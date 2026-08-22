#include "FWDLicenseManager.h"
#include "LicenseMasterKeys.h"

#include <QtCore/QDateTime>
#include <QtCore/QDebug>
#include <QtCore/QSettings>
#include <QtQml/qqml.h>

#include <openssl/evp.h>

const QString FWDLicenseManager::kSettingsGroup = QStringLiteral("FWDLicenses");
const QString kTimestampKey = QStringLiteral("ts");
// MAVLink epoch: 2015-01-01 UTC in microseconds
static const quint64 kMavlinkEpochUsec = 1420070400000000ULL;

FWDLicenseManager::FWDLicenseManager(QGCApplication* app, QGCToolbox* toolbox)
    : QGCTool(app, toolbox)
{
    qmlRegisterUncreatableType<FWDLicenseManager>("QGroundControl", 1, 0, "FWDLicenseManager", "Reference only");
}

QString FWDLicenseManager::boardUidFromPlaintext(const QByteArray& plaintext)
{
    if (plaintext.size() < 12) return QString();
    return plaintext.mid(0, 12).toHex().toUpper();
}

quint64 FWDLicenseManager::currentTimestampFromClock()
{
    static const QDateTime epoch(QDate(2015, 1, 1), QTime(0, 0));
    const quint64 nowUsec = static_cast<quint64>(epoch.msecsTo(QDateTime::currentDateTimeUtc())) * 1000;
    return (nowUsec - kMavlinkEpochUsec) / 10;
}

quint64 FWDLicenseManager::loadTimestamp(const QString& boardUid) const
{
    QSettings settings;
    settings.beginGroup(kSettingsGroup);
    const quint64 stored = settings.value(boardUid + QLatin1Char('/') + kTimestampKey, 0).toULongLong();
    settings.endGroup();
    return stored;
}

void FWDLicenseManager::saveTimestamp(const QString& boardUid, quint64 timestamp)
{
    QSettings settings;
    settings.beginGroup(kSettingsGroup);
    settings.setValue(boardUid + QLatin1Char('/') + kTimestampKey, timestamp);
    settings.endGroup();
}

quint64 FWDLicenseManager::getNextSigningTimestamp(const QString& boardUid)
{
    const quint64 stored = loadTimestamp(boardUid);
    const quint64 now = currentTimestampFromClock();
    const quint64 ts = qMax(stored, now);
    const quint64 next = ts + 1;
    saveTimestamp(boardUid, next);
    return next;
}

bool FWDLicenseManager::aes256gcmDecrypt(const QByteArray& ciphertext, const QByteArray& nonce, const QByteArray& tag, QByteArray* plaintext) const
{
    if (nonce.size() != 12 || ciphertext.size() != 44 || tag.size() != 16) {
        qWarning() << "FWDLicenseManager: Invalid AES-GCM input sizes";
        return false;
    }

    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) return false;

    bool ok = false;
    do {
        if (EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), nullptr, nullptr, nullptr) != 1) break;
        if (EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 12, nullptr) != 1) break;
        if (EVP_DecryptInit_ex(ctx, nullptr, nullptr, kFWDMasterAESKey, reinterpret_cast<const uint8_t*>(nonce.constData())) != 1) break;

        plaintext->resize(ciphertext.size());
        int len = 0;
        if (EVP_DecryptUpdate(ctx, reinterpret_cast<uint8_t*>(plaintext->data()), &len,
                              reinterpret_cast<const uint8_t*>(ciphertext.constData()), ciphertext.size()) != 1) break;

        if (EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, 16, const_cast<char*>(tag.constData())) != 1) break;

        int finalLen = 0;
        if (EVP_DecryptFinal_ex(ctx, reinterpret_cast<uint8_t*>(plaintext->data()) + len, &finalLen) != 1) break;

        plaintext->resize(len + finalLen);
        ok = true;
    } while (false);

    EVP_CIPHER_CTX_free(ctx);
    return ok;
}

bool FWDLicenseManager::activate(const QString& licenseString)
{
    const QByteArray raw = QByteArray::fromBase64(
        licenseString.trimmed().toUtf8(),
        QByteArray::Base64UrlEncoding | QByteArray::OmitTrailingEquals);

    if (raw.size() != 72) {
        qWarning() << "FWDLicenseManager: Invalid license length" << raw.size() << "expected 72 bytes";
        emit activationFailed(QStringLiteral("Invalid license format (expected 96 characters)"));
        return false;
    }

    const QByteArray nonce      = raw.mid(0, 12);
    const QByteArray ciphertext = raw.mid(12, 44);
    const QByteArray tag        = raw.mid(56, 16);

    QByteArray plaintext;
    if (!aes256gcmDecrypt(ciphertext, nonce, tag, &plaintext)) {
        qWarning() << "FWDLicenseManager: AES-256-GCM decryption failed";
        emit activationFailed(QStringLiteral("Invalid license key — decryption failed"));
        return false;
    }

    if (plaintext.size() != 44) {
        qWarning() << "FWDLicenseManager: Decrypted plaintext size" << plaintext.size() << "expected 44";
        emit activationFailed(QStringLiteral("Invalid license key — bad plaintext (expected 44 bytes)"));
        return false;
    }

    const QString boardUid = boardUidFromPlaintext(plaintext);
    const QByteArray signingKey = plaintext.mid(12, 32);

    if (boardUid.isEmpty()) {
        emit activationFailed(QStringLiteral("Invalid license key — empty board UID"));
        return false;
    }

    {
        QSettings settings;
        settings.beginGroup(kSettingsGroup);
        settings.setValue(boardUid, QString::fromLatin1(signingKey.toHex()));
        settings.endGroup();
    }

    qDebug() << "FWDLicenseManager: Activated license for drone" << boardUid;
    emit activationSucceeded(boardUid);
    return true;
}

QString FWDLicenseManager::boardUidFromLicense(const QString& licenseString) const
{
    const QByteArray raw = QByteArray::fromBase64(
        licenseString.trimmed().toUtf8(),
        QByteArray::Base64UrlEncoding | QByteArray::OmitTrailingEquals);

    if (raw.size() != 72) return QString();

    const QByteArray nonce      = raw.mid(0, 12);
    const QByteArray ciphertext = raw.mid(12, 44);
    const QByteArray tag        = raw.mid(56, 16);

    QByteArray plaintext;
    if (!aes256gcmDecrypt(ciphertext, nonce, tag, &plaintext)) return QString();
    if (plaintext.size() != 44) return QString();

    return boardUidFromPlaintext(plaintext);
}

QByteArray FWDLicenseManager::lookup(const QString& boardUid) const
{
    QSettings settings;
    settings.beginGroup(kSettingsGroup);
    const QString hexKey = settings.value(boardUid).toString();
    settings.endGroup();

    if (hexKey.isEmpty()) return QByteArray();
    return QByteArray::fromHex(hexKey.toLatin1());
}

bool FWDLicenseManager::remove(const QString& boardUid)
{
    QSettings settings;
    settings.beginGroup(kSettingsGroup);
    if (!settings.contains(boardUid)) return false;
    settings.remove(boardUid);
    settings.endGroup();
    emit licenseRemoved(boardUid);
    return true;
}

QVariantList FWDLicenseManager::list() const
{
    QVariantList result;
    QSettings settings;
    settings.beginGroup(kSettingsGroup);
    for (const auto& key : settings.childKeys()) {
        QVariantList pair;
        pair << key << (settings.value(key).toString().left(16) + QStringLiteral("..."));
        result.append(QVariant(pair));
    }
    settings.endGroup();
    return result;
}

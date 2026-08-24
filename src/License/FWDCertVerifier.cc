#include "FWDCertVerifier.h"
#include "LicenseMasterKeys.h"

#include <QtCore/QDebug>
#include <QtCore/QCryptographicHash>

#include <openssl/ec.h>
#include <openssl/pem.h>
#include <openssl/err.h>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

FWDCertVerifier::FWDCertVerifier(QObject* parent)
    : QObject(parent)
{
}

bool FWDCertVerifier::ecdsaP256Verify(const QByteArray& digest, const QByteArray& signature) const
{
    BIO* bio = BIO_new_mem_buf(kFWDMasterPublicKeyPEM, -1);
    if (!bio) return false;

    EC_KEY* ecKey = PEM_read_bio_EC_PUBKEY(bio, nullptr, nullptr, nullptr);
    BIO_free(bio);
    if (!ecKey) return false;

    bool ok = false;
    ECDSA_SIG* sig = ECDSA_SIG_new();
    if (!sig) {
        EC_KEY_free(ecKey);
        return false;
    }

    if (ECDSA_SIG_set0(sig,
            BN_bin2bn(reinterpret_cast<const uint8_t*>(signature.constData()), signature.size() / 2, nullptr),
            BN_bin2bn(reinterpret_cast<const uint8_t*>(signature.constData()) + signature.size() / 2, signature.size() - signature.size() / 2, nullptr))) {
        if (ECDSA_do_verify(reinterpret_cast<const uint8_t*>(digest.constData()), digest.size(), sig, ecKey) == 1) {
            ok = true;
        }
    }

    ECDSA_SIG_free(sig);
    EC_KEY_free(ecKey);
    return ok;
}

FWDCertVerifier::Result FWDCertVerifier::verify(const QByteArray& certBinary, const QString& expectedBoardUid)
{
    if (certBinary.size() < 78) {
        qDebug() << "FWDCertVerifier: Certificate too short" << certBinary.size();
        return NotPresent;
    }

    const uint8_t version = static_cast<uint8_t>(certBinary[0]);
    if (version != 0x01) {
        qDebug() << "FWDCertVerifier: Unknown version" << version;
        return InvalidFormat;
    }

    const QByteArray fileBoardUid = certBinary.mid(1, 12);
    const QString fileBoardUidHex = fileBoardUid.toHex().toUpper();

    if (fileBoardUidHex != expectedBoardUid) {
        qWarning() << "FWDCertVerifier: Board UID mismatch — cert" << fileBoardUidHex << "expected" << expectedBoardUid;
        return UidMismatch;
    }

    const QByteArray instancePub = certBinary.mid(13, 65);
    const QByteArray certSig = certBinary.mid(78);

    if (certSig.isEmpty()) {
        qWarning() << "FWDCertVerifier: Missing signature";
        return InvalidFormat;
    }

    const QByteArray certPayload = fileBoardUid + instancePub;
    const QByteArray digest = QCryptographicHash::hash(certPayload, QCryptographicHash::Sha256);

    if (!ecdsaP256Verify(digest, certSig)) {
        qWarning() << "FWDCertVerifier: ECDSA signature verification failed";
        return BadSignature;
    }

    qDebug() << "FWDCertVerifier: Certificate verified for" << expectedBoardUid;
    return Verified;
}

#pragma GCC diagnostic pop

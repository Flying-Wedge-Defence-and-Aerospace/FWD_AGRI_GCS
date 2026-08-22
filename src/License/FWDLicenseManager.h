#pragma once

#include <QtCore/QObject>
#include <QtCore/QByteArray>
#include <QtCore/QString>
#include <QtCore/QVariant>
#include <QtCore/QList>
#include <QtCore/QPair>
#include <QtCore/QSettings>

#include "QGCToolbox.h"

class FWDLicenseManager : public QGCTool
{
    Q_OBJECT
public:
    FWDLicenseManager(QGCApplication* app, QGCToolbox* toolbox);

    Q_INVOKABLE bool activate(const QString& licenseString);
    Q_INVOKABLE QByteArray lookup(const QString& boardUid) const;
    Q_INVOKABLE bool remove(const QString& boardUid);
    Q_INVOKABLE QVariantList list() const;
    Q_INVOKABLE QString boardUidFromLicense(const QString& licenseString) const;
    quint64 loadTimestamp(const QString& boardUid) const;
    void saveTimestamp(const QString& boardUid, quint64 timestamp);
    quint64 getNextSigningTimestamp(const QString& boardUid);

    static QString boardUidFromPlaintext(const QByteArray& plaintext);
    static quint64 currentTimestampFromClock();

signals:
    void activationFailed(const QString& reason);
    void activationSucceeded(const QString& boardUid);
    void licenseRemoved(const QString& boardUid);

private:
    bool aes256gcmDecrypt(const QByteArray& ciphertext, const QByteArray& nonce, const QByteArray& tag, QByteArray* plaintext) const;
    static const QString kSettingsGroup;
};

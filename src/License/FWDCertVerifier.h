#pragma once

#include <QtCore/QObject>
#include <QtCore/QByteArray>
#include <QtCore/QString>

class FWDCertVerifier : public QObject
{
    Q_OBJECT
public:
    explicit FWDCertVerifier(QObject* parent = nullptr);

    enum Result {
        Verified,
        NotPresent,
        BadSignature,
        UidMismatch,
        InvalidFormat,
        UnknownError
    };

    Result verify(const QByteArray& certBinary, const QString& expectedBoardUid);

private:
    bool ecdsaP256Verify(const QByteArray& digest, const QByteArray& signature) const;
};

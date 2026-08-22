#include "MAVLinkSigning.h"
#include "QGCMAVLink.h"

#include <QtCore/QDateTime>
#include <QtCore/QDebug>
#include <QtCore/QSettings>

namespace
{

void _setSigningKey(mavlink_signing_t *signing, const QByteArray& key)
{
    if (!key.isEmpty() && key.size() >= static_cast<qsizetype>(sizeof(signing->secret_key))) {
        (void) memcpy(signing->secret_key, key.constData(), sizeof(signing->secret_key));
    } else {
        (void) memset(signing->secret_key, 0, sizeof(signing->secret_key));
    }
}

void _setSigningTimestamp(mavlink_signing_t *signing)
{
    static const QDateTime offset_time(QDate(2015, 1, 1), QTime(0, 0));
    const uint64_t current_timestamp = offset_time.msecsTo(QDateTime::currentDateTimeUtc());
    signing->timestamp = current_timestamp * 100;
}

static bool _defaultAcceptUnsignedCallback(const mavlink_status_t *status, uint32_t message_id)
{
    Q_UNUSED(status);
    Q_UNUSED(message_id);
    return true;
}

uint64_t s_enforcementStartTime[MAVLINK_COMM_NUM_BUFFERS] = {};
bool s_enforcementEnabled[MAVLINK_COMM_NUM_BUFFERS] = {};

static bool _enforceAcceptUnsignedCallback(const mavlink_status_t *status, uint32_t message_id)
{
    if (!status) {
        qDebug() << "MAVLinkSigning: callback called with NULL status, msgid" << message_id;
        return true;
    }

    const mavlink_status_t* base = mavlink_get_channel_status(0);
    const ptrdiff_t diff = status - base;
    if (diff < 0 || diff >= static_cast<ptrdiff_t>(MAVLINK_COMM_NUM_BUFFERS)) {
        qDebug() << "MAVLinkSigning: callback called with out-of-range channel offset" << diff << "msgid" << message_id;
        return true;
    }
    const uint8_t channel = static_cast<uint8_t>(diff);

    if (!status->signing) {
        qDebug() << "MAVLinkSigning: callback ch" << channel << "msgid" << message_id << "status->signing is NULL, accepting";
        return true;
    }

    if (!s_enforcementEnabled[channel]) {
        qDebug() << "MAVLinkSigning: callback ch" << channel << "msgid" << message_id << "enforcement OFF, accepting";
        return true;
    }

    const uint64_t elapsed = QDateTime::currentMSecsSinceEpoch() - s_enforcementStartTime[channel];
    if (elapsed < 2000) {
        qDebug() << "MAVLinkSigning: callback ch" << channel << "msgid" << message_id << "grace period" << elapsed << "ms";
        return true;
    }

    qDebug() << "MAVLinkSigning: REJECTING packet ch" << channel << "msgid" << message_id;
    return false;
}

}

namespace MAVLinkSigning
{

bool initSigning(mavlink_channel_t channel, const QByteArray& key, mavlink_accept_unsigned_t callback)
{
    mavlink_status_t* status = mavlink_get_channel_status(channel);
    if (!status) {
        qWarning() << "MAVLinkSigning::initSigning: Invalid channel" << channel;
        return false;
    }

    if (key.isEmpty()) {
        qDebug() << "MAVLinkSigning::initSigning: Disabling signing on channel" << channel;
        status->signing = nullptr;
        status->signing_streams = nullptr;
        return true;
    }

    qDebug() << "MAVLinkSigning::initSigning: Enabling signing on channel" << channel;

    static mavlink_signing_t s_signing[MAVLINK_COMM_NUM_BUFFERS];
    static mavlink_signing_streams_t s_signing_streams;

    mavlink_signing_t* signing = &s_signing[channel];
    memset(signing, 0, sizeof(*signing));
    signing->link_id = channel;
    signing->flags |= MAVLINK_SIGNING_FLAG_SIGN_OUTGOING;
    signing->accept_unsigned_callback = callback ? callback : _defaultAcceptUnsignedCallback;

    _setSigningKey(signing, key);
    _setSigningTimestamp(signing);

    status->signing = signing;
    status->signing_streams = &s_signing_streams;

    status->flags &= ~MAVLINK_STATUS_FLAG_OUT_MAVLINK1;

    return true;
}

bool isSigningEnabled(mavlink_channel_t channel)
{
    mavlink_status_t* status = mavlink_get_channel_status(channel);
    return status && status->signing != nullptr;
}

bool setSigningTimestamp(mavlink_channel_t channel, quint64 timestamp)
{
    mavlink_status_t* status = mavlink_get_channel_status(channel);
    if (!status || !status->signing) {
        qWarning() << "MAVLinkSigning::setSigningTimestamp: Signing not initialized on channel" << channel;
        return false;
    }
    status->signing->timestamp = timestamp;
    return true;
}

void createSetupSigning(mavlink_channel_t channel, mavlink_system_t target_system, const QByteArray& keyBytes, mavlink_setup_signing_t &setup_signing)
{
    memset(&setup_signing, 0, sizeof(setup_signing));
    setup_signing.target_system = target_system.sysid;
    setup_signing.target_component = target_system.compid;

    if (!keyBytes.isEmpty() && keyBytes.size() >= static_cast<qsizetype>(sizeof(setup_signing.secret_key))) {
        mavlink_status_t* status = mavlink_get_channel_status(channel);
        if (status && status->signing) {
            setup_signing.initial_timestamp = status->signing->timestamp;
        } else {
            static const QDateTime offset_time(QDate(2015, 1, 1), QTime(0, 0));
            setup_signing.initial_timestamp = static_cast<uint64_t>(offset_time.msecsTo(QDateTime::currentDateTimeUtc())) * 100;
        }
        memcpy(setup_signing.secret_key, keyBytes.constData(), sizeof(setup_signing.secret_key));
    }
}

void createDisableSigning(mavlink_system_t target_system, mavlink_setup_signing_t &setup_signing)
{
    memset(&setup_signing, 0, sizeof(setup_signing));
    setup_signing.target_system = target_system.sysid;
    setup_signing.target_component = target_system.compid;
}

bool isEnforcementActive(mavlink_channel_t channel)
{
    if (static_cast<int>(channel) >= MAVLINK_COMM_NUM_BUFFERS) return false;
    return s_enforcementEnabled[channel];
}

void enableEnforcement(mavlink_channel_t channel, bool enforce, bool useGrace)
{
    mavlink_status_t* status = mavlink_get_channel_status(channel);
    if (!status) {
        qWarning() << "MAVLinkSigning::enableEnforcement: Invalid channel" << channel;
        return;
    }

    s_enforcementEnabled[channel] = enforce;

    if (enforce) {
        qDebug() << "MAVLinkSigning::enableEnforcement: Enabling enforcement on channel" << channel
                 << "signing ptr" << status->signing
                 << "useGrace" << useGrace
                 << "callback was" << (status->signing ? (const void*)status->signing->accept_unsigned_callback : 0);
        s_enforcementStartTime[channel] = useGrace ? QDateTime::currentMSecsSinceEpoch() : 0;
        if (status->signing) {
            status->signing->accept_unsigned_callback = _enforceAcceptUnsignedCallback;
            qDebug() << "MAVLinkSigning::enableEnforcement: callback now" << (const void*)status->signing->accept_unsigned_callback;
        } else {
            qDebug() << "MAVLinkSigning::enableEnforcement: WARNING status->signing is NULL, cannot set callback!";
        }
    } else {
        qDebug() << "MAVLinkSigning::enableEnforcement: Disabling enforcement on channel" << channel;
        if (status->signing) {
            status->signing->accept_unsigned_callback = _defaultAcceptUnsignedCallback;
        }
    }
}

void initEnforcementForAll()
{
    QSettings settings;
    settings.beginGroup("MAVLink");
    const QString signingKeyHex = settings.value("MAVLink2SigningKey").toString();
    settings.endGroup();

    if (signingKeyHex.isEmpty()) {
        qDebug() << "MAVLinkSigning::initEnforcementForAll: No key stored, leaving channels unsigned";
        return;
    }

    const QByteArray key = QByteArray::fromHex(signingKeyHex.toLatin1());
    if (key.size() != 32) {
        qDebug() << "MAVLinkSigning::initEnforcementForAll: Invalid key length" << key.size() << ", leaving channels unsigned";
        return;
    }

    qDebug() << "MAVLinkSigning::initEnforcementForAll: Restoring signing on all channels (no enforcement)";
    for (uint8_t i = 0; i < MAVLINK_COMM_NUM_BUFFERS; i++) {
        const mavlink_channel_t channel = static_cast<mavlink_channel_t>(i);
        initSigning(channel, key);
    }
}

void disableAll()
{
    for (uint8_t i = 0; i < MAVLINK_COMM_NUM_BUFFERS; i++) {
        const mavlink_channel_t channel = static_cast<mavlink_channel_t>(i);
        enableEnforcement(channel, false);
        initSigning(channel, QByteArray());
    }
}

}

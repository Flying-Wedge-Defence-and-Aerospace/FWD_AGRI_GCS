#pragma once

#include <QtCore/QByteArray>

#include "QGCMAVLink.h"

namespace MAVLinkSigning
{
    bool initSigning(mavlink_channel_t channel, const QByteArray& key, mavlink_accept_unsigned_t callback = nullptr);
    bool setSigningTimestamp(mavlink_channel_t channel, quint64 timestamp);
    bool isSigningEnabled(mavlink_channel_t channel);
    void createSetupSigning(mavlink_channel_t channel, mavlink_system_t target_system, const QByteArray& keyBytes, mavlink_setup_signing_t &setup_signing);
    void createDisableSigning(mavlink_system_t target_system, mavlink_setup_signing_t &setup_signing);
    void enableEnforcement(mavlink_channel_t channel, bool enforce, bool useGrace = true);
    bool isEnforcementActive(mavlink_channel_t channel);
    void initEnforcementForAll();
    void disableAll();
}

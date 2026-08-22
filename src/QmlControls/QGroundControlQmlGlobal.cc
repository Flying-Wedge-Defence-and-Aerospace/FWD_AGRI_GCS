/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "QGroundControlQmlGlobal.h"
#include "LinkManager.h"
#include "MAVLinkSigning.h"

#include <QSettings>
#include <QLineF>
#include <QPointF>

static const char* kQmlGlobalKeyName = "QGCQml";

const char* QGroundControlQmlGlobal::_flightMapPositionSettingsGroup =          "FlightMapPosition";
const char* QGroundControlQmlGlobal::_flightMapPositionLatitudeSettingsKey =    "Latitude";
const char* QGroundControlQmlGlobal::_flightMapPositionLongitudeSettingsKey =   "Longitude";
const char* QGroundControlQmlGlobal::_flightMapZoomSettingsKey =                "FlightMapZoom";

QGeoCoordinate   QGroundControlQmlGlobal::_coord = QGeoCoordinate(0.0,0.0);
double           QGroundControlQmlGlobal::_zoom = 2;

QGroundControlQmlGlobal::QGroundControlQmlGlobal(QGCApplication* app, QGCToolbox* toolbox)
    : QGCTool               (app, toolbox)
{
    // We clear the parent on this object since we run into shutdown problems caused by hybrid qml app. Instead we let it leak on shutdown.
    setParent(nullptr);

    // Load last coordinates and zoom from config file
    QSettings settings;
    settings.beginGroup(_flightMapPositionSettingsGroup);
    _coord.setLatitude(settings.value(_flightMapPositionLatitudeSettingsKey,    _coord.latitude()).toDouble());
    _coord.setLongitude(settings.value(_flightMapPositionLongitudeSettingsKey,  _coord.longitude()).toDouble());
    _zoom = settings.value(_flightMapZoomSettingsKey, _zoom).toDouble();
    _flightMapPositionSettledTimer.setSingleShot(true);
    _flightMapPositionSettledTimer.setInterval(1000);
    connect(&_flightMapPositionSettledTimer, &QTimer::timeout, [](){
        // When they settle, save flightMapPosition and Zoom to the config file
        QSettings settings;
        settings.beginGroup(_flightMapPositionSettingsGroup);
        settings.setValue(_flightMapPositionLatitudeSettingsKey, _coord.latitude());
        settings.setValue(_flightMapPositionLongitudeSettingsKey, _coord.longitude());
        settings.setValue(_flightMapZoomSettingsKey, _zoom);
    });
    connect(this, &QGroundControlQmlGlobal::flightMapPositionChanged, this, [this](QGeoCoordinate){
        if (!_flightMapPositionSettledTimer.isActive()) {
            _flightMapPositionSettledTimer.start();
        }
    });
    connect(this, &QGroundControlQmlGlobal::flightMapZoomChanged, this, [this](double){
        if (!_flightMapPositionSettledTimer.isActive()) {
            _flightMapPositionSettledTimer.start();
        }
    });
}

QGroundControlQmlGlobal::~QGroundControlQmlGlobal()
{
}

void QGroundControlQmlGlobal::setToolbox(QGCToolbox* toolbox)
{
    QGCTool::setToolbox(toolbox);

    _linkManager            = toolbox->linkManager();
    _multiVehicleManager    = toolbox->multiVehicleManager();
    _mapEngineManager       = toolbox->mapEngineManager();
    _qgcPositionManager     = toolbox->qgcPositionManager();
    _missionCommandTree     = toolbox->missionCommandTree();
    _videoManager           = toolbox->videoManager();
    _mavlinkLogManager      = toolbox->mavlinkLogManager();
    _corePlugin             = toolbox->corePlugin();
    _firmwarePluginManager  = toolbox->firmwarePluginManager();
    _settingsManager        = toolbox->settingsManager();
    _gpsRtkFactGroup        = qgcApp()->gpsRtkFactGroup();
    _adsbVehicleManager     = toolbox->adsbVehicleManager();
    _globalPalette          = new QGCPalette(this);
#if defined(QGC_ENABLE_PAIRING)
    _pairingManager         = toolbox->pairingManager();
#endif
#if defined(QGC_GST_TAISYNC_ENABLED)
    _taisyncManager         = toolbox->taisyncManager();
#endif
#if defined(QGC_GST_MICROHARD_ENABLED)
    _microhardManager       = toolbox->microhardManager();
#endif
}

void QGroundControlQmlGlobal::saveGlobalSetting (const QString& key, const QString& value)
{
    QSettings settings;
    settings.beginGroup(kQmlGlobalKeyName);
    settings.setValue(key, value);
}

QString QGroundControlQmlGlobal::loadGlobalSetting (const QString& key, const QString& defaultValue)
{
    QSettings settings;
    settings.beginGroup(kQmlGlobalKeyName);
    return settings.value(key, defaultValue).toString();
}

void QGroundControlQmlGlobal::saveBoolGlobalSetting (const QString& key, bool value)
{
    QSettings settings;
    settings.beginGroup(kQmlGlobalKeyName);
    settings.setValue(key, value);
}

bool QGroundControlQmlGlobal::loadBoolGlobalSetting (const QString& key, bool defaultValue)
{
    QSettings settings;
    settings.beginGroup(kQmlGlobalKeyName);
    return settings.value(key, defaultValue).toBool();
}

void QGroundControlQmlGlobal::startPX4MockLink(bool sendStatusText)
{
#ifdef QT_DEBUG
    MockLink::startPX4MockLink(sendStatusText);
#else
    Q_UNUSED(sendStatusText);
#endif
}

void QGroundControlQmlGlobal::startGenericMockLink(bool sendStatusText)
{
#ifdef QT_DEBUG
    MockLink::startGenericMockLink(sendStatusText);
#else
    Q_UNUSED(sendStatusText);
#endif
}

void QGroundControlQmlGlobal::startAPMArduCopterMockLink(bool sendStatusText)
{
#ifdef QT_DEBUG
    MockLink::startAPMArduCopterMockLink(sendStatusText);
#else
    Q_UNUSED(sendStatusText);
#endif
}

void QGroundControlQmlGlobal::startAPMArduPlaneMockLink(bool sendStatusText)
{
#ifdef QT_DEBUG
    MockLink::startAPMArduPlaneMockLink(sendStatusText);
#else
    Q_UNUSED(sendStatusText);
#endif
}

void QGroundControlQmlGlobal::startAPMArduSubMockLink(bool sendStatusText)
{
#ifdef QT_DEBUG
    MockLink::startAPMArduSubMockLink(sendStatusText);
#else
    Q_UNUSED(sendStatusText);
#endif
}

void QGroundControlQmlGlobal::startAPMArduRoverMockLink(bool sendStatusText)
{
#ifdef QT_DEBUG
    MockLink::startAPMArduRoverMockLink(sendStatusText);
#else
    Q_UNUSED(sendStatusText);
#endif
}

void QGroundControlQmlGlobal::startMavlinkConnections(void)
{
    _toolbox->linkManager()->setConnectionsAllowed();
    _toolbox->linkManager()->startAutoConnectedLinks();
}

void QGroundControlQmlGlobal::sendSetupSigningToAutopilot(const QString& keyHex)
{
    const QByteArray key = QByteArray::fromHex(keyHex.toLatin1());
    if (key.size() != 32) {
        qWarning() << "sendSetupSigningToAutopilot: Invalid key length" << key.size() << "expected 32 bytes (64 hex chars)";
        return;
    }

    qDebug() << "sendSetupSigningToAutopilot: sending SETUP_SIGNING unsigned on all links";

    const uint8_t sysId = static_cast<uint8_t>(_toolbox->mavlinkProtocol()->getSystemId());
    const uint8_t compId = static_cast<uint8_t>(_toolbox->mavlinkProtocol()->getComponentId());
    const mavlink_system_t target = { 0, 0 };

    // 1. Send SETUP_SIGNING unsigned on all active links
    const QList<SharedLinkInterfacePtr> sharedLinks = _toolbox->linkManager()->links();
    for (const auto& sharedLink : sharedLinks) {
        if (!sharedLink->isConnected()) continue;

        const mavlink_channel_t channel = static_cast<mavlink_channel_t>(sharedLink->mavlinkChannel());

        // Temporarily disable signing so message goes unsigned
        mavlink_status_t* status = mavlink_get_channel_status(channel);
        if (status) {
            status->signing = nullptr;
            status->flags &= ~MAVLINK_STATUS_FLAG_OUT_MAVLINK1;
        }

        mavlink_setup_signing_t setup_signing;
        MAVLinkSigning::createSetupSigning(channel, target, key, setup_signing);
        mavlink_message_t msg;
        mavlink_msg_setup_signing_encode_chan(sysId, compId, channel, &msg, &setup_signing);
        uint8_t buf[MAVLINK_MAX_PACKET_LEN];
        const int len = mavlink_msg_to_send_buffer(buf, &msg);
        sharedLink->writeBytesThreadSafe(reinterpret_cast<const char*>(buf), len);

        qDebug() << "sendSetupSigningToAutopilot: sent SETUP_SIGNING on ch" << channel;
    }

    // 2. Save key to QSettings
    {
        QSettings settings;
        settings.beginGroup("MAVLink");
        settings.setValue("MAVLink2SigningKey", keyHex);
        settings.endGroup();
    }

    // 3. Re-init signing + enforcement on all channels with the real key
    for (uint8_t i = 0; i < MAVLINK_COMM_NUM_BUFFERS; i++) {
        const mavlink_channel_t channel = static_cast<mavlink_channel_t>(i);
        MAVLinkSigning::initSigning(channel, key);
    }

    // 4. Enable enforcement on link channels
    for (const auto& sharedLink : sharedLinks) {
        if (!sharedLink->isConnected()) continue;
        const mavlink_channel_t channel = static_cast<mavlink_channel_t>(sharedLink->mavlinkChannel());
        MAVLinkSigning::enableEnforcement(channel, true);
    }

    qDebug() << "sendSetupSigningToAutopilot: done";
}

void QGroundControlQmlGlobal::stopOneMockLink(void)
{
#ifdef QT_DEBUG
    QList<SharedLinkInterfacePtr> sharedLinks = _toolbox->linkManager()->links();

    for (int i=0; i<sharedLinks.count(); i++) {
        LinkInterface* link = sharedLinks[i].get();
        MockLink* mockLink = qobject_cast<MockLink*>(link);
        if (mockLink) {
            mockLink->disconnect();
            return;
        }
    }
#endif
}

void QGroundControlQmlGlobal::setIsVersionCheckEnabled(bool enable)
{
    qgcApp()->toolbox()->mavlinkProtocol()->enableVersionCheck(enable);
    emit isVersionCheckEnabledChanged(enable);
}

void QGroundControlQmlGlobal::setMavlinkSystemID(int id)
{
    qgcApp()->toolbox()->mavlinkProtocol()->setSystemId(id);
    emit mavlinkSystemIDChanged(id);
}

bool QGroundControlQmlGlobal::singleFirmwareSupport(void)
{
    return _firmwarePluginManager->supportedFirmwareClasses().count() == 1;
}

bool QGroundControlQmlGlobal::singleVehicleSupport(void)
{
    if (singleFirmwareSupport()) {
        return _firmwarePluginManager->supportedVehicleClasses(_firmwarePluginManager->supportedFirmwareClasses()[0]).count() == 1;
    }

    return false;
}

bool QGroundControlQmlGlobal::px4ProFirmwareSupported()
{
    return _firmwarePluginManager->supportedFirmwareClasses().contains(QGCMAVLink::FirmwareClassPX4);
}

bool QGroundControlQmlGlobal::apmFirmwareSupported()
{
    return _firmwarePluginManager->supportedFirmwareClasses().contains(QGCMAVLink::FirmwareClassArduPilot);
}

bool QGroundControlQmlGlobal::linesIntersect(QPointF line1A, QPointF line1B, QPointF line2A, QPointF line2B)
{
    QPointF intersectPoint;

    auto intersect = QLineF(line1A, line1B).intersects(QLineF(line2A, line2B), &intersectPoint);

    return  intersect == QLineF::BoundedIntersection &&
            intersectPoint != line1A && intersectPoint != line1B;
}

void QGroundControlQmlGlobal::setSkipSetupPage(bool skip)
{
    if(_skipSetupPage != skip) {
        _skipSetupPage = skip;
        emit skipSetupPageChanged();
    }
}

void QGroundControlQmlGlobal::setFlightMapPosition(QGeoCoordinate& coordinate)
{
    if (coordinate != flightMapPosition()) {
        _coord.setLatitude(coordinate.latitude());
        _coord.setLongitude(coordinate.longitude());
        emit flightMapPositionChanged(coordinate);
    }
}

void QGroundControlQmlGlobal::setFlightMapZoom(double zoom)
{
    if (zoom != flightMapZoom()) {
        _zoom = zoom;
        emit flightMapZoomChanged(zoom);
    }
}

QString QGroundControlQmlGlobal::qgcVersion(void) const
{
    QString versionStr = qgcApp()->applicationVersion();
#ifdef __androidArm32__
    versionStr += QStringLiteral(" %1").arg(tr("32 bit"));
#elif __androidArm64__
    versionStr += QStringLiteral(" %1").arg(tr("64 bit"));
#endif
    return versionStr;
}

QString QGroundControlQmlGlobal::altitudeModeExtraUnits(AltMode altMode)
{
    switch (altMode) {
    case AltitudeModeNone:
        return QString();
    case AltitudeModeRelative:
        // Showing (Rel) all the time ends up being too noisy
        return QString();
    case AltitudeModeAbsolute:
        return tr("(AMSL)");
    case AltitudeModeCalcAboveTerrain:
        return tr("(CalcT)");
    case AltitudeModeTerrainFrame:
        return tr("(TerrF)");
    case AltitudeModeMixed:
        qWarning() << "Internal Error: QGroundControlQmlGlobal::altitudeModeExtraUnits called with altMode == AltitudeModeMixed";
        return QString();
    }

    // Should never get here but makes some compilers happy
    return QString();
}

QString QGroundControlQmlGlobal::altitudeModeShortDescription(AltMode altMode)
{
    switch (altMode) {
    case AltitudeModeNone:
        return QString();
    case AltitudeModeRelative:
        return tr("Relative To Launch");
    case AltitudeModeAbsolute:
        return tr("AMSL");
    case AltitudeModeCalcAboveTerrain:
        return tr("Calc Above Terrain");
    case AltitudeModeTerrainFrame:
        return tr("Terrain Frame");
    case AltitudeModeMixed:
        return tr("Mixed Modes");
    }

    // Should never get here but makes some compilers happy
    return QString();
}

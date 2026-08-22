#include "FWDUpdateManager.h"
#include "FWDUpdateConfig.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkRequest>
#include <QStandardPaths>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QDesktopServices>
#include <QUrl>
#include <QApplication>
#include <QRegularExpression>
#include <QDebug>
#include <QMessageBox>

#if defined(Q_OS_ANDROID)
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#endif

FWDUpdateManager::FWDUpdateManager(QObject* parent)
    : QObject(parent)
    , _networkManager(new QNetworkAccessManager(this))
    , _downloadManager(new QNetworkAccessManager(this))
{
}

QString FWDUpdateManager::_currentVersion() const
{
    return QString(APP_VERSION_STR);
}

bool FWDUpdateManager::_parseVersion(const QString& versionString, int& major, int& minor, int& patch)
{
    QRegularExpression regExp("v?(\\d+)\\.(\\d+)\\.(\\d+)");
    QRegularExpressionMatch match = regExp.match(versionString);
    if (match.hasMatch() && match.lastCapturedIndex() == 3) {
        major = match.captured(1).toInt();
        minor = match.captured(2).toInt();
        patch = match.captured(3).toInt();
        return true;
    }
    return false;
}

void FWDUpdateManager::checkForUpdates()
{
    qDebug() << "FWDUpdateManager: Checking for updates...";

    QNetworkRequest request{QUrl(FWD_UPDATE_API_URL)};
    request.setRawHeader("Authorization", QString("token %1").arg(FWD_UPDATE_GITHUB_TOKEN).toUtf8());
    request.setRawHeader("Accept", "application/vnd.github.v3+json");

    QNetworkReply* reply = _networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        _onVersionCheckFinished(reply);
    });
}

void FWDUpdateManager::_onVersionCheckFinished(QNetworkReply* reply)
{
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "FWDUpdateManager: Version check failed:" << reply->errorString();
        emit checkFailed(reply->errorString());
        return;
    }

    QByteArray responseData = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);

    if (!jsonDoc.isObject()) {
        qDebug() << "FWDUpdateManager: Invalid JSON response";
        emit checkFailed("Invalid response from server");
        return;
    }

    QJsonObject releaseObj = jsonDoc.object();

    // Get version tag (e.g., "v1.0.3")
    _latestVersion = releaseObj["tag_name"].toString();
    _changelog = releaseObj["body"].toString();

    if (_latestVersion.isEmpty()) {
        emit checkFailed("No version tag found in release");
        return;
    }

    // Parse versions for comparison
    int currentMajor, currentMinor, currentPatch;
    int latestMajor, latestMinor, latestPatch;

    if (!_parseVersion(_currentVersion(), currentMajor, currentMinor, currentPatch)) {
        qDebug() << "FWDUpdateManager: Failed to parse current version:" << _currentVersion();
        emit checkFailed("Failed to parse current version");
        return;
    }

    if (!_parseVersion(_latestVersion, latestMajor, latestMinor, latestPatch)) {
        qDebug() << "FWDUpdateManager: Failed to parse latest version:" << _latestVersion;
        emit checkFailed("Failed to parse latest version");
        return;
    }

    qDebug() << "FWDUpdateManager: Current:" << currentMajor << "." << currentMinor << "." << currentPatch
             << "Latest:" << latestMajor << "." << latestMinor << "." << latestPatch;

    // Compare versions
    if (latestMajor > currentMajor ||
        (latestMajor == currentMajor && latestMinor > currentMinor) ||
        (latestMajor == currentMajor && latestMinor == currentMinor && latestPatch > currentPatch)) {

        _updateAvailable = true;

        // Find platform-specific download URL from assets
        QJsonArray assets = releaseObj["assets"].toArray();
        QString platformSuffix = _platformAssetName();

        for (const QJsonValue& asset : assets) {
            QJsonObject assetObj = asset.toObject();
            QString fileName = assetObj["name"].toString();

            if (fileName.contains(platformSuffix, Qt::CaseInsensitive)) {
                // For private repos, use the asset API endpoint (url field) with Accept: application/octet-stream
                // instead of browser_download_url which only works for public repos
                _downloadUrl = assetObj["url"].toString();
                _downloadFileName = fileName;
                qDebug() << "FWDUpdateManager: Found asset:" << fileName << "->" << _downloadUrl;
                break;
            }
        }

        if (_downloadUrl.isEmpty()) {
            qDebug() << "FWDUpdateManager: No platform asset found for:" << platformSuffix;
            // Still notify update available, but without direct download
            emit updateAvailable(_latestVersion, _changelog);
        } else {
            emit updateAvailable(_latestVersion, _changelog);
        }
    } else {
        qDebug() << "FWDUpdateManager: Already up to date";
        emit noUpdateAvailable();
    }
}

QString FWDUpdateManager::_platformAssetName() const
{
#if defined(Q_OS_WIN)
    return QStringLiteral(".exe");
#elif defined(Q_OS_LINUX)
    return QStringLiteral(".AppImage");
#elif defined(Q_OS_ANDROID)
    return QStringLiteral(".apk");
#elif defined(Q_OS_IOS)
    return QStringLiteral(".ipa");
#else
    return QString();
#endif
}

void FWDUpdateManager::downloadUpdate()
{
    if (_downloadUrl.isEmpty()) {
        emit downloadError("No download URL available");
        return;
    }

    if (_isDownloading) {
        return;
    }

    _isDownloading = true;
    _downloadProgress = 0;
    _downloadTotal = 0;

    qDebug() << "FWDUpdateManager: Starting download from:" << _downloadUrl;

    QNetworkRequest request{QUrl(_downloadUrl)};
    request.setRawHeader("Authorization", QString("token %1").arg(FWD_UPDATE_GITHUB_TOKEN).toUtf8());
    request.setRawHeader("Accept", "application/octet-stream");

    QNetworkReply* reply = _downloadManager->get(request);
    connect(reply, &QNetworkReply::downloadProgress, this, &FWDUpdateManager::_onDownloadProgress);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        _onDownloadFinished(reply);
    });
}

void FWDUpdateManager::_onDownloadError(QNetworkReply::NetworkError code)
{
    Q_UNUSED(code);
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(sender());
    if (reply) {
        qDebug() << "FWDUpdateManager: Download error:" << reply->errorString();
        emit downloadError(reply->errorString());
        _isDownloading = false;
        reply->deleteLater();
    }
}

void FWDUpdateManager::_onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    _downloadProgress = bytesReceived;
    _downloadTotal = bytesTotal;
    emit downloadProgressChanged(bytesReceived, bytesTotal);
}

void FWDUpdateManager::_onDownloadFinished(QNetworkReply* reply)
{
    if (!reply) return;

    reply->deleteLater();
    _isDownloading = false;

    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "FWDUpdateManager: Download failed:" << reply->errorString();
        emit downloadError(reply->errorString());
        return;
    }

    // Check for redirect
    QVariant redirectionTarget = reply->attribute(QNetworkRequest::RedirectionTargetAttribute);
    if (!redirectionTarget.isNull()) {
        QUrl redirectUrl = reply->url().resolved(redirectionTarget.toUrl());
        _downloadUrl = redirectUrl.toString();
        downloadUpdate();
        return;
    }

    // Determine filename from the known asset name (not from redirect URL which has long query params)
    QString remoteFileName = _downloadFileName;
    if (remoteFileName.isEmpty()) {
        // Fallback: extract from URL but strip query params
        QString urlStr = reply->url().toString();
        int queryPos = urlStr.indexOf('?');
        if (queryPos > 0) {
            urlStr = urlStr.left(queryPos);
        }
        remoteFileName = QFileInfo(urlStr).fileName();
    }
    if (remoteFileName.isEmpty()) {
        remoteFileName = "FWDUpdate";
    }

    // Save to temp directory
    QString downloadDir = QStandardPaths::writableLocation(QStandardPaths::TempLocation);
    if (downloadDir.isEmpty()) {
        downloadDir = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    }

    QString filePath = downloadDir + "/" + remoteFileName;
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qDebug() << "FWDUpdateManager: Failed to save file:" << filePath;
        emit downloadError("Failed to save downloaded file: " + file.errorString());
        return;
    }

    file.write(reply->readAll());
    file.close();

    _downloadedFilePath = filePath;
    qDebug() << "FWDUpdateManager: Download complete:" << filePath;

    emit downloadFinished(filePath);
}

void FWDUpdateManager::installUpdate()
{
    if (_downloadedFilePath.isEmpty()) {
        qDebug() << "FWDUpdateManager: No file to install";
        return;
    }

    qDebug() << "FWDUpdateManager: Installing update from:" << _downloadedFilePath;

#if defined(Q_OS_LINUX)
    // In an AppImage, applicationFilePath() points inside a read-only squashfs mount.
    // Use $APPIMAGE env var to get the real file path on disk.
    QString currentBinPath = qgetenv("APPIMAGE");
    if (currentBinPath.isEmpty()) {
        currentBinPath = QCoreApplication::applicationFilePath();
    }
    qDebug() << "FWDUpdateManager: Current binary path:" << currentBinPath;

    if (!QFile::remove(currentBinPath)) {
        QMessageBox::critical(nullptr, tr("Update Failed"),
            tr("Cannot delete:\n%1\n\nCheck that you have write permission to this folder.")
            .arg(currentBinPath));
        return;
    }

    if (!QFile::copy(_downloadedFilePath, currentBinPath)) {
        QMessageBox::critical(nullptr, tr("Update Failed"),
            tr("Failed to copy update to:\n%1").arg(currentBinPath));
        return;
    }

    QProcess::startDetached("chmod", {"+x", currentBinPath});
    QProcess::startDetached(currentBinPath, QStringList());
    QApplication::quit();

#elif defined(Q_OS_WIN)
    // Run the installer
    QDesktopServices::openUrl(QUrl::fromLocalFile(_downloadedFilePath));
    // Quit current app so installer can overwrite
    QApplication::quit();

#elif defined(Q_OS_ANDROID)
    // Open APK with system installer
    QAndroidJniObject intent("android/content/Intent", "(Ljava/lang/String;)V",
        QAndroidJniObject::getStaticObjectField("android/content/Intent", "ACTION_VIEW",
            "Ljava/lang/String;"));
    QAndroidJniObject fileUri = QAndroidJniObject::callStaticObjectMethod(
        "android/net/Uri", "parse",
        "(Ljava/lang/String;)Landroid/net/Uri;",
        QAndroidJniObject::fromString("file://" + _downloadedFilePath).object());
    intent.callObjectMethod("setDataAndType",
        "(Landroid/net/Uri;Ljava/lang/String;)Landroid/content/Intent;",
        fileUri.object(),
        QAndroidJniObject::fromString("application/vnd.android.package-archive").object());
    intent.callObjectMethod("addFlags",
        "(I)Landroid/content/Intent;",
        0x00000001); // FLAG_GRANT_READ_URI_PERMISSION
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod(
        "org/qtproject/qt5/android/bindings/QtActivity",
        "activity",
        "()Landroid/app/Activity;");
    activity.callObjectMethod("startActivity",
        "(Landroid/content/Intent;)V",
        intent.object());

#elif defined(Q_OS_IOS)
    // iOS cannot install directly - open App Store or web page
    QDesktopServices::openUrl(QUrl(FWD_UPDATE_WEB_URL));

#else
    // Fallback: open download page
    QDesktopServices::openUrl(QUrl(FWD_UPDATE_WEB_URL));
#endif
}

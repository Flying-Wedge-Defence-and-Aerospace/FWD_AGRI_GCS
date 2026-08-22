#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>

class FWDUpdateManager : public QObject
{
    Q_OBJECT
public:
    explicit FWDUpdateManager(QObject* parent = nullptr);

    Q_INVOKABLE void checkForUpdates();
    Q_INVOKABLE void downloadUpdate();
    Q_INVOKABLE void installUpdate();

    QString latestVersion() const { return _latestVersion; }
    QString changelog() const { return _changelog; }
    qint64 downloadProgress() const { return _downloadProgress; }
    qint64 downloadTotal() const { return _downloadTotal; }
    bool isDownloading() const { return _isDownloading; }
    bool isUpdateAvailable() const { return _updateAvailable; }

signals:
    void updateAvailable(const QString& version, const QString& changelog);
    void noUpdateAvailable();
    void checkFailed(const QString& error);
    void downloadProgressChanged(qint64 bytesReceived, qint64 bytesTotal);
    void downloadFinished(const QString& filePath);
    void downloadError(const QString& error);
    void installReady(const QString& filePath);

private slots:
    void _onVersionCheckFinished(QNetworkReply* reply);
    void _onDownloadFinished(QNetworkReply* reply);
    void _onDownloadError(QNetworkReply::NetworkError code);
    void _onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);

private:
    bool _parseVersion(const QString& versionString, int& major, int& minor, int& patch);
    QString _currentVersion() const;
    QString _platformAssetName() const;

    QNetworkAccessManager* _networkManager = nullptr;
    QNetworkAccessManager* _downloadManager = nullptr;

    bool    _updateAvailable = false;
    bool    _isDownloading  = false;
    QString _latestVersion;
    QString _changelog;
    QString _downloadUrl;
    QString _downloadFileName;
    QString _downloadedFilePath;
    qint64  _downloadProgress = 0;
    qint64  _downloadTotal    = 0;
};

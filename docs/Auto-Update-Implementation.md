# FWDAgriGCS — In-App Auto-Update System

## Document Information

| Field | Details |
|---|---|
| Project | FWDAgriGCS (Custom QGroundControl Fork) |
| Repository | Flying-Wedge-Defence-AI/FWDAgriGCS |
| Branch | Stable_V2 |
| Platforms | Linux (AppImage), Android (APK) |
| Date | August 2026 |
| Build System | qmake (Qt 5.15.2) |
| Qt Version | 5.15.2 |

---

## 1. Executive Summary

An in-app auto-update system was implemented for FWDAgriGCS that automatically checks for new releases on GitHub when the application starts. If a newer version is available, the user is presented with a dialog showing the version number and changelog. The user can then download and install the update directly from within the application, without needing to manually visit a website or use an app store.

The system supports two platforms:

- **Linux**: Downloads the AppImage and replaces the running binary in-place, then relaunches.
- **Android**: Downloads the APK, copies it to the app cache, and hands off to the Android system package installer via FileProvider.

A release automation script (`release.sh`) was also created to handle version bumping, building, signing, and uploading to GitHub in a single command.

---

## 2. System Architecture

### 2.1 High-Level Flow

```
 App Startup
      |
      v
 QTimer(3000ms)
      |
      v
 checkForUpdates()  ------>  GitHub Releases API
      |                        (GET /releases/latest)
      v
 Parse JSON Response
      |
      v
 Compare: latest > current ?
      |           |
     YES          NO --> "Already up to date"
      |
      v
 Scan assets for platform file (.apk / .AppImage)
      |
      v
 emit updateAvailable(version, changelog)
      |
      v
 QML Update Dialog (showFWDUpdateDialog)
      |
      v
 User taps "Update Now"
      |
      v
 downloadUpdate()  ------>  GitHub Asset API
      |                       (GET /releases/assets/{id})
      |                       Accept: application/octet-stream
      v
 Save to temp/cache directory
      |
      v
 User taps "Restart Now"
      |
      v
 installUpdate()
      |
   +--+--+--+
   |     |     |
  Linux  Win  Android
   |     |     |
   v     v     v
 Replace  Open  FileProvider
 binary   exe   + Intent
 and      in    --> System
 relaunch  Explorer  Installer
```

### 2.2 Component Diagram

```
+----------------------------+     +-----------------------------+
|     QML Layer              |     |      C++ Layer              |
|                            |     |                             |
| MainRootWindow.qml         |     | QGCApplication.cc           |
|  - showFWDUpdateDialog()   |<----|  - _updateManager (member)  |
|  - updateFWDDownloadProg.. |---->|  - Signal/slot connections   |
|  - fwdDownloadComplete()   |     |  - Context property binding  |
|  - fwdDownloadFailed()     |     |                             |
|  - fwdUpdateDialog Popup   |     | FWDUpdateManager.cc         |
|    (inline UI)             |     |  - checkForUpdates()        |
|                            |     |  - downloadUpdate()         |
|                            |     |  - installUpdate()          |
|                            |     |  - _platformAssetName()     |
|                            |     |  - _parseVersion()          |
+----------------------------+     +-----------------------------+
                                              |
                                     HTTPS (PAT token auth)
                                              |
                                     +--------v---------+
                                     | GitHub Releases   |
                                     | API + Assets      |
                                     +------------------+
```

---

## 3. Files Created and Modified

### 3.1 New Files

| File | Purpose |
|---|---|
| `src/FWDUpdateManager/FWDUpdateConfig.h` | GitHub API configuration constants (owner, repo, PAT token, API URL, fallback web URL) |
| `src/FWDUpdateManager/FWDUpdateManager.h` | Update manager C++ class header with Q_INVOKABLE methods and signals |
| `src/FWDUpdateManager/FWDUpdateManager.cc` | Core implementation: version check, download with redirect handling, platform-specific install |
| `src/FWDUpdateManager/FWDUpdateDialog.qml` | Standalone QML dialog component (registered in qgcresources.qrc) |
| `android/res/xml/file_paths.xml` | FileProvider path configuration for sharing APK via content:// URI |
| `release.sh` | One-command release automation: version bump, build, sign, git tag, GitHub upload |

### 3.2 Modified Files

| File | Changes Made |
|---|---|
| `src/QGCApplication.h` | Added `#include "FWDUpdateManager/FWDUpdateManager.h"`, declared `_onFWDUpdate*` slots, added `_updateManager` member pointer |
| `src/QGCApplication.cc` | Created `FWDUpdateManager` in `_initForNormalAppBoot()`, connected 5 signals/slots, registered as QML context property `fwdUpdateManager`, disabled old `_checkForNewVersion()` |
| `src/ui/MainRootWindow.qml` | Added `showFWDUpdateDialog()` function, inline `Popup` with version info, changelog, progress bar, and action buttons; added C++ callback wrapper functions |
| `src/ui/SettingsDrawer.qml` | Added version display label showing `APP_VERSION_STR` |
| `qgroundcontrol.pro` | Added `FWDUpdateManager/FWDUpdateManager.cc` and `.h` to `SOURCES` and `HEADERS` |
| `qgcresources.qrc` | Registered `FWDUpdateDialog.qml` resource |
| `android/AndroidManifest.xml` | Added `<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>` and `<provider>` for `androidx.core.content.FileProvider` |
| `android/build.gradle` | Added `implementation 'androidx.core:core:1.6.0'` dependency for FileProvider |
| `build/.../android-build/gradle.properties` | Added `android.useAndroidX=true` |
| `build/.../android-build/build.gradle` | Added `implementation 'androidx.core:core:1.6.0'` (active build copy) |

---

## 4. Implementation Details

### 4.1 Configuration (FWDUpdateConfig.h)

```cpp
#define FWD_UPDATE_GITHUB_OWNER  "Flying-Wedge-Defence-AI"
#define FWD_UPDATE_GITHUB_REPO   "FWDAgriGCS"
#define FWD_UPDATE_GITHUB_TOKEN  "ghp_..."
#define FWD_UPDATE_API_URL       "https://api.github.com/repos/" FWD_UPDATE_GITHUB_OWNER "/" FWD_UPDATE_GITHUB_REPO "/releases/latest"
#define FWD_UPDATE_WEB_URL       "https://github.com/" FWD_UPDATE_GITHUB_OWNER "/" FWD_UPDATE_GITHUB_REPO "/releases"
```

The GitHub Personal Access Token (PAT) is required because the repository is private. The token grants read access to releases and assets.

### 4.2 Update Check (checkForUpdates)

1. Called 3 seconds after app startup via `QTimer::singleShot(3000, ...)`
2. Makes HTTP GET to GitHub Releases API with `Authorization: token {PAT}` header
3. Parses the JSON response to extract `tag_name` and `body` (changelog)
4. Parses both current version (`APP_VERSION_STR` from `QGCCommon.pri`) and latest version using regex `v?(\d+)\.(\d+)\.(\d+)`
5. Compares using standard semantic versioning (major > minor > patch)
6. If newer version found, scans the `assets` array for a platform-matching filename:
   - `_platformAssetName()` returns `.apk` for Android, `.AppImage` for Linux, `.exe` for Windows, `.ipa` for iOS

**Critical Design Decision**: On Android, `Q_OS_ANDROID` must be checked BEFORE `Q_OS_LINUX` in preprocessor directives because Qt defines both `Q_OS_LINUX` and `Q_OS_ANDROID` when building for Android (Android is Linux-based). This was a bug discovered and fixed during testing.

### 4.3 Download (downloadUpdate)

1. For private repos, uses the asset `url` field (API endpoint) instead of `browser_download_url`
2. Sets `Accept: application/octet-stream` header for the asset API
3. Follows HTTP redirects (GitHub releases redirect to Azure CDN)
4. Handles redirect chain: `api.github.com` -> `objects.githubusercontent.com` -> `release-assets.githubusercontent.com`
5. Saves file to system temp directory with the original filename
6. Emits `downloadFinished(filePath)` signal on success

### 4.4 Update Dialog (MainRootWindow.qml)

The dialog is implemented as an inline `Popup` overlay:

- **Responsive sizing**: Width capped at `min(60em, 85% screen)`, height capped at `min(contentHeight, 85% screen)`
- **Changelog area**: Uses `Flickable` with `Layout.fillHeight: true` so it scrolls within available space instead of pushing buttons off-screen
- **Progress bar**: Shows percentage during download
- **State machine**:
  - Initial: Shows "Update Available" + version + changelog + "Later" + "Update Now" buttons
  - Downloading: Shows progress bar + "Cancel" button
  - Download complete: Shows "download_complete" status + "Restart Now" button
  - Error: Shows error message in red

### 4.5 Linux Installation (installUpdate)

```
1. Get real binary path:
   - Try $APPIMAGE environment variable (AppImage sets this)
   - Fall back to QCoreApplication::applicationFilePath()

2. Delete current binary:
   - QFile::remove(currentBinPath)
   - Shows error dialog if permission denied

3. Copy downloaded update:
   - QFile::copy(_downloadedFilePath, currentBinPath)

4. Set executable permission:
   - QProcess::startDetached("chmod", {"+x", currentBinPath})

5. Relaunch:
   - QProcess::startDetached(currentBinPath, QStringList())

6. Quit current instance:
   - QApplication::quit()
```

**OpenSSL Bundling**: The Linux AppImage bundles `libcrypto.so.1.1` and `libssl.so.1.1` in `AppDir/Qt/libs/` to ensure HTTPS connectivity for GitHub API calls.

### 4.6 Android Installation (installUpdate)

```
1. Copy APK to app's cache directory:
   - CacheLocation = /data/user/0/com.fwd.agri.gcs/cache/
   - Destination: CacheLocation/FWDUpdate.apk

2. Get Activity reference via JNI:
   - QAndroidJniObject::callStaticObjectMethod(
       "org/qtproject/qt5/android/QtNative",
       "activity", "()Landroid/app/Activity;")

3. Get content:// URI via FileProvider:
   - androidx.core.content.FileProvider.getUriForFile(
       activity,
       "com.fwd.agri.gcs.fileprovider",
       javaFile)

4. Create install Intent:
   - Action: ACTION_VIEW
   - Data: content:// URI from FileProvider
   - Type: "application/vnd.android.package-archive"
   - Flags: FLAG_GRANT_READ_URI_PERMISSION | FLAG_ACTIVITY_NEW_TASK

5. Launch system installer:
   - activity.startActivity(intent)

6. Quit current instance:
   - QApplication::quit()
```

**JNI Fix**: The initial implementation used `org.qtproject.qt5.android.bindings.QtActivity` to get the activity reference, which caused a `NoSuchMethodError` crash. This was fixed to use `org.qtproject.qt5.android.QtNative` which is the correct Qt 5.15 JNI bridge class.

### 4.7 Android Manifest Configuration

**Permissions added:**
```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
```

**FileProvider declaration:**
```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="com.fwd.agri.gcs.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths"/>
</provider>
```

**FileProvider paths (file_paths.xml):**
```xml
<paths>
    <cache-path name="apks" path="."/>
    <external-files-path name="updates" path="."/>
</paths>
```

**AndroidX dependency (build.gradle):**
```gradle
implementation 'androidx.core:core:1.6.0'
```

**Gradle properties:**
```properties
android.useAndroidX=true
android.enableJetifier=false
```

---

## 5. Release Automation Script (release.sh)

### 5.1 Usage

```bash
./release.sh <patch|minor|major|vX.Y.Z> [--linux-only|--android-only]
```

**Examples:**
```bash
./release.sh patch                  # v1.0.5 -> v1.0.6, build both platforms
./release.sh patch --android-only   # v1.0.5 -> v1.0.6, Android APK only
./release.sh v1.2.0 --linux-only    # Set exact version, Linux only
```

### 5.2 What the Script Does

1. **Checks for uncommitted changes** (aborts if dirty working tree)
2. **Determines new version** from bump type or exact version string
3. **Updates `QGCCommon.pri`** with new `APP_VERSION_STR`
4. **Builds the application** (Linux and/or Android)
5. **Android-specific**:
   - Patches `AndroidManifest.xml` with correct `versionName` and computed `versionCode`
   - Format: `BBMIPPDDD` (BB=66/arm64, M=major, I=minor, PP=patch, DDD=dev)
   - Fixes deployment settings to `arm64-v8a` only
   - Builds with `androiddeployqt --android-platform android-29`
   - Signs APK with debug keystore using `apksigner.jar`
6. **Linux-specific**:
   - Creates AppImage with bundled OpenSSL 1.1 libraries
7. **Git operations**: Commits version change, creates annotated tag, pushes to `Stable_V2`
8. **GitHub release**: Creates release via API, uploads APK/AppImage as assets

### 5.3 Android versionCode Calculation

```
versionCode = 66 * 10000000 + major * 1000000 + minor * 100000 + patch * 1000 + dev

Example: v1.0.10
= 66 * 10000000 + 1 * 1000000 + 0 * 100000 + 10 * 1000 + 0
= 661010000
```

The `66` prefix is the Android bitness code for `arm64-v8a`.

---

## 6. Bugs Found and Fixed During Development

| # | Bug | Root Cause | Fix |
|---|---|---|---|
| 1 | `_platformAssetName()` returned `.AppImage` on Android | Qt defines both `Q_OS_LINUX` and `Q_OS_ANDROID` on Android; `Q_OS_LINUX` was checked first in `#elif` chain | Reordered preprocessor: `Q_OS_ANDROID` before `Q_OS_LINUX` in both `_platformAssetName()` and `installUpdate()` |
| 2 | `installUpdate()` ran Linux code path on Android | Same preprocessor ordering issue | Same fix as above |
| 3 | JNI crash: `NoSuchMethodError: QtActivity.activity()` | Used wrong JNI class `org.qtproject.qt5.android.bindings.QtActivity` | Changed to `org.qtproject.qt5.android.QtNative` |
| 4 | APK always showed `v1.0.5` regardless of release version | `release.sh` patched Makefile via sed but `androiddeployqt` regenerated `AndroidManifest.xml` from source | Script now patches source `android/AndroidManifest.xml` before `androiddeployqt` runs, restores after |
| 5 | `versionCode` exceeded Android max (2^31-1) | Extra zero in multiplier: `66 * 100000000` instead of `66 * 10000000` | Fixed multiplier from `100000000` to `10000000` |
| 6 | Private repo assets: `browser_download_url` returns 404 | GitHub returns 404 for private repo asset download URLs | Use `url` field (API endpoint) with `Accept: application/octet-stream` header |
| 7 | Update dialog buttons off-screen on small devices | Popup height was unconstrained (`mainColumn.height + padding * 2`) | Capped height at `min(contentHeight, 85% screen height)`, made changelog Flickable fill available space |
| 8 | APK install failed (signature mismatch) | Original APK signed with release keystore; new APK signed with debug keystore | Must uninstall first when switching signing keys; subsequent updates use same debug key |

---

## 7. Security Considerations

- **GitHub PAT Token**: Embedded in `FWDUpdateConfig.h`. This is a read-only token scoped to the repository. For production, consider storing it in a more secure location or using a backend proxy.
- **APK Signing**: Current implementation uses debug keystore. For production release, a dedicated release signing key should be used.
- **HTTPS Only**: All API calls use HTTPS. The asset download follows GitHub's signed redirect URLs with expiration tokens.
- **FileProvider**: Android `content://` URIs are used instead of `file://` paths, following Android security best practices (required since Android 7.0).

---

## 8. Testing Results

| Test Case | Platform | Result |
|---|---|---|
| Update detection (newer version on GitHub) | Both | PASS |
| Update detection (same version - no update) | Both | PASS |
| Platform asset matching (.apk on Android) | Android | PASS |
| Platform asset matching (.AppImage on Linux) | Linux | PASS |
| Download with progress reporting | Both | PASS |
| Download redirect following | Both | PASS |
| Download error handling (network abort) | Android | PASS - auto-retry |
| FileProvider content:// URI generation | Android | PASS |
| System package installer launch | Android | PASS |
| APK installation (same signing key) | Android | PASS |
| Dialog fits on small screen (< 5 inch) | Android | PASS |
| Version display in Settings Drawer | Both | PASS |
| release.sh: version bump + build + upload | Both | PASS |
| release.sh: AndroidManifest versionCode | Android | PASS |

---

## 9. Future Improvements

1. **Auto-relaunch after Android install**: Add a `BroadcastReceiver` for `ACTION_MY_PACKAGE_REPLACED` to automatically relaunch the app after the system installer completes.
2. **Release signing key**: Replace debug keystore with a dedicated release keystore for production APKs.
3. **Token security**: Move GitHub PAT to a backend proxy service instead of embedding in the binary.
4. **Differential updates**: Implement delta/diff patching to reduce download size for incremental updates.
5. **Scheduled checks**: Add option for periodic background update checks (currently only checks on startup).
6. **Download resume**: Support resuming interrupted downloads using HTTP Range headers.

---

## 10. Summary of All Commits

| Commit Message | Description |
|---|---|
| FWD Update Manager init | Created FWDUpdateConfig.h, FWDUpdateManager.h/.cc |
| Add update dialog to MainRootWindow | Inline Popup UI with progress bar |
| Add version display to SettingsDrawer | Shows current version in settings |
| Add FileProvider for Android APK install | AndroidManifest.xml, file_paths.xml |
| Fix AndroidX FileProvider class | Switched from support lib to androidx.core |
| Add APK signing to release.sh | Debug keystore signing in release script |
| Fix _platformAssetName preprocessor order | Q_OS_ANDROID before Q_OS_LINUX |
| Fix installUpdate preprocessor order | Same fix for installUpdate method |
| Fix JNI crash QtNative.activity() | Changed from QtActivity to QtNative |
| Fix AndroidManifest version patching | Patch source manifest before androiddeployqt |
| Fix versionCode multiplier | 10000000 not 100000000 |
| Fix update dialog small screen overflow | Cap height 85%, scrollable changelog |

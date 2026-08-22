#!/bin/bash
set -e

# ---- Configuration ----
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$REPO_DIR/build/Desktop_Qt_5_15_2_GCC_64bit-Release"
QT_DIR="/home/fwd/Qt/5.15.2/gcc_64"
ANDROID_QT_DIR="/home/fwd/Qt/5.15.2/android"
ANDROID_BUILD_DIR="$REPO_DIR/build/Android_Qt_5_15_2_Clang_Multi_Abi-Release"
BRANCH="Stable_V2"
PRI_FILE="$REPO_DIR/QGCCommon.pri"
GITHUB_OWNER="Flying-Wedge-Defence-AI"
GITHUB_REPO="FWDAgriGCS"
PYTHON=$(command -v python3.9 2>/dev/null || echo "/usr/bin/python3.9")

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ---- Platform flags ----
BUILD_LINUX=true
BUILD_ANDROID=true

# ---- Usage ----
usage() {
    echo "Usage: $0 <patch|minor|major|vX.Y.Z> [--linux-only|--android-only]"
    echo ""
    echo "Options:"
    echo "  patch          Bump patch version (e.g., v1.0.2 -> v1.0.3)"
    echo "  minor          Bump minor version (e.g., v1.0.2 -> v1.1.0)"
    echo "  major          Bump major version (e.g., v1.0.2 -> v2.0.0)"
    echo "  vX.Y.Z         Set exact version"
    echo "  --linux-only   Build Linux AppImage only"
    echo "  --android-only Build Android APK only"
    echo ""
    echo "Examples:"
    echo "  $0 patch                  # Build both Linux + Android"
    echo "  $0 patch --linux-only     # Linux AppImage only"
    echo "  $0 patch --android-only   # Android APK only"
    echo "  $0 v1.0.5 --linux-only    # Exact version, Linux only"
    exit 1
}

# ---- Check arguments ----
if [ $# -lt 1 ]; then
    usage
fi

# Parse arguments: first non-flag arg is bump type, flags set platform
BUMP_TYPE=""
for arg in "$@"; do
    case "$arg" in
        --linux-only)
            BUILD_ANDROID=false
            ;;
        --android-only)
            BUILD_LINUX=false
            ;;
        *)
            if [ -z "$BUMP_TYPE" ]; then
                BUMP_TYPE="$arg"
            else
                echo -e "${RED}Error: Unknown argument '$arg'${NC}"
                usage
            fi
            ;;
    esac
done

if [ -z "$BUMP_TYPE" ]; then
    echo -e "${RED}Error: No version specified${NC}"
    usage
fi

echo -e "${YELLOW}Build targets: Linux=$BUILD_LINUX, Android=$BUILD_ANDROID${NC}"

# ---- Check for uncommitted changes ----
cd "$REPO_DIR"
if ! git diff --quiet HEAD 2>/dev/null; then
    echo -e "${RED}Error: You have uncommitted changes. Commit or stash them first.${NC}"
    exit 1
fi

# ---- Get current version from last git tag ----
CURRENT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$CURRENT_TAG" ]; then
    CURRENT_TAG=$(grep 'APP_VERSION_STR' "$PRI_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')
fi
if [ -z "$CURRENT_TAG" ]; then
    CURRENT_TAG="v0.0.0"
fi

echo -e "${YELLOW}Current version: $CURRENT_TAG${NC}"

# ---- Determine new version ----
if [[ "$BUMP_TYPE" == v* ]]; then
    if [[ ! "$BUMP_TYPE" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}Error: Invalid version format '$BUMP_TYPE' (expected v1.2.3)${NC}"
        exit 1
    fi
    NEW_VERSION="$BUMP_TYPE"
else
    if [[ "$BUMP_TYPE" != "patch" && "$BUMP_TYPE" != "minor" && "$BUMP_TYPE" != "major" ]]; then
        echo -e "${RED}Error: Invalid argument '$BUMP_TYPE'${NC}"
        usage
    fi
    VERSION=${CURRENT_TAG#v}
    IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
    MAJOR=${MAJOR:-0}; MINOR=${MINOR:-0}; PATCH=${PATCH:-0}
    case "$BUMP_TYPE" in
        major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
        minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
        patch) PATCH=$((PATCH + 1)) ;;
    esac
    NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
fi

echo -e "${GREEN}New version: $NEW_VERSION${NC}"

# ---- Check if GitHub release already exists ----
PAT_TOKEN=$(grep 'FWD_UPDATE_GITHUB_TOKEN' "$REPO_DIR/src/FWDUpdateManager/FWDUpdateConfig.h" | sed 's/.*"\(.*\)".*/\1/')
if [ -z "$PAT_TOKEN" ]; then
    echo -e "${RED}Error: Could not read GitHub token from FWDUpdateConfig.h${NC}"
    exit 1
fi

EXISTING_HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $PAT_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/tags/$NEW_VERSION")

if [ "$EXISTING_HTTP_CODE" = "200" ]; then
    echo -e "${YELLOW}GitHub release $NEW_VERSION already exists. Deleting and recreating...${NC}"
    RELEASE_ID=$(curl -s -H "Authorization: token $PAT_TOKEN" -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/tags/$NEW_VERSION" | \
        $PYTHON -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
    if [ -n "$RELEASE_ID" ]; then
        curl -s -X DELETE -H "Authorization: token $PAT_TOKEN" \
            "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/$RELEASE_ID" > /dev/null
        echo -e "${GREEN}Deleted old release.${NC}"
    fi
fi

# ---- Update QGCCommon.pri ----
echo "Updating version in QGCCommon.pri..."
sed -i "s/APP_VERSION_STR = \".*\"/APP_VERSION_STR = \"$NEW_VERSION\"/" "$PRI_FILE"

# ---- Verify the change ----
if ! grep -q "APP_VERSION_STR = \"$NEW_VERSION\"" "$PRI_FILE"; then
    echo -e "${RED}Error: Failed to update version in QGCCommon.pri${NC}"
    git checkout "$PRI_FILE"
    exit 1
fi

# Touch source files that use APP_VERSION_STR to force recompile
touch "$REPO_DIR/src/QGCApplication.cc"
touch "$REPO_DIR/src/FWDUpdateManager/FWDUpdateManager.cc"

OUTPUT_DIR="$BUILD_DIR/staging"
APK_NAME="FWDAgriGCS-${NEW_VERSION}.apk"
APPIMAGE_NAME="FWDAgriGCS-${NEW_VERSION}.AppImage"

# ---- Build Linux ----
if [ "$BUILD_LINUX" = true ]; then
    echo -e "${YELLOW}Building Linux $NEW_VERSION...${NC}"
    cd "$BUILD_DIR"

    "$QT_DIR/bin/qmake" "$REPO_DIR/qgroundcontrol.pro" -r
    make -j$(nproc)

    if [ ! -f "$OUTPUT_DIR/FWD_AGRI_GCS" ]; then
        echo -e "${RED}Error: Linux binary not found at $OUTPUT_DIR/FWD_AGRI_GCS${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Creating AppImage...${NC}"
    APPDIR="$OUTPUT_DIR/AppDir"

    cp "$OUTPUT_DIR/FWD_AGRI_GCS" "$APPDIR/"

    cp /lib/x86_64-linux-gnu/libcrypto.so.1.1 "$APPDIR/Qt/libs/"
    cp /lib/x86_64-linux-gnu/libssl.so.1.1 "$APPDIR/Qt/libs/"

    rm -f "$OUTPUT_DIR"/*.AppImage

    cd "$OUTPUT_DIR"
    /home/fwd/appimagetool-x86_64.AppImage AppDir "$APPIMAGE_NAME"

    if [ ! -f "$OUTPUT_DIR/$APPIMAGE_NAME" ]; then
        echo -e "${RED}Error: AppImage creation failed${NC}"
        exit 1
    fi

    echo -e "${GREEN}AppImage: $OUTPUT_DIR/$APPIMAGE_NAME${NC}"
fi

# ---- Build Android ----
if [ "$BUILD_ANDROID" = true ]; then
    echo -e "${YELLOW}Building Android $NEW_VERSION...${NC}"

    if [ ! -d "$ANDROID_BUILD_DIR" ]; then
        echo -e "${RED}Error: Android build directory not found at $ANDROID_BUILD_DIR${NC}"
        echo -e "${YELLOW}Run Qt Creator with Android kit once to set up the build directory.${NC}"
        exit 1
    fi

    export ANDROID_NDK_ROOT="/home/fwd/Android/Sdk/ndk/21.3.6528147"
    export ANDROID_SDK_ROOT="/home/fwd/Android/Sdk"

    cd "$ANDROID_BUILD_DIR"

    # Update version define in existing Makefiles (skip qmake — it may reconfigure unsupported architectures)
    find "$ANDROID_BUILD_DIR" -name "Makefile" -exec sed -i "s/APP_VERSION_STR=\"\\\\\"[^\"]*\\\\\"\"/APP_VERSION_STR=\"\\\\\"$NEW_VERSION\\\\\"\"/g" {} +

    # Update AndroidManifest.xml versionName and versionCode
    # versionCode format: BBMIPPDDD (BB=66/arm64, M=major, I=minor, PP=patch, DDD=dev)
    ANDROID_MANIFEST="$ANDROID_BUILD_DIR/android-build/AndroidManifest.xml"
    if [ -f "$ANDROID_MANIFEST" ]; then
        $PYTHON -c "
import re
new_version = '$NEW_VERSION'
m = re.match(r'v?(\d+)\.(\d+)\.(\d+)', new_version)
major, minor, patch = int(m.group(1)), int(m.group(2)), int(m.group(3))
version_code = 66 * 100000000 + major * 10000000 + minor * 1000000 + patch * 10000 + 0
with open('$ANDROID_MANIFEST', 'r') as f:
    content = f.read()
content = re.sub(r'android:versionName=\"[^\"]*\"', f'android:versionName=\"$NEW_VERSION\"', content)
content = re.sub(r'android:versionCode=\"[^\"]*\"', f'android:versionCode=\"{version_code}\"', content)
with open('$ANDROID_MANIFEST', 'w') as f:
    f.write(content)
print(f'AndroidManifest: versionName={new_version}, versionCode={version_code}')
"
    fi

    # Fix deployment settings to only include arm64-v8a (the architecture that was actually compiled)
    $PYTHON -c "
import json
with open('$ANDROID_BUILD_DIR/android-FWD_AGRI_GCS-deployment-settings.json', 'r') as f:
    data = json.load(f)
data['architectures'] = {'arm64-v8a': 'aarch64-linux-android'}
data['qrcFiles'] = [q for q in data['qrcFiles'] if '/x86/' not in q and '/x86_64/' not in q and '/armeabi-v7a/' not in q]
with open('$ANDROID_BUILD_DIR/android-FWD_AGRI_GCS-deployment-settings.json', 'w') as f:
    json.dump(data, f, indent=3)
"

    make -j$(nproc)

    # Run install + androiddeployqt directly with correct platform (make apk defaults to android-35 which is incompatible)
    make -f "$ANDROID_BUILD_DIR/Makefile" INSTALL_ROOT="$ANDROID_BUILD_DIR/android-build" install
    "$ANDROID_QT_DIR/bin/androiddeployqt" \
        --input "$ANDROID_BUILD_DIR/android-FWD_AGRI_GCS-deployment-settings.json" \
        --output "$ANDROID_BUILD_DIR/android-build" \
        --apk "$ANDROID_BUILD_DIR/android-build/FWD_AGRI_GCS.apk" \
        --android-platform android-29 \
        --release

    APK_OUTPUT=""
    for CANDIDATE in \
        "$ANDROID_BUILD_DIR/android-build/build/outputs/apk/release/android-build-release-signed.apk" \
        "$ANDROID_BUILD_DIR/android-build/build/outputs/apk/release/android-build-release-unsigned.apk" \
        "$ANDROID_BUILD_DIR/android-build/build/outputs/apk/release/FWD_AGRI_GCS_V2.apk" \
        "$ANDROID_BUILD_DIR/android-build/build/outputs/apk/debug/android-build-debug.apk" \
        "$OUTPUT_DIR/$APK_NAME"; do
        if [ -f "$CANDIDATE" ]; then
            APK_OUTPUT="$CANDIDATE"
            break
        fi
    done

    if [ -z "$APK_OUTPUT" ]; then
        echo -e "${RED}Error: Android APK not found after build${NC}"
        exit 1
    fi

    cp "$APK_OUTPUT" "$OUTPUT_DIR/$APK_NAME"

    # Sign the APK with debug keystore (required for Android install)
    DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
    if [ -f "$DEBUG_KEYSTORE" ]; then
        echo -e "${YELLOW}Signing APK with debug keystore...${NC}"
        BUILD_TOOLS=$(ls -d /home/fwd/Android/Sdk/build-tools/*/ 2>/dev/null | sort -V | tail -1)
        if [ -n "$BUILD_TOOLS" ] && [ -f "${BUILD_TOOLS}lib/apksigner.jar" ]; then
            /usr/bin/java -jar "${BUILD_TOOLS}lib/apksigner.jar" sign \
                --ks "$DEBUG_KEYSTORE" \
                --ks-pass pass:android \
                --key-pass pass:android \
                "$OUTPUT_DIR/$APK_NAME"
            echo -e "${GREEN}APK signed successfully${NC}"
        else
            echo -e "${YELLOW}Warning: apksigner.jar not found, APK left unsigned${NC}"
        fi
    fi

    echo -e "${GREEN}APK: $OUTPUT_DIR/$APK_NAME${NC}"
fi

# ---- Git commit + tag + push ----
echo -e "${YELLOW}Creating git commit and tag $NEW_VERSION...${NC}"
cd "$REPO_DIR"
git add QGCCommon.pri
git commit -m "Release $NEW_VERSION" --allow-empty

if ! git rev-parse "$NEW_VERSION" >/dev/null 2>&1; then
    git tag -a "$NEW_VERSION" -m "Version ${NEW_VERSION#v}"
else
    echo -e "${YELLOW}Tag $NEW_VERSION already exists, skipping tag creation.${NC}"
fi
git push origin "$BRANCH" --tags

# ---- Create GitHub Release ----
echo -e "${YELLOW}Creating GitHub Release...${NC}"

RELEASE_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Authorization: token $PAT_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases" \
    -d "{
        \"tag_name\": \"$NEW_VERSION\",
        \"name\": \"$NEW_VERSION\",
        \"body\": \"Release $NEW_VERSION\",
        \"draft\": false,
        \"prerelease\": false
    }")

HTTP_CODE=$(echo "$RELEASE_RESPONSE" | tail -1)
RELEASE_BODY=$(echo "$RELEASE_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" != "201" ]; then
    echo -e "${RED}Error: Failed to create GitHub release (HTTP $HTTP_CODE)${NC}"
    echo "$RELEASE_BODY"
    exit 1
fi

RELEASE_ID=$(echo "$RELEASE_BODY" | $PYTHON -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
echo -e "${GREEN}GitHub Release created (ID: $RELEASE_ID)${NC}"

UPLOAD_URL=$(echo "$RELEASE_BODY" | $PYTHON -c "import sys,json; print(json.load(sys.stdin)['upload_url'].replace('{?name,label}',''))" 2>/dev/null)

upload_asset() {
    local FILE_PATH="$1"
    local ASSET_NAME="$2"
    local FILE_SIZE
    local UPLOAD_RESPONSE
    local UPLOAD_HTTP_CODE

    FILE_SIZE=$(stat -c%s "$FILE_PATH")
    UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: token $PAT_TOKEN" \
        -H "Content-Type: application/octet-stream" \
        -H "Content-Length: $FILE_SIZE" \
        "$UPLOAD_URL?name=$ASSET_NAME" \
        --data-binary @"$FILE_PATH")

    UPLOAD_HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -1)

    if [ "$UPLOAD_HTTP_CODE" != "201" ]; then
        echo -e "${RED}Error: Failed to upload $ASSET_NAME (HTTP $UPLOAD_HTTP_CODE)${NC}"
        return 1
    else
        echo -e "${GREEN}$ASSET_NAME uploaded successfully${NC}"
        return 0
    fi
}

# ---- Upload assets ----
if [ "$BUILD_LINUX" = true ] && [ -f "$OUTPUT_DIR/$APPIMAGE_NAME" ]; then
    upload_asset "$OUTPUT_DIR/$APPIMAGE_NAME" "$APPIMAGE_NAME"
fi

if [ "$BUILD_ANDROID" = true ] && [ -f "$OUTPUT_DIR/$APK_NAME" ]; then
    upload_asset "$OUTPUT_DIR/$APK_NAME" "$APK_NAME"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Release $NEW_VERSION complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "  GitHub: https://github.com/$GITHUB_OWNER/$GITHUB_REPO/releases/tag/$NEW_VERSION"
echo ""
echo -e "  Users running older versions will auto-update."

#!/bin/bash
set -e

# ---- Configuration ----
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$REPO_DIR/build/Desktop_Qt_5_15_2_GCC_64bit-Release"
QT_DIR="/home/fwd/Qt/5.15.2/gcc_64"
BRANCH="Stable_V2"
PRI_FILE="$REPO_DIR/QGCCommon.pri"
GITHUB_OWNER="Flying-Wedge-Defence-AI"
GITHUB_REPO="FWDAgriGCS"

# ---- Colors ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ---- Usage ----
usage() {
    echo "Usage: $0 <patch|minor|major|vX.Y.Z>"
    echo ""
    echo "Examples:"
    echo "  $0 patch    # v1.0.2 -> v1.0.3"
    echo "  $0 minor    # v1.0.2 -> v1.1.0"
    echo "  $0 major    # v1.0.2 -> v2.0.0"
    echo "  $0 v1.0.3   # set exact version (recreate release if deleted)"
    exit 1
}

# ---- Check arguments ----
if [ $# -ne 1 ]; then
    usage
fi

BUMP_TYPE=$1

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
    # Exact version provided (e.g., v1.0.3)
    if [[ ! "$BUMP_TYPE" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}Error: Invalid version format '$BUMP_TYPE' (expected v1.2.3)${NC}"
        exit 1
    fi
    NEW_VERSION="$BUMP_TYPE"
else
    # Auto-bump
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
        python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
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

# ---- Build ----
echo -e "${YELLOW}Building $NEW_VERSION...${NC}"
cd "$BUILD_DIR"

# Touch source files that use APP_VERSION_STR to force recompile
touch "$REPO_DIR/src/QGCApplication.cc"
touch "$REPO_DIR/src/FWDUpdateManager/FWDUpdateManager.cc"

"$QT_DIR/bin/qmake" "$REPO_DIR/qgroundcontrol.pro" -r
make -j$(nproc)

# ---- Verify binary ----
BINARY="$BUILD_DIR/staging/FWD_AGRI_GCS"
if [ ! -f "$BINARY" ]; then
    echo -e "${RED}Error: Binary not found at $BINARY${NC}"
    exit 1
fi

# ---- Create AppImage ----
echo -e "${YELLOW}Creating AppImage...${NC}"
OUTPUT_DIR="$BUILD_DIR/staging"
APPDIR="$OUTPUT_DIR/AppDir"
APPIMAGE_NAME="FWDAgriGCS-${NEW_VERSION}.AppImage"

# Copy freshly built binary into AppDir
cp "$OUTPUT_DIR/FWD_AGRI_GCS" "$APPDIR/"

# Bundle OpenSSL 1.1 (required by Qt networking, not available on Ubuntu 22.04+)
cp /lib/x86_64-linux-gnu/libcrypto.so.1.1 "$APPDIR/Qt/libs/"
cp /lib/x86_64-linux-gnu/libssl.so.1.1 "$APPDIR/Qt/libs/"

# Remove old AppImage if exists
rm -f "$OUTPUT_DIR"/*.AppImage

# Create new AppImage
cd "$OUTPUT_DIR"
/home/fwd/appimagetool-x86_64.AppImage AppDir "$APPIMAGE_NAME"

if [ ! -f "$OUTPUT_DIR/$APPIMAGE_NAME" ]; then
    echo -e "${RED}Error: AppImage creation failed${NC}"
    exit 1
fi

echo -e "${GREEN}AppImage: $OUTPUT_DIR/$APPIMAGE_NAME${NC}"

# ---- Git commit + tag + push ----
echo -e "${YELLOW}Creating git commit and tag $NEW_VERSION...${NC}"
cd "$REPO_DIR"
git add QGCCommon.pri
git commit -m "Release $NEW_VERSION" --allow-empty

# Create tag only if it doesn't exist
if ! git rev-parse "$NEW_VERSION" >/dev/null 2>&1; then
    git tag -a "$NEW_VERSION" -m "Version ${NEW_VERSION#v}"
else
    echo -e "${YELLOW}Tag $NEW_VERSION already exists, skipping tag creation.${NC}"
fi
git push origin "$BRANCH" --tags

# ---- Create GitHub Release + upload AppImage ----
echo -e "${YELLOW}Creating GitHub Release...${NC}"

# Create release
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

RELEASE_ID=$(echo "$RELEASE_BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
echo -e "${GREEN}GitHub Release created (ID: $RELEASE_ID)${NC}"

# Upload AppImage asset
echo -e "${YELLOW}Uploading AppImage to GitHub Release...${NC}"

# Get upload URL from release
UPLOAD_URL=$(echo "$RELEASE_BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['upload_url'].replace('{?name,label}',''))" 2>/dev/null)

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

upload_asset "$OUTPUT_DIR/$APPIMAGE_NAME" "$APPIMAGE_NAME"

# Upload APK if it exists
APK_NAME="FWDAgriGCS-${NEW_VERSION}.apk"
# Check common Android build output locations
APK_SOURCE=""
for CANDIDATE in \
    "$REPO_DIR/build-android/release/outputs/apk/release/release.apk" \
    "$REPO_DIR/build-android/FWDAgriGCS.apk" \
    "$REPO_DIR/build-android/output/FWDAgriGCS.apk" \
    "$OUTPUT_DIR/$APK_NAME"; do
    if [ -f "$CANDIDATE" ]; then
        APK_SOURCE="$CANDIDATE"
        break
    fi
done

if [ -n "$APK_SOURCE" ]; then
    echo -e "${YELLOW}Uploading APK to GitHub Release...${NC}"
    cp "$APK_SOURCE" "$OUTPUT_DIR/$APK_NAME"
    upload_asset "$OUTPUT_DIR/$APK_NAME" "$APK_NAME"
else
    echo -e "${YELLOW}No APK found. Skipping APK upload.${NC}"
    echo -e "${YELLOW}To include APK, build with Android kit first, then place it at:${NC}"
    echo -e "  $REPO_DIR/build-android/release/outputs/apk/release/release.apk"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Release $NEW_VERSION complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "  AppImage: $OUTPUT_DIR/$APPIMAGE_NAME"
echo -e "  APK:      ${APK_SOURCE:-Not built}"
echo -e "  GitHub:   https://github.com/$GITHUB_OWNER/$GITHUB_REPO/releases/tag/$NEW_VERSION"
echo ""
echo -e "  Users running older versions will auto-update."

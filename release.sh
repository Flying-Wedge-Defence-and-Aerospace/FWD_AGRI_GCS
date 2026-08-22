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
    echo "Usage: $0 <patch|minor|major>"
    echo ""
    echo "Examples:"
    echo "  $0 patch    # v1.0.2 -> v1.0.3"
    echo "  $0 minor    # v1.0.2 -> v1.1.0"
    echo "  $0 major    # v1.0.2 -> v2.0.0"
    exit 1
}

# ---- Check arguments ----
if [ $# -ne 1 ]; then
    usage
fi

BUMP_TYPE=$1
if [[ "$BUMP_TYPE" != "patch" && "$BUMP_TYPE" != "minor" && "$BUMP_TYPE" != "major" ]]; then
    echo -e "${RED}Error: Invalid bump type '$BUMP_TYPE'${NC}"
    usage
fi

cd "$REPO_DIR"

# ---- Check for uncommitted changes ----
if ! git diff --quiet HEAD 2>/dev/null; then
    echo -e "${RED}Error: You have uncommitted changes. Commit or stash them first.${NC}"
    exit 1
fi

# ---- Get current version from last git tag ----
CURRENT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$CURRENT_TAG" ]; then
    # No tags yet, read from QGCCommon.pri
    CURRENT_TAG=$(grep 'APP_VERSION_STR' "$PRI_FILE" | head -1 | sed 's/.*"\(.*\)".*/\1/')
fi

if [ -z "$CURRENT_TAG" ]; then
    CURRENT_TAG="v0.0.0"
fi

echo -e "${YELLOW}Current version: $CURRENT_TAG${NC}"

# ---- Parse version ----
VERSION=${CURRENT_TAG#v}
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}

# ---- Bump version ----
case "$BUMP_TYPE" in
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
echo -e "${GREEN}New version: $NEW_VERSION${NC}"

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
"$QT_DIR/bin/qmake" "$REPO_DIR/qgroundcontrol.pro" -r
make -j$(nproc)

# ---- Verify binary ----
BINARY="$BUILD_DIR/staging/FWD_AGRI_GCS"
if [ ! -f "$BINARY" ]; then
    echo -e "${RED}Error: Binary not found at $BINARY${NC}"
    exit 1
fi

# ---- Find AppImage ----
# The build process (Post Link Common) already creates the AppImage in staging
OUTPUT_DIR="$BUILD_DIR/staging"
APPIMAGE_NAME="FWDAgriGCS-${NEW_VERSION}.AppImage"

# Find the AppImage created by the build (may have various names)
APPIMAGE_SRC=""
for f in "$OUTPUT_DIR"/*.AppImage; do
    if [ -f "$f" ]; then
        APPIMAGE_SRC="$f"
        break
    fi
done

if [ -z "$APPIMAGE_SRC" ]; then
    echo -e "${RED}Error: No AppImage found in $OUTPUT_DIR${NC}"
    echo "Make sure the build completed successfully."
    exit 1
fi

# Rename to versioned name
mv "$APPIMAGE_SRC" "$OUTPUT_DIR/$APPIMAGE_NAME"
echo -e "${GREEN}AppImage: $OUTPUT_DIR/$APPIMAGE_NAME${NC}"

# ---- Git commit + tag + push ----
echo -e "${YELLOW}Creating git commit and tag $NEW_VERSION...${NC}"
cd "$REPO_DIR"
git add QGCCommon.pri
git commit -m "Release $NEW_VERSION"
git tag -a "$NEW_VERSION" -m "Version ${MAJOR}.${MINOR}.${PATCH}"
git push origin "$BRANCH" --tags

# ---- Create GitHub Release + upload AppImage ----
echo -e "${YELLOW}Creating GitHub Release...${NC}"

# Read PAT token from FWDUpdateConfig.h
PAT_TOKEN=$(grep 'FWD_UPDATE_GITHUB_TOKEN' "$REPO_DIR/src/FWDUpdateManager/FWDUpdateConfig.h" | sed 's/.*"\(.*\)".*/\1/')

if [ -z "$PAT_TOKEN" ]; then
    echo -e "${RED}Error: Could not read GitHub token from FWDUpdateConfig.h${NC}"
    exit 1
fi

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

FILE_SIZE=$(stat -c%s "$OUTPUT_DIR/$APPIMAGE_NAME")
UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Authorization: token $PAT_TOKEN" \
    -H "Content-Type: application/octet-stream" \
    -H "Content-Length: $FILE_SIZE" \
    "$UPLOAD_URL?name=$APPIMAGE_NAME" \
    --data-binary @"$OUTPUT_DIR/$APPIMAGE_NAME")

UPLOAD_HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -1)

if [ "$UPLOAD_HTTP_CODE" != "201" ]; then
    echo -e "${RED}Error: Failed to upload AppImage (HTTP $UPLOAD_HTTP_CODE)${NC}"
    echo -e "${YELLOW}Release was created but upload failed. Upload manually from GitHub.${NC}"
else
    echo -e "${GREEN}AppImage uploaded successfully${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Release $NEW_VERSION complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "  AppImage: $OUTPUT_DIR/$APPIMAGE_NAME"
echo -e "  GitHub:   https://github.com/$GITHUB_OWNER/$GITHUB_REPO/releases/tag/$NEW_VERSION"
echo ""
echo -e "  Users running older versions will auto-update."

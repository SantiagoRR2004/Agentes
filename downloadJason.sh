#!/bin/bash

# Set repo info
REPO="jason-lang/jason"

# Get latest release data from GitHub API
RELEASE_DATA=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")

# Extract the URL with -bin- and that downloads a .zip file
ASSET_URL=$(echo "$RELEASE_DATA" \
  | grep browser_download_url \
  | cut -d '"' -f 4 \
  | grep '\-bin-.*\.zip$')

# Check if we found a URL
if [ -z "$ASSET_URL" ]; then
  echo "No valid URL found in the latest release."
  exit 1
fi

# Extract filename from URL
FILENAME=$(basename "$ASSET_URL")

# Strip .zip to get folder name
FOLDER_NAME="${FILENAME%.zip}"

# Download the asset
echo "Downloading $FILENAME..."
curl -L -o "$FILENAME" "$ASSET_URL"

echo "Download complete."

# Create target extraction directory
mkdir -p "$FOLDER_NAME"

# Extract into that folder
echo "Extracting $FILENAME to ./$FOLDER_NAME..."
unzip "$FILENAME" -d "$FOLDER_NAME"

echo "Extraction complete. Extracted to: $FOLDER_NAME"
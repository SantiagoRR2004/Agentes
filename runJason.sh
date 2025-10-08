#!/bin/bash

# Find the latest jason-bin-* directory
JASON_DIR=$(find "${PWD}" -maxdepth 1 -type d -name "jason-bin-*" | sort -V | tail -n 1)

# Check if we found a jason-bin directory
if [ -z "$JASON_DIR" ]; then
  echo "Error: No jason-bin-* directory found in ${PWD}"
  echo "Please run the downloadJason.sh script first to download Jason."
  exit 1
fi

# Check if the jason executable exists in the found directory
JASON_EXEC="${JASON_DIR}/bin/jason"
if [ ! -f "$JASON_EXEC" ]; then
  echo "Error: Jason executable not found at $JASON_EXEC"
  echo "The jason-bin directory may be corrupted or incomplete."
  exit 1
fi

# Delete the files and folders if they exist
MAS2J_DIR=$(dirname "$1")
FILES=("$MAS2J_DIR/.gradle"
  "$MAS2J_DIR/build.gradle"
  "$MAS2J_DIR/bin"
  "$MAS2J_DIR/build"
  "$MAS2J_DIR/settings.gradle"
  )

for FILE in "${FILES[@]}"; do
  if [ -e "$FILE" ]; then
    rm -rf "$FILE"
    echo "Deleted existing $FILE."
  fi
done

# Enable OpenGL in Java
export _JAVA_OPTIONS="-Dsun.java2d.opengl=true -Dsun.java2d.opengl.fbobject=false"

echo "Using Jason from: $JASON_DIR"
"$JASON_EXEC" "$1"

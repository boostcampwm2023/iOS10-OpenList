#!/usr/bin/env sh
# original source: https://github.com/uber/RIBs/blob/main/ios/tooling/install-xcode-template.sh

# Configuration
XCODE_TEMPLATE_DIR=$HOME'/Library/Developer/Xcode/Templates/File Templates/Butterfly'
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Copy Butterfly file templates into the local Butterfly template directory
xcodeTemplate () {
  echo "==> Copying up Butterfly Xcode file templates..."

  if [ -d "$XCODE_TEMPLATE_DIR" ]; then
    rm -R "$XCODE_TEMPLATE_DIR"
  fi
  mkdir -p "$XCODE_TEMPLATE_DIR"

  cp -R $SCRIPT_DIR/*.xctemplate "$XCODE_TEMPLATE_DIR"
}

xcodeTemplate

echo "==> ... success!"
echo "==> Butterfly have been set up. In Xcode, select 'New File...' to use Butterfly templates."

#!/bin/bash
set -euo pipefail

VERSION="${DN_VERSION:-latest}"
INSTALL_DIR="${DN_INSTALL_DIR:-$HOME/.local/bin}"

# Detect OS
case "$RUNNER_OS" in
  Linux)  OS="linux" ;;
  macOS)  OS="macos" ;;
  Windows) OS="windows" ;;
  *)
    echo "error: unsupported OS: $RUNNER_OS" >&2
    exit 1
    ;;
esac

# Detect architecture
case "$RUNNER_ARCH" in
  X64)  ARCH="x64" ;;
  ARM64) ARCH="arm64" ;;
  *)
    echo "error: unsupported architecture: $RUNNER_ARCH" >&2
    exit 1
    ;;
esac

# Build binary name
if [ "$OS" = "windows" ]; then
  BINARY="dn-${OS}-${ARCH}.exe"
else
  BINARY="dn-${OS}-${ARCH}"
fi

# Resolve version tag
if [ "$VERSION" = "latest" ]; then
  TAG=$(curl -fsSL \
    -H "Authorization: token ${GITHUB_TOKEN:-}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/chesapeake/dn/releases/latest" \
    | grep '"tag_name"' \
    | sed 's/.*"v\?\([^"]*\)".*/\1/')
  if [ -z "$TAG" ]; then
    echo "error: failed to resolve latest release tag" >&2
    exit 1
  fi
else
  TAG="$VERSION"
fi

# Download
URL="https://github.com/chesapeake/dn/releases/download/${TAG}/${BINARY}"
DEST="$INSTALL_DIR/${BINARY##*/}"

mkdir -p "$INSTALL_DIR"
echo "::notice::Downloading dn ${TAG} for ${OS}/${ARCH} from ${URL}"
curl -fsSL -o "$DEST" "$URL"

# Make executable (skip on Windows — .exe is already executable)
if [ "$OS" != "windows" ]; then
  chmod +x "$DEST"
fi

# Ensure binary is on PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo "$INSTALL_DIR" >> $GITHUB_PATH
fi

# Write outputs
echo "version=$TAG" >> $GITHUB_OUTPUT
echo "path=$DEST" >> $GITHUB_OUTPUT

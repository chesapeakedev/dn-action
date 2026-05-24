#!/bin/bash
set -euo pipefail

VERSION="${DN_VERSION:-latest}"
INSTALL_DIR="${DN_INSTALL_DIR:-$HOME/.local/bin}"
DN_REPO="${DN_REPO:-chesapeakedev/dn}"

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

# Release asset name (platform-specific download from GitHub Releases)
if [ "$OS" = "windows" ]; then
  BINARY="dn-${OS}-${ARCH}.exe"
  DN_BIN="$INSTALL_DIR/dn.exe"
else
  BINARY="dn-${OS}-${ARCH}"
  DN_BIN="$INSTALL_DIR/dn"
fi

# Auth headers only when a token is set (empty Authorization causes GitHub 401)
AUTH_HEADER=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

# Auth headers only when a token is set (empty Authorization causes GitHub 401)
AUTH_HEADER=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

# Resolve version tag
if [ "$VERSION" = "latest" ]; then
  TAG=$(curl -fsSL \
    "${AUTH_HEADER[@]}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${DN_REPO}/releases/latest" \
    | grep '"tag_name"' \
    | head -1 \
    | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
  if [ -z "$TAG" ]; then
    echo "error: failed to resolve latest release tag from ${DN_REPO}" >&2
    exit 1
  fi
else
  TAG="$VERSION"
fi

# Release tags use a v prefix (e.g. v0.0.23)
if [[ "$TAG" != v* ]]; then
  TAG="v${TAG}"
fi

# Download release asset to a temp file, then install as dn (or dn.exe on Windows)
URL="https://github.com/${DN_REPO}/releases/download/${TAG}/${BINARY}"
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

mkdir -p "$INSTALL_DIR"
echo "::notice::Downloading dn ${TAG} for ${OS}/${ARCH} from ${URL}"
if [ "${#AUTH_HEADER[@]}" -gt 0 ]; then
  curl -fsSL "${AUTH_HEADER[@]}" -H "Accept: application/octet-stream" -o "$TMP" "$URL"
else
  curl -fsSL -o "$TMP" "$URL"
fi

if [ "$OS" != "windows" ]; then
  chmod +x "$TMP"
fi

mv -f "$TMP" "$DN_BIN"
trap - EXIT

# Remove legacy platform-named binary from older action versions
rm -f "$INSTALL_DIR/${BINARY##*/}"

if [ "$OS" != "windows" ]; then
  chmod +x "$DN_BIN"
fi

# Ensure install directory is on PATH for subsequent workflow steps
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo "$INSTALL_DIR" >> "$GITHUB_PATH"
fi

echo "version=$TAG" >> "$GITHUB_OUTPUT"
echo "path=$DN_BIN" >> "$GITHUB_OUTPUT"

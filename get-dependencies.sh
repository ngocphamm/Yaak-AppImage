#!/bin/sh
# Resolve the latest STABLE Yaak release, download its .deb, and lay it out
# as ./AppDir so make-appimage.sh can bundle it with sharun.
#
# Yaak is a Tauri v2 app (Rust + React + WebKitGTK 4.1). We repackage the
# upstream .deb rather than building from source: the .deb already contains a
# clean FHS layout (/usr/bin, /usr/share/...), which sharun can trace cleanly.
set -eu

ARCH="$(uname -m)"

# Yaak currently only publishes an x86_64 (amd64) .deb. If upstream ever ships
# arm64, this mapping will pick it up automatically.
case "$ARCH" in
    x86_64)  DEB_ARCH="amd64" ;;
    aarch64) DEB_ARCH="arm64" ;;   # not published by Yaak yet -> will 404
    *) echo "Unsupported arch: $ARCH" >&2; exit 1 ;;
esac

# --- Bootstrap the pkgforge helper if the container doesn't provide it --------
# The pkgforge builder image ships get-debloated-pkgs on PATH already. This
# fallback lets the repo also build on a vanilla Arch container.
command -v get-debloated-pkgs >/dev/null 2>&1 || {
    wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh \
        -O /usr/local/bin/get-debloated-pkgs
    chmod +x /usr/local/bin/get-debloated-pkgs
}

# --- Resolve the latest stable version ---------------------------------------
# /releases/latest deliberately excludes pre-releases; Yaak publishes a LOT of
# betas, so this keeps us on stable. Strip the leading "v" from the tag
# (tag: v2026.4.0  ->  asset: yaak_2026.4.0_amd64.deb).
echo "Resolving latest Yaak release..."
VERSION="$(wget -qO- https://api.github.com/repos/mountain-loop/yaak/releases/latest \
    | grep -Po '"tag_name"\s*:\s*"\K[^"]+' | sed 's/^v//')"
[ -n "$VERSION" ] || { echo "Could not determine latest Yaak version" >&2; exit 1; }
echo "Latest stable Yaak: $VERSION"

DEB_LINK="https://github.com/mountain-loop/yaak/releases/download/v${VERSION}/yaak_${VERSION}_${DEB_ARCH}.deb"

# --- Debloated WebKitGTK 4.1 + common libs -----------------------------------
# Same trick Stirling-PDF/opencode use: pull a slimmed webkit so the bundle
# stays small. quick-sharun will collect it into the AppDir in make-appimage.sh.
echo "Installing debloated webkit2gtk-4.1 + common libs..."
get-debloated-pkgs --add-common --prefer-nano webkit2gtk-4.1-mini

# Yaak's WebKitGTK links libjxl (JPEG XL). The pkgforge webkit2gtk-4.1-mini
# currently expects libjxl.so.0.11, but Arch's stock libjxl has moved to 0.12,
# so nothing on the system provides the 0.11 soname and sharun aborts. Pull the
# matching 0.11 build from the Arch Linux Archive so it can be bundled.
# NOTE: once pkgforge rebuilds webkit-mini against libjxl 0.12, drop or bump this.
pacman -U --noconfirm \
    https://archive.archlinux.org/packages/l/libjxl/libjxl-0.11.1-5-x86_64.pkg.tar.zst

# --- Download + extract the .deb into ./AppDir -------------------------------
echo "Downloading $DEB_LINK ..."
wget --retry-connrefused --tries=30 "$DEB_LINK" -O /tmp/yaak.deb

echo "Extracting .deb -> ./AppDir ..."
ar xv /tmp/yaak.deb
tar -xf ./data.tar.*
rm -f ./*.tar.* ./debian-binary
mv -v ./usr ./AppDir

# Record version so the CI release step can tag correctly.
echo "$VERSION" > "$HOME/version"

echo "----------------------------------------------------------------"
echo "AppDir binaries (verify the main one is 'yaak-app'):"
ls -1 ./AppDir/bin || true
echo "AppDir .desktop / icons:"
find ./AppDir/share/applications ./AppDir/share/icons -type f 2>/dev/null || true
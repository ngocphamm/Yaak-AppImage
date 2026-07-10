#!/bin/sh
# Bundle the extracted Yaak AppDir into a portable AppImage using sharun, and
# bake in the WebKitGTK env fixes so it "just works" on Wayland / NVIDIA.
set -eu

ARCH="$(uname -m)"
export ARCH
export OUTPATH=./dist

# --- AppImage metadata --------------------------------------------------------
# Auto-detect the .desktop and the largest icon the .deb shipped, so this keeps
# working even if upstream tweaks the paths.
export DESKTOP="$(find ./AppDir/share/applications -name '*.desktop' | head -n1)"
export ICON="$(find ./AppDir/share/icons -name 'yaak*.png' | sort -V | tail -n1)"

# Main binary inside ./AppDir/bin. Yaak's GUI binary is "yaak-app-client"
export MAIN_BIN=yaak-app-client

# Self-updater metadata -> points at YOUR fork's GitHub releases.
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"

# --- sharun behaviour ---------------------------------------------------------
export DEPLOY_OPENGL=1     # WebKitGTK needs GL
export DEPLOY_VULKAN=0     # not needed once dmabuf renderer is off; flip to 1
                           # only if NVIDIA users still report issues
export GTK_CLASS_FIX=1     # fix WM_CLASS so Wayland matches yaak.desktop
                           # (prevents "generic wl-shell icon" / grouping bugs)
export ANYLINUX_LIB=1      # general portability preload (default on)
export URUNTIME_PRELOAD=1

# OPTIONAL self-updater hook (checks YOUR releases and prompts the user).
# NOTE: Yaak also has its own in-app updater. If it tries to replace this file
# with the official (non-sharun) AppImage, the Wayland bug comes back. Consider
# disabling Yaak's built-in updater (see README notes) if you keep this hook.
export ADD_HOOKS="self-updater.bg.hook"

# --- Bootstrap quick-sharun if the container doesn't provide it ---------------
command -v quick-sharun >/dev/null 2>&1 || {
    wget -q https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh \
        -O /usr/local/bin/quick-sharun
    chmod +x /usr/local/bin/quick-sharun
}

# --- Bundle every binary the .deb shipped (main app + any Tauri sidecars) -----
quick-sharun ./AppDir/bin/*

# --- Turn the AppDir into an AppImage ----------------------------------------
quick-sharun --make-appimage

echo "----------------------------------------------------------------"
echo "Built:"
ls -1 ./dist

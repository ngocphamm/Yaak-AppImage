# Yaak-AppImage 🦬

[![GitHub Downloads](https://img.shields.io/github/downloads/ngocphamm/Yaak-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/ngocphamm/Yaak-AppImage/releases/latest) [![CI Build Status](https://github.com/ngocphamm/Yaak-AppImage/actions/workflows/appimage.yml/badge.svg)](https://github.com/ngocphamm/Yaak-AppImage/actions/workflows/appimage.yml) [![Latest Stable Release](https://img.shields.io/github/v/release/ngocphamm/Yaak-AppImage)](https://github.com/ngocphamm/Yaak-AppImage/releases/latest)

| Latest Stable Release                                                        | Upstream URL                                                |
| --------------------------------------------------------------------------- | ---------------------------------------------------------- |
| [Click here](https://github.com/ngocphamm/Yaak-AppImage/releases/latest)    | [Click here](https://github.com/mountain-loop/yaak)        |

---

> [!IMPORTANT]
> **This is an unofficial, community-maintained repackage of [Yaak](https://github.com/mountain-loop/yaak).**
> It is **not** affiliated with, endorsed by, or supported by the Yaak project or Mountain Loop.
> For official builds, see [yaak.app](https://yaak.app) or the [upstream repository](https://github.com/mountain-loop/yaak).
> Please report problems with **this AppImage packaging** on [this repo's issue tracker](https://github.com/ngocphamm/Yaak-AppImage/issues) — not to the upstream Yaak project.

---

AppImage made using [quick-sharun](https://github.com/pkgforge-dev/Anylinux-AppImages/blob/main/useful-tools/quick-sharun.sh), which makes it extremely easy to turn any binary into a portable package reliably without using containers or similar tricks.

**This AppImage bundles everything and it should work on any Linux distro, including old and musl-based ones.**

Because every library (including WebKitGTK) is bundled, this build also avoids the blank-screen / crash-on-launch problems that the official Yaak AppImage can hit on **Wayland** and **NVIDIA** setups — it runs on Wayland out of the box, with no need to set `WEBKIT_DISABLE_DMABUF_RENDERER` or `WEBKIT_DISABLE_COMPOSITING_MODE` by hand.

This AppImage doesn't require FUSE to run at all, thanks to the [uruntime](https://github.com/VHSgunzo/uruntime).

This AppImage is also supplied with a self-updater by default, so any updates to this application won't be missed. You will be prompted for permission to check for updates, and if you agree, you will then be notified when a new update is available.

Self-updater is disabled by default if AppImage managers like [am](https://github.com/ivan-hc/AM), [soar](https://github.com/pkgforge/soar) or [dbin](https://github.com/xplshn/dbin) exist, which manage AppImage updates.

## Usage

Download the latest `.AppImage` from the [releases page](https://github.com/ngocphamm/Yaak-AppImage/releases/latest), then:

```sh
chmod +x ./Yaak-*.AppImage
./Yaak-*.AppImage
```

The [official Yaak AppImage](https://yaak.app/docs/getting-started/installation) is built with Tauri's bundler and relies on the host's WebKitGTK, which leads to recurring blank-screen and crash-on-launch reports on Wayland and NVIDIA. This repository repackages the upstream `.deb` with sharun so that WebKitGTK and all other dependencies are bundled and the Wayland fixes ship enabled — producing a single portable file that works across distros.

---

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)

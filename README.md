# Kinoite NVIDIA + Hyprland + Quickshell (Caelestia)

Custom Universal Blue image built on:

* `ghcr.io/ublue-os/kinoite-nvidia:43`
* Hyprland (Copr: solopasha)
* quickshell-git (Copr: errornointernet)
* Caelestia shell (built from source)
* libcava (built from source for CavaProvider)
* Gaming stack (gamescope, mangohud, vkBasalt, gamemode)

This image is designed to be:

* Atomic
* NVIDIA-ready
* Wayland-native
* Quickshell-powered
* Reproducible

---

## 🔧 Base

```
ghcr.io/ublue-os/kinoite-nvidia:43
```

This provides:

* Fedora Kinoite
* NVIDIA drivers + akmods
* Atomic / rpm-ostree model

---

## 🧱 What This Image Adds

### Window Manager

* Hyprland
* xdg-desktop-portal-hyprland

### Shell

* quickshell-git (required for Caelestia)
* Caelestia shell plugin (compiled from source)
* Installed into:

  ```
  /usr/lib64/qt6/qml/Caelestia
  ```

### Audio Visualization

* libcava (compiled from source)
* symlinked pkg-config as `cava.pc`

### Qt6 Requirements

Installed dev/runtime alignment to ensure plugin builds correctly:

* qt6-qtbase
* qt6-qtdeclarative
* qt6-qtwayland
* qt6-qtsvg
* qt6-qtquickcontrols2
* qt6-qtimageformats
* qt6-qtshadertools
* qt6-qt5compat

### Gaming

* gamescope
* mangohud
* vkBasalt
* gamemode

### Tools

* podman
* toolbox
* distrobox
* git
* cmake
* ninja-build
* gcc-c++
* pkgconf-pkg-config

---

## 🚀 Rebase Instructions

### Rebase using tag

```bash
sudo rpm-ostree rebase \
  ostree-unverified-registry:ghcr.io/vumast3r/kinoite-nvidia-hyprland:latest
```

### Rebase using digest (recommended)

```bash
sudo rpm-ostree rebase \
  ostree-unverified-registry:ghcr.io/vumast3r/kinoite-nvidia-hyprland@sha256:<digest>
```

Then reboot:

```bash
reboot
```

Verify:

```bash
rpm-ostree status
```

---

## 🧠 Caelestia Notes

This image fixes:

* QML module path issues (`/usr/usr` bug)
* Correct Qt6 QML install directory:

  ```
  /usr/lib64/qt6/qml
  ```
* libcava install prefix (`/usr`, not `/usr/local`)
* pkg-config visibility for cava

If Caelestia fails to load:

```bash
qs -c caelestia
```

Check logs:

```bash
tail -n 200 /run/user/1000/quickshell/by-id/*/log.qslog
```

---

## 🧹 Deployment Management

Remove old deployment:

```bash
sudo rpm-ostree cleanup -r
```

Remove pending deployment:

```bash
sudo rpm-ostree cleanup -p
```

---

## 📦 Philosophy

This image follows the atomic model:

* No mutable root changes
* All changes baked into the image
* Reproducible via Containerfile
* Versioned like infrastructure

It is effectively:

> Git for your operating system.

---

## ⚠️ Known Constraints

* Built for Fedora 43 (NVIDIA base)
* Uses Copr repos (Hyprland + quickshell)
* Caelestia compiled from upstream source
* Requires reboot after rebase

---

## 🔮 Future Improvements

* Remove build toolchain from final image layer (multi-stage build)
* Add auto-config installer for Caelestia
* Optional image signing enforcement
* Switch to digest pinning in workflow
* A slimmer runtime-only final image
* A proper release tagging strategy
* Github Actions hardening updates

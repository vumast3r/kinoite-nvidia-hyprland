#!/bin/bash
set -ouex pipefail

echo "=== System Build Starting ==="

# 1. Add Custom Repositories
# Material Symbols Font
curl -Lo /etc/yum.repos.d/purian23-material-symbols-fonts.repo https://copr.fedorainfracloud.org/coprs/purian23/material-symbols-fonts/repo/fedora-$(rpm -E %fedora)/purian23-material-symbols-fonts-fedora-$(rpm -E %fedora).repo

# Solopasha Hyprland
curl -Lo /etc/yum.repos.d/solopasha-hyprland.repo https://copr.fedorainfracloud.org/coprs/solopasha/hyprland/repo/fedora-$(rpm -E %fedora)/solopasha-hyprland-fedora-$(rpm -E %fedora).repo

# Quickshell Pre-Compiled Binaries
curl -Lo /etc/yum.repos.d/errornointernet-quickshell.repo https://copr.fedorainfracloud.org/coprs/errornointernet/quickshell/repo/fedora-$(rpm -E %fedora)/errornointernet-quickshell-fedora-$(rpm -E %fedora).repo

# 2. Install Hyprland Base Compositor
rpm-ostree install \
    hyprland \
    xdg-desktop-portal-hyprland

# 3. Install Caelestia Runtime & System Essentials
rpm-ostree install \
    brightnessctl \
    ddcutil \
    network-manager-applet \
    lm_sensors \
    fish \
    nvtop \
    fastfetch \
    qalculate \
    material-symbols-fonts \
    playerctl \
    grim \
    slurp

# 4. Install Quickshell & Qt6 Runtime (NO DEVEL HEADERS REQUIRED)
rpm-ostree install \
    quickshell \
    qt6-qtdeclarative \
    qt6-qt5compat \
    qt6-qtsvg \
    qt6-qtmultimedia

echo "=== System Build Complete ==="

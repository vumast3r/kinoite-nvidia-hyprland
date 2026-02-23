#!/bin/bash
set -ouex pipefail

echo "=== System Build Starting ==="

# 1. Add Custom Repositories
# Material Symbols Font
curl -Lo /etc/yum.repos.d/purian23-material-symbols-fonts.repo https://copr.fedorainfracloud.org/coprs/purian23/material-symbols-fonts/repo/fedora-$(rpm -E %fedora)/purian23-material-symbols-fonts-fedora-$(rpm -E %fedora).repo

# Solopasha Hyprland (Provides the missing Hyprland packages)
curl -Lo /etc/yum.repos.d/solopasha-hyprland.repo https://copr.fedorainfracloud.org/coprs/solopasha/hyprland/repo/fedora-$(rpm -E %fedora)/solopasha-hyprland-fedora-$(rpm -E %fedora).repo

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

# 4. Install Qt6 & Wayland Compilation Headers
rpm-ostree install \
    cmake ninja-build gcc-c++ python3-pip autoconf automake libtool \
    fftw-devel alsa-lib-devel iniparser-devel qt6-qtbase-devel \
    qt6-qtdeclarative-devel qt6-qtwayland-devel qt6-qtsvg-devel \
    qt6-qtshadertools-devel wayland-devel wayland-protocols-devel \
    cli11-devel spirv-tools pkgconf-pkg-config libdrm-devel \
    mesa-libgbm-devel pipewire-devel pulseaudio-libs-devel \
    aubio-devel libxkbcommon-devel pam-devel NetworkManager-libnm-devel \
    lm_sensors-devel libqalculate-devel polkit-devel meson ncurses-devel \
    qt6-qtdeclarative qt6-qt5compat qt6-qtsvg qt6-qtmultimedia

echo "=== System Build Complete ==="

#!/bin/bash
set -ouex pipefail

# Add Copr repositories
COPR_REPOS=(purian23/material-symbols-fonts solopasha/hyprland errornointernet/quickshell)
for repo in "${COPR_REPOS[@]}"; do
  name="${repo//\//-}"
  curl -Lo "/etc/yum.repos.d/${name}.repo" \
    "https://copr.fedorainfracloud.org/coprs/${repo}/repo/fedora-$(rpm -E %fedora)/${name}-fedora-$(rpm -E %fedora).repo"
done

# Install all packages in a single transaction
rpm-ostree install \
    hyprland \
    xdg-desktop-portal-hyprland \
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
    slurp \
    quickshell \
    qt6-qtdeclarative \
    qt6-qt5compat \
    qt6-qtsvg \
    qt6-qtmultimedia

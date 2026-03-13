# Containerfile — Hyprland rice on Kinoite or Bazzite
#
# Base image selection:
#   Kinoite:  ghcr.io/ublue-os/kinoite-nvidia:latest
#   Bazzite:  ghcr.io/ublue-os/bazzite-nvidia:stable
#
ARG BASE_IMAGE="ghcr.io/ublue-os/bazzite-nvidia:stable"

FROM ${BASE_IMAGE}

# ── Add COPR repositories ────────────────────────────────────────────
RUN curl -Lo /etc/yum.repos.d/solopasha-hyprland.repo \
      "https://copr.fedorainfracloud.org/coprs/solopasha/hyprland/repo/fedora-$(rpm -E %fedora)/solopasha-hyprland-fedora-$(rpm -E %fedora).repo" && \
    curl -Lo /etc/yum.repos.d/errornointernet-quickshell.repo \
      "https://copr.fedorainfracloud.org/coprs/errornointernet/quickshell/repo/fedora-$(rpm -E %fedora)/errornointernet-quickshell-fedora-$(rpm -E %fedora).repo" && \
    curl -Lo /etc/yum.repos.d/purian23-material-symbols-fonts.repo \
      "https://copr.fedorainfracloud.org/coprs/purian23/material-symbols-fonts/repo/fedora-$(rpm -E %fedora)/purian23-material-symbols-fonts-fedora-$(rpm -E %fedora).repo"

# ── Hyprland compositor + portal ─────────────────────────────────────
RUN rpm-ostree install \
      hyprland \
      xdg-desktop-portal-hyprland \
    && rpm-ostree cleanup -m

# ── Quickshell bar + Qt6 runtime ─────────────────────────────────────
RUN rpm-ostree install \
      quickshell \
      qt6-qtdeclarative \
      qt6-qt5compat \
      qt6-qtsvg \
      qt6-qtmultimedia \
    && rpm-ostree cleanup -m

# ── Rice utilities ───────────────────────────────────────────────────
RUN rpm-ostree install \
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
    && rpm-ostree cleanup -m

# ── Copy any system overlay files ────────────────────────────────────
COPY system_files/ /

# ── Final cleanup ────────────────────────────────────────────────────
RUN rpm-ostree cleanup -m && \
    ostree container commit

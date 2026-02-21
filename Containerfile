# =====================================================================
# Kinoite NVIDIA (Fedora 43) + Hyprland + Quickshell + Caelestia Shell
# =====================================================================

FROM ghcr.io/ublue-os/kinoite-nvidia:43

# ---------------------------------------------------------
# COPR: solopasha/hyprland (Fedora 43)
# ---------------------------------------------------------
RUN printf '%s\n' \
'[copr:copr.fedorainfracloud.org:solopasha:hyprland]' \
'name=Copr repo for hyprland owned by solopasha' \
'baseurl=https://download.copr.fedorainfracloud.org/results/solopasha/hyprland/fedora-43-x86_64/' \
'type=rpm-md' \
'skip_if_unavailable=True' \
'gpgcheck=1' \
'gpgkey=https://download.copr.fedorainfracloud.org/results/solopasha/hyprland/pubkey.gpg' \
'repo_gpgcheck=0' \
'enabled=1' \
'enabled_metadata=1' \
> /etc/yum.repos.d/_copr_solopasha-hyprland.repo

# ---------------------------------------------------------
# COPR: errornointernet/quickshell (Fedora 43)
# ---------------------------------------------------------
RUN printf '%s\n' \
'[copr:copr.fedorainfracloud.org:errornointernet:quickshell]' \
'name=Copr repo for quickshell owned by errornointernet' \
'baseurl=https://download.copr.fedorainfracloud.org/results/errornointernet/quickshell/fedora-43-x86_64/' \
'type=rpm-md' \
'skip_if_unavailable=True' \
'gpgcheck=1' \
'gpgkey=https://download.copr.fedorainfracloud.org/results/errornointernet/quickshell/pubkey.gpg' \
'repo_gpgcheck=0' \
'enabled=1' \
'enabled_metadata=1' \
> /etc/yum.repos.d/_copr_errornointernet-quickshell.repo

# ---------------------------------------------------------
# Install packages
# ---------------------------------------------------------
# Notes:
# - Fedora package name is vkBasalt (capital B)
# - We install git temporarily to clone Caelestia during build
# - qt6-qtdeclarative + qt6-qtsvg are common Quickshell/QML deps
RUN rpm-ostree install \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt6-qtwayland \
    quickshell \
    qt6-qtdeclarative \
    qt6-qtsvg \
    wofi \
    foot \
    wl-clipboard \
    grim \
    slurp \
    brightnessctl \
    pavucontrol \
    playerctl \
    gamemode \
    gamescope \
    mangohud \
    vkBasalt \
    podman \
    toolbox \
    distrobox \
    git \
    && ostree container commit

# ---------------------------------------------------------
# Embed Caelestia Shell system-wide for Quickshell
# ---------------------------------------------------------
# This clones the Caelestia shell repo into the immutable image.
# Users can then symlink it into ~/.config/quickshell/caelestia
RUN mkdir -p /usr/share/quickshell \
 && git clone --depth=1 https://github.com/caelestia-dots/shell /usr/share/quickshell/caelestia \
 && rm -rf /usr/share/quickshell/caelestia/.git \
 && ostree container commit
# Copy repo-provided system files into the image (scripts, configs, etc.)
COPY system_files/ /
RUN ostree container commit

ddddddddddddddddddddddddddddddddddddddddddd# =====================================================================
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
# add in cmake, ninja-build, gcc-c++, and make
RUN rpm-ostree install \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt6-qtwayland \
    quickshell-git \
    qt6-qtdeclarative \
    qt6-qtquickcontrols2 \
    qt6-qtsvg \
    qt6-qtimageformats \
    qt6-qtshadertools \
    qt6-qt5compat \
    pkgconf-pkg-config \
    qt6-qtbase-devel \
    qt6-qtbase-private-devel \
    qt6-qtdeclarative-devel \
    qt6-qtdeclarative-private-devel \
    qt6-qtwayland-devel \
    qt6-qtsvg-devel \
    cava \
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
    cmake \
    ninja-build \
    gcc-c++ \
    make \
    && ostree container commit

# ---------------------------------------------------------
# Embed Caelestia Shell system-wide for Quickshell
# ---------------------------------------------------------
# Copy repo-provided system files into the image (scripts, configs, etc.)
COPY system_files/ /
RUN ostree container commit
# Build + install Caelestia Shell (installs the QML module "Caelestia")
RUN git clone --filter=blob:none --tags https://github.com/caelestia-dots/shell.git /tmp/caelestia-shell \
 && cmake -S /tmp/caelestia-shell -B /tmp/caelestia-shell/build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_MESSAGE_LOG_LEVEL=VERBOSE \
 && cmake --build /tmp/caelestia-shell/build \
 && cmake --install /tmp/caelestia-shell/build \
 && rm -rf /tmp/caelestia-shell \
 && ostree container commit

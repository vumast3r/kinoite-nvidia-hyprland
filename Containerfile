# =====================================================================
# Kinoite NVIDIA (Fedora 43) + Hyprland + Quickshell-git + Caelestia Shell
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

# Make COPR downloads less fragile in CI
RUN printf '%s\n' \
'fastestmirror=True' \
'max_parallel_downloads=10' \
'retries=20' \
'timeout=120' \
'minrate=1' \
>> /etc/dnf/dnf.conf

# ---------------------------------------------------------
# Runtime + build deps (build deps are here to compile Caelestia)
# ---------------------------------------------------------
RUN rpm-ostree install \
    # Hyprland + portals
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt6-qtwayland \
    \
    # Quickshell (git)
    quickshell-git \
    \
    # Qt runtime (needed by Caelestia at runtime)
    qt6-qtdeclarative \
    qt6-qtquickcontrols2 \
    qt6-qtsvg \
    qt6-qtimageformats \
    qt6-qtshadertools \
    qt6-qt5compat \
    \
    # Caelestia runtime deps
    cava \
    playerctl \
    ddcutil \
    lm_sensors \
    pipewire \
    pipewire-libs \
    NetworkManager \
    brightnessctl \
    \
    # Launchers / tools
    wofi \
    foot \
    wl-clipboard \
    grim \
    slurp \
    pavucontrol \
    swappy \
    \
    # Gaming
    gamemode \
    gamescope \
    mangohud \
    vkBasalt \
    \
    # Containers
    podman \
    toolbox \
    distrobox \
    \
    # Build toolchain for Caelestia
    git \
    cmake \
    ninja-build \
    gcc-c++ \
    make \
    pkgconf-pkg-config \
    \
    # Caelestia plugin build deps (pkg-config provides .pc files)
    libqalculate-devel \
    pipewire-devel \
    lm_sensors-devel \
    \
    # Qt dev + private dev (required for this ecosystem)
    qt6-qtbase-devel \
    qt6-qtbase-private-devel \
    qt6-qtdeclarative-devel \
    qt6-qtdeclarative-private-devel \
    qt6-qtwayland-devel \
    qt6-qtsvg-devel \
    \
    && ostree container commit

# ---------------------------------------------------------
# Copy repo-provided system files into the image
# ---------------------------------------------------------
COPY system_files/ /
RUN ostree container commit

# ---------------------------------------------------------
# Build + install Caelestia Shell (installs QML module "Caelestia")
# ---------------------------------------------------------
RUN git clone --filter=blob:none --tags https://github.com/caelestia-dots/shell.git /tmp/caelestia-shell \
 && cmake -S /tmp/caelestia-shell -B /tmp/caelestia-shell/build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
 && cmake --build /tmp/caelestia-shell/build \
 && cmake --install /tmp/caelestia-shell/build \
 && rm -rf /tmp/caelestia-shell \
 && ostree container commit

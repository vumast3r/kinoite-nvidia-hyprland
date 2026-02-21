FROM ghcr.io/ublue-os/kinoite-nvidia:43

# Add COPRs (hyprland + quickshell-git)
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

# Make COPR downloads less flaky (timeouts/retries)
RUN printf '%s\n' \
  'fastestmirror=True' \
  'max_parallel_downloads=5' \
  'retries=20' \
  'timeout=120' \
  'minrate=1' \
  >> /etc/dnf/dnf.conf

# Base runtime + build deps needed for Caelestia plugin + libcava
RUN rpm-ostree install \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt6-qtwayland \
    quickshell-git \
    foot \
    wofi \
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
    cava \
    ddcutil \
    lm_sensors \
    pipewire \
    pipewire-libs \
    NetworkManager \
    podman \
    toolbox \
    distrobox \
    git \
    \
    cmake \
    ninja-build \
    gcc-c++ \
    make \
    meson \
    pkgconf-pkg-config \
    \
    # Caelestia plugin deps (headers + pkg-config)
    aubio-devel \
    libqalculate-devel \
    pipewire-devel \
    NetworkManager-libnm-devel \
    \
    # libcava build deps (meson will look for these)
    fftw3-devel \
    iniparser-devel \
    \
    # Qt6 dev (for cmake find_package(Qt6 ...))
    qt6-qtbase-devel \
    qt6-qtdeclarative-devel \
    qt6-qtquickcontrols2-devel \
    qt6-qtsvg-devel \
    qt6-qt5compat-devel \
    \
    && ostree container commit

# ---- Build/install libcava (fork that actually provides a shared lib) ----
RUN git clone --filter=blob:none --depth=1 https://github.com/LukashonakV/cava.git /tmp/libcava \
 && meson setup /tmp/libcava/build /tmp/libcava \
      -Dbuild_target=lib \
      --prefix=/usr \
      --libdir=lib64 \
 && meson compile -C /tmp/libcava/build \
 && meson install -C /tmp/libcava/build \
 && rm -rf /tmp/libcava \
 && if [ -f /usr/lib64/pkgconfig/libcava.pc ]; then ln -sf /usr/lib64/pkgconfig/libcava.pc /usr/lib64/pkgconfig/cava.pc; fi \
 && ostree container commit

# ---- Embed Caelestia shell config (for your installer script to link) ----
RUN mkdir -p /usr/share/quickshell \
    && git clone --depth=1 https://github.com/caelestia-dots/shell /usr/share/quickshell/caelestia \
    && rm -rf /usr/share/quickshell/caelestia/.git \
    && ostree container commit

# ---- Build/install Caelestia plugin (installs the "Caelestia" QML module) ----
RUN git clone --filter=blob:none --tags https://github.com/caelestia-dots/shell.git /tmp/caelestia-shell \
    && cmake -S /tmp/caelestia-shell -B /tmp/caelestia-shell/build -G Ninja \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=/ \
         -DCMAKE_INSTALL_LIBDIR=/usr/lib64 \
         -DINSTALL_QMLDIR=/usr/lib64/qt6/qml \
    && cmake --build /tmp/caelestia-shell/build \
    && cmake --install /tmp/caelestia-shell/build \
    && rm -rf /tmp/caelestia-shell \
    && ostree container commit

# Your tiny installer script (and any other system_files/* you keep)
COPY system_files/ /
RUN chmod +x /usr/bin/install-caelestia-shell \
    && ostree container commit

# ---- Update dynamic linker cache for manually compiled libraries ----
RUN ldconfig \
    && ostree container commit

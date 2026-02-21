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

# Make COPR downloads less flaky
RUN printf '%s\n' \
  'fastestmirror=True' \
  'max_parallel_downloads=5' \
  'retries=20' \
  'timeout=120' \
  'minrate=1' \
  >> /etc/dnf/dnf.conf

# Base runtime, desktop workflow dependencies, and build tools
RUN rpm-ostree install \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt6-qtwayland \
    quickshell-git \
    \
    # Hyprland UI workflow tools \
    rofi-wayland \
    swww \
    cliphist \
    mate-polkit \
    jq \
    wl-clipboard \
    grim \
    slurp \
    swappy \
    hyprpicker \
    brightnessctl \
    pavucontrol \
    playerctl \
    \
    # Gaming & System \
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
    \
    # Fonts and scripting \
    cascadia-code-fonts \
    python3 \
    python3-pip \
    \
    # Container / OS tools \
    podman \
    toolbox \
    distrobox \
    git \
    \
    # Build Tools \
    cmake \
    ninja-build \
    gcc-c++ \
    make \
    meson \
    pkgconf-pkg-config \
    \
    # Caelestia plugin deps (headers + pkg-config) \
    aubio-devel \
    libqalculate-devel \
    pipewire-devel \
    NetworkManager-libnm-devel \
    \
    # libcava build deps \
    fftw3-devel \
    iniparser-devel \
    \
    # Qt6 dev \
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

# ---- Embed Caelestia shell config ----
RUN mkdir -p /usr/share/quickshell \
    && git clone --depth=1 https://github.com/caelestia-dots/shell /usr/share/quickshell/caelestia \
    && rm -rf /usr/share/quickshell/caelestia/.git \
    && ostree container commit

# ---- Build/install Caelestia plugin ----
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

# ---- Install caelestia-cli (Required for buttons/menus to work) ----
RUN git clone --depth=1 https://github.com/caelestia-dots/cli.git /tmp/caelestia-cli \
    && pip3 install --prefix=/usr --break-system-packages /tmp/caelestia-cli \
    && rm -rf /tmp/caelestia-cli \
    && ostree container commit

# ---- Create and embed the install-caelestia-shell script directly ----
RUN printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -euo pipefail' \
  '' \
  'DST="${HOME}/.config/quickshell/caelestia"' \
  'mkdir -p "${HOME}/.config/quickshell"' \
  '' \
  'if [[ -e "${DST}" ]]; then' \
  '  echo "Refusing to overwrite existing: ${DST}"' \
  '  echo "Remove it if you want a fresh install."' \
  '  exit 1' \
  'fi' \
  '' \
  '# Copy the offline embedded config from the image' \
  'cp -r /usr/share/quickshell/caelestia "${DST}"' \
  '' \
  'echo "Installed Caelestia config → ${DST}"' \
  'echo "Run: qs -c caelestia"' \
  > /usr/bin/install-caelestia-shell \
  && chmod +x /usr/bin/install-caelestia-shell \
  && ostree container commit

# ---- Update dynamic linker cache for manually compiled libraries ----
RUN ldconfig \
    && ostree container commit

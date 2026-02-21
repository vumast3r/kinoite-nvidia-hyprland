FROM ghcr.io/ublue-os/kinoite-nvidia:43

# COPR repos (printf-only, no heredocs)
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

# Make COPR downloads less fragile in CI
RUN printf '%s\n' \
'fastestmirror=True' \
'max_parallel_downloads=5' \
'retries=20' \
'timeout=120' \
'minrate=1' \
>> /etc/dnf/dnf.conf

# Install packages (single RUN; backslashes only, no bash arrays)
RUN rpm-ostree install \
  hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk qt6-qtwayland \
  quickshell-git \
  qt6-qtdeclarative qt6-qtquickcontrols2 qt6-qtsvg qt6-qtimageformats qt6-qtshadertools qt6-qt5compat \
  cava playerctl ddcutil lm_sensors pipewire pipewire-libs brightnessctl swappy \
  wofi foot wl-clipboard grim slurp pavucontrol \
  gamemode gamescope mangohud vkBasalt \
  podman toolbox distrobox \
  git cmake ninja-build gcc-c++ make pkgconf-pkg-config \
  libqalculate-devel pipewire-devel aubio-devel lm_sensors-devel \
  qt6-qtbase-devel qt6-qtbase-private-devel qt6-qtdeclarative-devel qt6-qtdeclarative-private-devel qt6-qtwayland-devel qt6-qtsvg-devel \
  && ostree container commit

COPY system_files/ /
RUN ostree container commit

RUN git clone --filter=blob:none --tags https://github.com/caelestia-dots/shell.git /tmp/caelestia-shell \
 && cmake -S /tmp/caelestia-shell -B /tmp/caelestia-shell/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
 && cmake --build /tmp/caelestia-shell/build \
 && cmake --install /tmp/caelestia-shell/build \
 && rm -rf /tmp/caelestia-shell \
 && ostree container commit


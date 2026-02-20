FROM ghcr.io/ublue-os/kinoite-nvidia:stable

# Add solopasha/hyprland COPR (Fedora 43 x86_64) via the public "results" repo
RUN cat > /etc/yum.repos.d/_copr_solopasha-hyprland.repo <<'EOF'
[copr:copr.fedorainfracloud.org:solopasha:hyprland]
name=Copr repo for hyprland owned by solopasha
baseurl=https://download.copr.fedorainfracloud.org/results/solopasha/hyprland/fedora-43-x86_64/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/solopasha/hyprland/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF

# Install Hyprland + portal + gaming bits
# NOTE: Fedora package name is vkBasalt (capital B)
RUN rpm-ostree install \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt6-qtwayland \
    waybar \
    wofi \
    kitty \
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
    && ostree container commit

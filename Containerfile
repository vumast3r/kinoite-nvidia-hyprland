FROM ghcr.io/ublue-os/kinoite-nvidia:stable

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
    vkbasalt \
    podman \
    toolbox \
    distrobox \
    && ostree container commit


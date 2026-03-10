# shellcheck shell=bash
# This script is meant to be sourced.
# It's not for directly running.

source ./installation/packages/install-deps.sh

showfun install-python-packages
v install-python-packages

function setup_user_groups() {
    if [[ -z $(getent group i2c) ]]; then
        x sudo groupadd i2c
    fi
    x sudo usermod -aG video,i2c,input "$(whoami)"
    v bash -c "echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf"
    v sudo chsh -s /usr/bin/fish rafael
}

function setup_systemd_services() {
    # When $DBUS_SESSION_BUS_ADDRESS and $XDG_RUNTIME_DIR are empty, it commonly means that the current user has been logged in with `su - user` or `ssh user@hostname`. In such case `systemctl --user enable <service>` is not usable. It should be `sudo systemctl --machine=$(whoami)@.host --user enable <service>` instead.
    if [[ ! -z "${DBUS_SESSION_BUS_ADDRESS}" ]]; then
        v systemctl --user enable ydotool --now
    else
        v sudo systemctl --machine=$(whoami)@.host --user enable ydotool --now
    fi
    v sudo systemctl enable sddm
    v sudo systemctl enable bluetooth --now
}

function setup_desktop_settings(){
    if command -v gsettings &>/dev/null; then
        v gsettings set org.gnome.desktop.interface font-name 'Google Sans Medium 11 @opsz=11,wght=500'
        v gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        v gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
        v gsettings set org.gnome.desktop.interface icon-theme 'OneUI-dark'
        v gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
        v gsettings set org.gnome.desktop.interface cursor-size 24
    fi

    mkdir -p "${XDG_CONFIG_HOME}/Kvantum"
    echo -e "[General]\ntheme=MaterialAdw" > "${XDG_CONFIG_HOME}/Kvantum/kvantum.kvconfig"

    if command -v dconf &>/dev/null; then
        dconf write /org/gnome/nautilus/preferences/default-folder-viewer "'list-view'" 2>/dev/null || true
        dconf write /org/gnome/nautilus/list-view/use-tree-view true 2>/dev/null || true
        dconf write /org/gnome/nautilus/list-view/default-zoom-level "'small'" 2>/dev/null || true
        dconf write /org/gnome/nautilus/list-view/default-visible-columns "['name', 'size', 'type', 'date_modified']" 2>/dev/null || true
        dconf write /org/gnome/nautilus/list-view/default-column-order "['name', 'size', 'type', 'owner', 'group', 'permissions', 'date_modified', 'date_accessed', 'date_created', 'recency', 'detailed_type']" 2>/dev/null || true
        dconf write /org/gnome/nautilus/preferences/show-hidden-files false 2>/dev/null || true
        dconf write /org/gnome/nautilus/preferences/date-time-format "'simple'" 2>/dev/null || true
        # Window size
        dconf write /org/gnome/nautilus/window-state/initial-size "(1100, 700)" 2>/dev/null || true
    fi
}

showfun setup_user_groups
v setup_user_groups

showfun setup_systemd_services
v setup_systemd_services

showfun setup_desktop_settings
v setup_desktop_settings
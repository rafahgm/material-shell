# shellcheck shell=bash
# This script is meant to be sourced.
# It's not for directly running.

if [[ -z $(getent group i2c) ]]; then
  # On Fedora this is not needed. Tested with desktop computer with NVIDIA video card.
  x sudo groupadd i2c
fi

x sudo usermod -aG video,i2c,input "$(whoami)"

v bash -c "echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf"

# When $DBUS_SESSION_BUS_ADDRESS and $XDG_RUNTIME_DIR are empty, it commonly means that the current user has been logged in with `su - user` or `ssh user@hostname`. In such case `systemctl --user enable <service>` is not usable. It should be `sudo systemctl --machine=$(whoami)@.host --user enable <service>` instead.
if [[ ! -z "${DBUS_SESSION_BUS_ADDRESS}" ]]; then
    v systemctl --user enable ydotool --now
else
    v sudo systemctl --machine=$(whoami)@.host --user enable ydotool --now
fi

v sudo chsh /usr/bin/fish rafael
v sudo systemctl enable sddm
v sudo systemctl enable bluetooth --now
v gsettings set org.gnome.desktop.interface font-name 'Google Sans Medium 11 @opsz=11,wght=500'
v gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

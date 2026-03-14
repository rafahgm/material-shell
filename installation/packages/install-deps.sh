install-paru(){
  x sudo pacman -S --needed --noconfirm base-devel rustup bat devtools
  x rustup default stable
  x git clone https://aur.archlinux.org/paru.git /tmp/buildparu
  x cd /tmp/buildparu
  x makepkg -o
  x makepkg -se
  x makepkg -i --noconfirm
  x cd ${REPO_ROOT}
  rm -rf /tmp/buildparu
}

if ! command -v pacman >/dev/null 2>&1; then
  printf "${STY_RED}[$0]: pacman not found, it seems that the system is not ArchLinux or Arch-based distros. Aborting...${STY_RST}\n"
  exit 1
fi

# Keep makepkg from resetting sudo credentials
if [[ -z "${PACMAN_AUTH:-}" ]]; then
  export PACMAN_AUTH="sudo"
fi

# Issue #363
case $SKIP_SYSUPDATE in
  true) sleep 0;;
  *) v sudo pacman -Syu;;
esac

if ! command -v paru >/dev/null 2>&1;then
  echo -e "${STY_YELLOW}[$0]: \"paru\" not found.${STY_RST}"
  showfun install-paru
  v install-paru
fi

install-local-pkgbuild() {
  local location=$1
  local installflags=$2

  x pushd $location

  source ./PKGBUILD
  x paru -S --sudoloop $installflags --asdeps "${depends[@]}"
  # man makepkg:
  # -A, --ignorearch: Ignore a missing or incomplete arch field in the build script.
  # -s, --syncdeps: Install missing dependencies using pacman. When build-time or run-time dependencies are not found, pacman will try to resolve them.
  # -f, --force: build a package even if it already exists in the PKGDEST
  # -i, --install: Install or upgrade the package after a successful build using pacman(8).
  # In https://github.com/end-4/dots-hyprland/issues/823#issuecomment-3394774645 it's suggested to use `sudo pacman -U --noconfirm *.pkg.tar.zst` instead of `makepkg -i`, however it's possible that multiple *.pkg.tar.zst exist, which makes this command not reliable.
  x makepkg -Afsi --noconfirm
  x popd
}

# Install core dependencies from the meta-packages
metapkgs=(./installation/packages/{audio,backlight,basic,fonts-themes,hyprland,portal,one-ui-icons,python,screencapture,toolkit,widgets,quickshell,utilities})

for i in "${metapkgs[@]}"; do
  metainstallflags="--needed"
  $ask && showfun install-local-pkgbuild || metainstallflags="$metainstallflags --noconfirm"
  v install-local-pkgbuild "$i" "$metainstallflags"
done

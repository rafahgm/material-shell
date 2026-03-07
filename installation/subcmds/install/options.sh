# Handle args for subcmd: install
# shellcheck shell=bash
showhelp(){
printf "Syntax: $0 install [OPTIONS]...

Idempotent installation for dotfiles.

Options for install:
  -h, --help                Print this help message and exit
  -f, --force               (Dangerous) Force mode without any confirm
  -F, --fisrtrun            Act like it is the first run
  -c, --clean               Clean the build cache first
      --skip-allgreeting    Skip the whole process greeting
      --skip-alldeps        Skip the whole process installing dependency
      --skip-allsetups      Skip the whole process setting up permissions/services etc
  -s, --skip-sysupdate      Skip system package upgrade e.g. \"sudo pacman -Syu\"
${STY_RST}"
}

cleancache(){
  rm -rf "${REPO_ROOT}/cache"
}

# `man getopt` to see more
para=$(getopt \
  -o hfFk:cs \
  -l help,force,firstrun,fontset:,clean,skip-allgreeting,skip-alldeps,skip-allsetups,skip-sysupdate \
  -n "$0" -- "$@")
[ $? != 0 ] && echo "$0: Error when getopt, please recheck parameters." && exit 1
#####################################################################################
## getopt Phase 1
# ignore parameter's order, execute options below first
eval set -- "$para"
while true ; do
  case "$1" in
    -h|--help) showhelp;exit;;
    -c|--clean) cleancache;shift;;
    --) shift;break ;;
    *) shift ;;
  esac
done
#####################################################################################
## getopt Phase 2

eval set -- "$para"
while true ; do
  case "$1" in
    ## Already processed in phase 1, but not exited
    -c|--clean) shift;;
    ## Ones without parameter
    -f|--force) ask=false;shift;;
    -F|--firstrun) INSTALL_FIRSTRUN=true;shift;;
    --skip-allgreeting) SKIP_ALLGREETING=true;shift;;
    --skip-alldeps) SKIP_ALLDEPS=true;shift;;
    --skip-allsetups) SKIP_ALLSETUPS=true;shift;;
    -s|--skip-sysupdate) SKIP_SYSUPDATE=true;shift;;

    ## Ending
    --) shift;break ;;
    *) echo -e "$0: Wrong parameters.";exit 1;;
  esac
done
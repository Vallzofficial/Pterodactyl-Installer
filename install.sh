#!/bin/bash

set -e
export GITHUB_SOURCE="v1.1.0"
export SCRIPT_RELEASE="v1.1.0"
export GITHUB_BASE_URL="https://raw.githubusercontent.com/vallzofficial/pterodactyl-installer"

# Cek untuk curl
if ! [ -x "$(command -v curl)" ]; then
  echo -e "* curl is required in order for this script to work."
  echo -e "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

# Ambil dan jalankan lib.sh
[ -f /tmp/lib.sh ] && rm -rf /tmp/lib.sh
curl -sSL -o /tmp/lib.sh "$GITHUB_BASE_URL/master/lib/lib.sh"
source /tmp/lib.sh

execute() {
  if [[ -n $2 ]]; then
    echo -e -n "* Installation of $1 completed. Do you want to proceed to $2 installation? (y/N): "
    read -r CONFIRM
    if [[ "$CONFIRM" =~ [Yy] ]]; then
      execute "$2"
    else
      error "Installation of $2 aborted."
      exit 1
    fi
  fi
}

welcome ""

# Kode warna ANSI
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
RESET="\e[0m"

# Fungsi untuk menampilkan teks bertahap dengan warna
display_step_by_step() {
    local text="$1"
    local color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -n -e "${color}${text:i:1}${RESET}"  # Tampilkan satu karakter dengan warna
        sleep 0.1                                  # Jeda 0.1 detik
    done
    echo  # Pindah ke baris berikutnya
}

display_step_by_step "Selamat datang di Pterodactyl Installer, By Vallzofficial!" "$GREEN"
display_step_by_step "Prosess menampilkan menu....." "$BLUE"

done=false
while [ "$done" == false ]; do
  options=(
    "Install Panel"
    "Install Wings"
  )

  actions=(
    "panel"
    "wings"
    "panel;wings"
    # "uninstall"

    "panel_canary"
    "wings_canary"
    "panel_canary;wings_canary"
    "uninstall_canary"
  )

  output "What would you like to do?"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue

  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && IFS=";" read -r i1 i2 <<<"${actions[$action]}" && execute "$i1" "$i2"
done

# Hapus lib.sh agar versi terbaru diunduh saat skrip dijalankan lagi.
rm -rf /tmp/lib.sh

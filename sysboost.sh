#!/bin/bash

# Vitor Cruz de Souza's General Purpose System Boost Script
# Version 1.2.0
# License: GPL v3.0

VERSION="1.2.0"

set -e

### Helper Functions ###
is_dryrun=false
dryrun() {
  $is_dryrun && echo "[dryrun] $*"
  ! $is_dryrun && eval "$@"
}

print_banner() {
  echo "╔══════════════════════════════════════════════╗"
  echo "║     🔧 sysboost.sh v$VERSION - Ubuntu Boost      ║"
  echo "║  ⚡ By Vitor Cruz de Souza | GPL 3.0 ⚡  ║"
  echo "╚══════════════════════════════════════════════╝"
}

detect_machine_type() {
  if grep -iq "battery" /sys/class/power_supply/*/type 2>/dev/null; then
    echo "laptop"
  else
    echo "desktop"
  fi
}

### Prompts ###
confirm() {
  read -rp "$1 [y/N]: " response
  [[ "$response" =~ ^[Yy]$ ]]
}

### Core Functions ###
system_cleanup() {
  echo "🔄 Updating and cleaning system..."
  dryrun sudo apt-get update
  dryrun sudo apt update
  dryrun sudo apt-get check
  dryrun sudo apt-get --purge autoremove -y
  dryrun sudo apt-get dist-upgrade -y
  dryrun sudo apt-get upgrade -y
  dryrun sudo apt upgrade -y
  dryrun sudo apt-get check
  dryrun sudo apt-get autoclean
  dryrun sudo apt-get clean
  dryrun sudo snap refresh
  dryrun sudo flatpak update
}

remove_temp_files() {
  if confirm "🧹 Do you want to remove temp files in /tmp and ~/.cache?"; then
    echo "🗑️ Cleaning temp files..."
    dryrun sudo rm -rf /tmp/*
    dryrun rm -rf ~/.cache/*
    dryrun sudo apt install bleachbit -y
  fi
}

disable_telemetry() {
  echo "🚫 Disabling telemetry and background reporting..."
  dryrun sudo systemctl disable apport.service --now
  dryrun sudo systemctl disable whoopsie.service --now
  dryrun sudo systemctl disable motd-news.timer --now
  dryrun sudo sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/motd-news
  dryrun sudo sed -i 's/ubuntu\.com/#ubuntu.com/' /etc/update-motd.d/90-updates-available
  echo "[*] Resolving \"metrics.ubuntu.com\" to localhost"
  dryrun sudo echo 127.0.0.1 www.metrics.ubuntu.com >>/etc/hosts
  dryrun sudo echo 127.0.0.1 metrics.ubuntu.com >>/etc/hosts
  echo "[*] Resolving \"popcon.ubuntu.com\" to localhost"
  dryrun sudo echo 127.0.0.1 www.popcon.ubuntu.com >>/etc/hosts
  dryrun sudo echo 127.0.0.1 popcon.ubuntu.com >>/etc/hosts
  dryrun sudo apt purge -y ubuntu-report popularity-contest apport whoopsie apport-symptoms >/dev/null 2>&1 && dryrun sudo apt-mark hold ubuntu-report popularity-contest apport whoopsie apport-symptoms
}

setup_firewall() {
  echo "🛡️ Setting up UFW firewall rules..."
  dryrun sudo ufw --force reset
  dryrun sudo ufw default allow outgoing
  dryrun sudo ufw default deny incoming
  dryrun sudo ufw logging off
  dryrun sudo ufw enable
}

replace_firefox_with_librewolf() {
  if confirm "🌐 Replace Firefox Snap with LibreWolf from official repo?"; then
    dryrun sudo snap remove firefox || true
    echo "🌎 Adding LibreWolf repo and installing..."
    dryrun sudo apt install curl gnupg -y
    curl https://deb.librewolf.net/keyring.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/librewolf.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/librewolf.gpg arch=amd64] http://deb.librewolf.net $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/librewolf.list > /dev/null
    dryrun sudo apt update
    dryrun sudo apt install librewolf -y
  fi
}

install_flatpak_snap_store() {
  if confirm "📦 Do you want full Flatpak, Snap and GNOME Software support?"; then
    echo "🛍️ Installing Snap/Flatpak support with GNOME Software..."
    dryrun sudo apt install gnome-software gnome-software-plugin-flatpak gnome-software-plugin-snap flatpak -y
    dryrun sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
}

enable_trim() {
  if confirm "💾 Enable periodic TRIM for SSDs (recommended)?"; then
    dryrun sudo systemctl enable fstrim.timer
  fi
}

enable_cpu_performance_mode() {
  if confirm "⚙️ Set CPU governor to 'performance'? (Better for desktops/sockets, may reduce battery life)"; then
    dryrun sudo apt install cpufrequtils -y
    echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
    dryrun sudo systemctl disable ondemand
    dryrun sudo systemctl enable cpufrequtils
  fi
}

install_gaming_tools() {
  if confirm "🎮 Enable gaming mode (GameMode, MangoHUD)?"; then
    dryrun sudo apt install gamemode mangohud -y
  fi
}

install_vm_tools() {
  if confirm "📦 Install VirtualBox support for VMs?"; then
    dryrun sudo apt install virtualbox virtualbox-ext-pack virtualbox-guest-additions-iso -y
  fi
}

show_version() {
  echo "sysboost.sh version $VERSION"
}

print_help() {
  echo "Usage: ./sysboost.sh [options]"
  echo ""
  echo "Options:"
  echo "  --clean         Run full cleanup & update steps"
  echo "  --harden        Apply security tweaks, telemetry disable, and firewall"
  echo "  --extras        Offer VM/gaming/SSD/cpu governor options"
  echo "  --store         Add Snap/Flatpak/GNOME store support"
  echo "  --librewolf     Replace Snap Firefox with LibreWolf"
  echo "  --all           Run all modules"
  echo "  --dryrun        Show what would happen without executing"
  echo "  -v, --version   Show script version"
  echo "  -h, --help      Show help"
}

### Main Entry Point ###
main() {
  print_banner
  machine_type=$(detect_machine_type)
  echo "💻 Detected machine type: $machine_type"

  while [[ "$1" != "" ]]; do
    case $1 in
      --clean) system_cleanup ;;
      --harden) disable_telemetry; setup_firewall ;;
      --extras) install_vm_tools; install_gaming_tools; enable_trim; enable_cpu_performance_mode; remove_temp_files ;;
      --store) install_flatpak_snap_store ;;
      --librewolf) replace_firefox_with_librewolf ;;
      --dryrun) is_dryrun=true ;;
      --all) system_cleanup; disable_telemetry; setup_firewall; install_flatpak_snap_store; replace_firefox_with_librewolf; install_vm_tools; install_gaming_tools; enable_trim; enable_cpu_performance_mode; remove_temp_files ;;
      -v|--version) show_version; exit 0 ;;
      -h|--help) print_help; exit 0 ;;
      *) echo "❌ Unknown option: $1"; print_help; exit 1 ;;
    esac
    shift
  done

  echo "✅ Done. Don't forget to reboot if major updates or kernel upgrades were installed."
}

main "$@"

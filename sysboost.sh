#!/bin/bash

# Vitor Cruz de Souza's General Purpose System Boost Script
# Version 1.3.3
# License: GPL v3.0

VERSION="1.3.3"
set -e

### Helper Functions ###
is_dryrun=false
dryrun() {
  $is_dryrun && echo "[dryrun] $*"
  ! $is_dryrun && eval "$@"
}

print_banner() {
  echo "╔═════════════════════════════════════════════════════════════╗"
  echo "║     🔧 sysboost.sh v$VERSION - Ubuntu Boost      ║"
  echo "║  ⚡ By Vitor Cruz de Souza | GPL 3.0 ⚡  ║"
  echo "╚═════════════════════════════════════════════════════════════╝"
}

detect_machine_type() {
  if grep -iq "battery" /sys/class/power_supply/*/type 2>/dev/null; then
    echo "laptop"
  else
    echo "desktop"
  fi
}

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
  dryrun sudo apt-get -f install
  dryrun sudo apt-get --purge autoremove -y
  dryrun sudo apt-get dist-upgrade -y
  dryrun sudo apt-get upgrade -y
  dryrun sudo apt upgrade -y
  dryrun sudo apt full-upgrade -y
  dryrun sudo apt-get check
  dryrun sudo apt-get autoclean
  dryrun sudo apt-get clean
  dryrun sudo snap refresh
  dryrun sudo flatpak update
}

install_restricted_packages() {
  if confirm "🎵 Do you want to install multimedia support (ubuntu-restricted-extras & addons)?"; then
    echo "🎶 Installing ubuntu-restricted-extras and ubuntu-restricted-addons..."
    dryrun sudo apt install ubuntu-restricted-extras ubuntu-restricted-addons -y
  fi
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
  for service in apport whoopsie motd-news.timer; do
    if systemctl list-unit-files | grep -q "$service"; then
      dryrun sudo systemctl disable "$service" --now || true
    fi
  done
  dryrun sudo sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/motd-news || true
  dryrun sudo sed -i 's/ubuntu\\.com/#ubuntu.com/' /etc/update-motd.d/90-updates-available || true
  {
    grep -q "metrics.ubuntu.com" /etc/hosts || echo "127.0.0.1 metrics.ubuntu.com" | sudo tee -a /etc/hosts
    grep -q "popcon.ubuntu.com" /etc/hosts || echo "127.0.0.1 popcon.ubuntu.com" | sudo tee -a /etc/hosts
  } || true
  pkgs="ubuntu-report popularity-contest apport whoopsie apport-symptoms"
  for pkg in $pkgs; do
    if dpkg -l | grep -q "^ii\s*$pkg"; then
      dryrun sudo apt purge -y "$pkg"
      dryrun sudo apt-mark hold "$pkg"
    fi
  done
}

setup_firewall() {
  echo "🛡️ Setting up UFW firewall rules..."
  dryrun sudo apt install ufw gufw -y
  dryrun sudo systemctl enable ufw
  dryrun sudo systemctl restart ufw
  dryrun sudo ufw --force reset
  dryrun sudo ufw default allow outgoing
  dryrun sudo ufw default deny incoming
  dryrun sudo ufw logging off
  dryrun sudo ufw enable
  dryrun sudo ufw reload
}

replace_firefox_with_librewolf() {
  if confirm "🌐 Replace Firefox Snap with LibreWolf from official repo?"; then
    dryrun sudo snap remove firefox || true
    echo "🌎 Adding LibreWolf repo and installing..."
    dryrun sudo apt update
    dryrun sudo apt install extrepo -y
    dryrun extrepo enable librewolf
    dryrun sudo apt update
    dryrun sudo apt install librewolf -y
  fi
}

install_flatpak_snap_store() {
  if confirm "📦 Do you want full Flatpak, Snap and GNOME Software support?"; then
    echo "🛜️ Installing Snap/Flatpak support with GNOME Software..."
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
    dryrun sudo systemctl disable ondemand || true
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
  echo "  --clean         🔄 Run full cleanup & update steps"
  echo "  --harden        🛡️ Disable telemetry & enable firewall"
  echo "  --vm            💾 Install VirtualBox support for VMs"
  echo "  --gaming        🎮 Install GameMode and MangoHUD"
  echo "  --trim          💾 Enable periodic TRIM for SSDs"
  echo "  --cpuperf       ⚙️ Set CPU governor to 'performance'"
  echo "  --cleantemp     🧹 Remove temp files from /tmp and ~/.cache"
  echo "  --multimedia    🎵 Install multimedia codecs and extras"
  echo "  --store         🛜️ Add Snap/Flatpak/GNOME Software support"
  echo "  --librewolf     🌐 Replace Snap Firefox with LibreWolf"
  echo "  --dryrun        🧪 Show what would happen without executing"
  echo "  --all           ⚡ Run all modules"
  echo "  -v, --version   🔢 Show script version"
  echo "  -h, --help      📖 Show this help message"
}

main() {
  print_banner
  machine_type=$(detect_machine_type)
  echo "💻 Detected machine type: $machine_type"

  while [[ "$1" != "" ]]; do
    case $1 in
      --clean) system_cleanup ;;
      --harden) disable_telemetry; setup_firewall ;;
      --vm) install_vm_tools ;;
      --gaming) install_gaming_tools ;;
      --trim) enable_trim ;;
      --cpuperf) enable_cpu_performance_mode ;;
      --cleantemp) remove_temp_files ;;
      --multimedia) install_restricted_packages ;;
      --store) install_flatpak_snap_store ;;
      --librewolf) replace_firefox_with_librewolf ;;
      --dryrun) is_dryrun=true ;;
      --all)
        system_cleanup
        disable_telemetry
        setup_firewall
        install_flatpak_snap_store
        replace_firefox_with_librewolf
        install_vm_tools
        install_gaming_tools
        enable_trim
        enable_cpu_performance_mode
        remove_temp_files
        install_restricted_packages
        ;;
      -v|--version) show_version; exit 0 ;;
      -h|--help) print_help; exit 0 ;;
      *) echo "❌ Unknown option: $1"; print_help; exit 1 ;;
    esac
    shift
  done

  echo "✅ Done. Don't forget to reboot if major updates or kernel upgrades were installed."
}

main "$@"

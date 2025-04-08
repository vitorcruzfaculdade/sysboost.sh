#!/bin/bash

# Vitor Cruz's General Purpose System Boost Script
# Version 1.3.8
# License: GPL v3.0

VERSION="1.3.8"
set -e

### Helper Functions ###
is_dryrun=false
dryrun() {
  $is_dryrun && echo "[dryrun] $*"
  ! $is_dryrun && eval "$@"
}

print_banner() {
  echo ""
  echo "┌─────────────────────────────────────────────────────────────┐"
  echo "│ 🛠️  sysboost.sh v$VERSION                                    "
  echo "│ 🚀 The Ultimate Ubuntu Booster for 24.04+                     "
  echo "│ 🔧 By Vitor Cruz · License: GPL v3.0                          "
  echo "└─────────────────────────────────────────────────────────────┘"
  echo ""
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
    if systemctl list-unit-files | grep -q "${service}"; then
      dryrun sudo systemctl disable "$service" --now || true
    fi
  done

  dryrun sudo sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/motd-news || true
  dryrun sudo sed -i 's/ubuntu\.com/#ubuntu.com/' /etc/update-motd.d/90-updates-available || true

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
    dryrun sudo extrepo enable librewolf
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
   if confirm "📦 Install latest VirtualBox from Oracle's official repo?"; then
    echo "🌐 Setting up Oracle VirtualBox repository..."
    dryrun wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo gpg --dearmor -o /usr/share/keyrings/oracle-virtualbox.gpg
    codename=$(lsb_release -cs)
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $codename contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    dryrun sudo apt update
    echo "📥 Installing latest VirtualBox and Extension Pack..."
    dryrun sudo apt install -y virtualbox-7.1
  fi
}

install_compression_tools() {
  if confirm "🗜️ Install support for common compressed file formats (zip, rar, 7z, xz, bz2, etc)?"; then
    echo "📦 Installing archive tools..."
    dryrun sudo apt install -y zip unzip rar unrar p7zip-full xz-utils bzip2 lzma 7zip-rar
  fi
}

suggest_preload() {
  total_ram_gb=$(free -g | awk '/^Mem:/{print $2}')
  echo "🧠 Detected RAM: ${total_ram_gb} GB"

  if [ "$total_ram_gb" -le 4 ]; then
    echo "⚠️  Your system has ${total_ram_gb} GB of RAM. Installing preload is not recommended as it might consume resources needed elsewhere."
  elif [ "$total_ram_gb" -le 8 ]; then
    if confirm "✅ Your system has ${total_ram_gb} GB RAM. Preload is likely to improve responsiveness. Install it?"; then
      dryrun sudo apt install preload -y
    fi
  elif [ "$total_ram_gb" -le 16 ]; then
    if confirm "ℹ️  Your system has ${total_ram_gb} GB RAM. Preload is optional and may help with app launch times. Install it?"; then
      dryrun sudo apt install preload -y
    fi
  else
    if confirm "💡 You have ${total_ram_gb} GB RAM. Preload is not necessary but harmless. Install anyway?"; then
      dryrun sudo apt install preload -y
    fi
  fi
}

show_version() {
  echo "sysboost.sh version $VERSION"
}

print_help() {
  echo "Usage: ./sysboost.sh [options]"
  echo ""
  echo "Options:"
  echo "  --clean           Run full cleanup & update steps"
  echo "  --harden          Apply security tweaks, disable telemetry, enable firewall"
  echo "  --vm              Install VirtualBox tools"
  echo "  --gaming          Install GameMode and MangoHUD"
  echo "  --trim            Enable SSD TRIM"
  echo "  --performance     Set CPU governor to 'performance'"
  echo "  --clean-temp      Remove temp/cache files and offer BleachBit"
  echo "  --media           Install multimedia codecs (restricted-extras)"
  echo "  --store           Add Flatpak, Snap, and GNOME Software support"
  echo "  --librewolf       Replace Snap Firefox with LibreWolf"
  echo "  --compression     Install archive format support (zip, rar, 7z, xz, etc)"
  echo "  --preload         Suggest and optionally install preload based on system RAM"
  echo "  --dryrun          Show commands without executing"
  echo "  --all             Run all modules"
  echo "  -v, --version     Show script version"
  echo "  -h, --help        Show help"
}

### Main Entry Point ###
main() {
  print_banner
  machine_type=$(detect_machine_type)
  echo "💻 Detected machine type: $machine_type"

  if [ $# -eq 0 ]; then
    print_help
    exit 0
  fi

  while [[ "$1" != "" ]]; do
    case $1 in
      --clean) system_cleanup ;;
      --harden) disable_telemetry; setup_firewall ;;
      --vm) install_vm_tools ;;
      --gaming) install_gaming_tools ;;
      --trim) enable_trim ;;
      --performance) enable_cpu_performance_mode ;;
      --clean-temp) remove_temp_files ;;
      --media) install_restricted_packages ;;
      --store) install_flatpak_snap_store ;;
      --librewolf) replace_firefox_with_librewolf ;;
      --compression) install_compression_tools ;;
      --preload) suggest_preload ;;
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
        suggest_preload
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

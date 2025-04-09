#!/bin/bash

# Vitor Cruz's General Purpose System Boost Script
# License: GPL v3.0

VERSION="1.6.1"
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
full_cleanup() {
  echo "🗑️ Cleaning temp files..."
  dryrun sudo apt update
  dryrun sudo apt install bleachbit -y
  dryrun sudo apt-get check
  dryrun sudo apt-get -f install -y
  dryrun sudo apt-get --purge autoremove -y
  dryrun sudo apt-get autoclean
  dryrun sudo apt-get clean
  dryrun sudo rm -rf /tmp/*
  dryrun rm -rf ~/.cache/*
}

system_update() {
  echo "🔄 Performing full system update"
  dryrun sudo apt update
  dryrun sudo apt-get update
  dryrun sudo apt-get check
  dryrun sudo apt-get -f install
  dryrun sudo apt-get dist-upgrade -y
  dryrun sudo apt upgrade -y
  dryrun sudo apt full-upgrade -y
  dryrun sudo snap refresh
  dryrun sudo flatpak update
}

install_restricted_packages() {
  if confirm "🎵 Do you want to install multimedia support (ubuntu-restricted-extras & addons)?"; then
    echo "🎶 Installing ubuntu-restricted-extras and ubuntu-restricted-addons..."
    dryrun sudo apt install ubuntu-restricted-extras ubuntu-restricted-addons -y
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

  for pkg in ubuntu-report popularity-contest apport whoopsie apport-symptoms; do
    if dpkg -l | grep -q "^ii\s*$pkg"; then
      dryrun sudo apt purge -y "$pkg"
      dryrun sudo apt-mark hold "$pkg"
    fi
  done
}

# Added code for checking and removing remote access servers
remove_remote_access_servers() {
  echo "🔐 Checking for remote access servers..."
  # List of common remote access servers
  remote_servers=("sshd" "xrdp" "vnc4server" "tightvncserver" "x11vnc")

  for server in "${remote_servers[@]}"; do
    if dpkg -l | grep -q "^ii\s*$server"; then
      echo "⚠️ Found $server installed."
      if confirm "Do you want to remove $server?"; then
        dryrun sudo apt purge -y "$server"
        dryrun sudo apt autoremove -y
        echo "$server has been removed."
      fi
    else
      echo "✔️ $server is not installed."
    fi
  done
}

setup_firewall() {
  echo "🛡️ Setting up UFW firewall rules..."

  if sudo ufw status | grep -q "Status: active"; then
    echo "🔒 UFW is already active."
    if ! confirm "🔁 Do you want to reconfigure the firewall?"; then
      echo "❌ Skipping firewall configuration."
      return
    fi
  else
    if ! confirm "🚫 Firewall is inactive. Do you want to enable and configure it now?"; then
      echo "❌ Skipping firewall setup."
      return
    fi
  fi

  dryrun sudo apt update
  dryrun sudo apt install ufw gufw -y
  dryrun sudo systemctl enable ufw
  dryrun sudo systemctl restart ufw
  dryrun sudo ufw --force reset
  dryrun sudo ufw default allow outgoing
  dryrun sudo ufw default deny incoming

  if confirm "📝 Do you want to enable UFW logging?"; then
    dryrun sudo ufw logging on
    log_status="enabled"
  else
    dryrun sudo ufw logging off
    log_status="disabled"
  fi

  dryrun sudo ufw reload
  echo "🧱 G/UFW firewall🔥 configured and enabled✅ — logging $log_status, incoming connections denied🚫."
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
  if confirm "⚙️ Set CPU governor to 'performance'?"; then
    dryrun sudo apt install cpufrequtils -y
    echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
    dryrun sudo systemctl disable ondemand || true
    dryrun sudo systemctl enable cpufrequtils
  fi
}

install_gaming_tools() {
  # 🎮 Gaming Utilities
  if confirm "🎮 Enable gaming mode (GameMode, MangoHUD)?"; then
    dryrun sudo apt install gamemode mangohud -y
    echo "🧪 Checking if gamemoded is running..."
    if systemctl is-active --quiet gamemoded; then
      echo "✅ GameMode is active and running."
    else
      echo "⚠️ GameMode is installed but not running. You may need to restart or check systemd services."
    fi
  fi

  # 🧠 GPU Detection
  gpu_info=$(lspci | grep -E "VGA|3D")
  if echo "$gpu_info" | grep -qi nvidia; then
    echo "🟢 NVIDIA GPU detected."
    if confirm "Install NVIDIA proprietary drivers?"; then
      dryrun sudo ubuntu-drivers autoinstall
      echo "✅ NVIDIA drivers installation triggered."
    fi
  elif echo "$gpu_info" | grep -qi amd; then
    echo "🔴 AMD GPU detected."
    if confirm "Install AMD Mesa graphics drivers?"; then
      dryrun sudo apt install mesa-vulkan-drivers mesa-utils -y
      echo "✅ AMD Mesa drivers installed."
    fi
  elif echo "$gpu_info" | grep -qi intel; then
    echo "🔵 Intel GPU detected."
    if confirm "Install Intel Mesa graphics drivers?"; then
      dryrun sudo apt install mesa-vulkan-drivers mesa-utils -y
      echo "✅ Intel Mesa drivers installed."
    fi
  else
    echo "❓ GPU vendor not recognized: $gpu_info"
  fi
 
  if confirm "🧱 Install Vulkan packages for Proton/DXVK support?"; then
    dryrun sudo apt install vulkan-tools mesa-vulkan-drivers vulkan-utils -y
    echo "✅ Vulkan support installed."
  fi

  # 🔌 Vulkan + 32-bit libs for Steam/Proton
  if confirm "📦 Install 32-bit libraries required for Steam & gaming?"; then
    dryrun sudo dpkg --add-architecture i386
    dryrun sudo apt update
    dryrun sudo apt install libc6:i386 libncurses6:i386 libstdc++6:i386 libgl1-mesa-glx:i386 libxss1:i386 libasound2:i386 -y
    echo "✅ 32-bit libraries installed for compatibility."
  fi

  # 🎮 Steam
  if confirm "🎮 Install Steam (official .deb release)?"; then
    tmp_deb="/tmp/steam_latest.deb"
    echo "🌐 Downloading Steam .deb from official servers..."
    dryrun wget -O "$tmp_deb" https://cdn.fastly.steamstatic.com/client/installer/steam.deb
    dryrun sudo apt install "$tmp_deb" -y
    dryrun sudo apt update
    dryrun sudo apt -f install -y
    dryrun rm -f "$tmp_deb"
    echo "✅ Steam installed from official .deb package (dependencies resolved)."
  fi
}

install_vm_tools() {
  if confirm "📦 Install latest VirtualBox from Oracle's official repo?"; then
    dryrun wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo gpg --dearmor -o /usr/share/keyrings/oracle-virtualbox.gpg
    codename=$(lsb_release -cs)
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $codename contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    dryrun sudo apt update
    dryrun sudo apt install -y virtualbox-7.1
  fi
}

install_compression_tools() {
  if confirm "🗜️ Install support for compressed file formats (zip, rar, 7z, xz, bz2, etc)?"; then
    dryrun sudo apt install -y zip unzip rar unrar p7zip-full xz-utils bzip2 lzma 7zip-rar
  fi
}

install_remmina() {
  if confirm "🖥️ Install Remmina (remote desktop client with full plugin support)?"; then
    echo "📦 Installing Remmina and plugins..."
    dryrun sudo apt update
    dryrun sudo apt install remmina remmina-plugin-rdp remmina-plugin-vnc remmina-plugin-secret remmina-plugin-spice remmina-plugin-exec -y
    echo "✅ Remmina installed with full client support — no server components."
  fi
}

suggest_preload_and_zram() {
  total_ram_gb=$(free -g | awk '/^Mem:/{print $2}')
  machine_type=$(detect_machine_type)
  echo "🧠 Detected RAM: ${total_ram_gb} GB"
  echo "💻 Machine type: $machine_type"

  case $total_ram_gb in
    [0-2])
      echo "🟥 Low RAM detected (≤2GB): ZRAM is recommended. Preload is not advised."
      if confirm "💾 Enable ZRAM (compressed RAM swap)?"; then
        dryrun sudo apt install zram-tools -y
        echo "ALGO=zstd" | sudo tee /etc/default/zramswap
        echo "✅ ZRAM enabled. Reboot to apply."
      fi
      ;;
    [3-4])
      echo "🟧 Low RAM (3–4GB): ZRAM strongly recommended. Preload not advised."
      if confirm "💾 Enable ZRAM (compressed RAM swap)?"; then
        dryrun sudo apt install zram-tools -y
        echo "ALGO=zstd" | sudo tee /etc/default/zramswap
        echo "✅ ZRAM enabled. Reboot to apply."
      fi
      ;;
    [5-8])
      echo "🟨 Moderate RAM (5–8GB): Preload and ZRAM can both improve performance."
      if confirm "📦 Install preload to speed up app launches?"; then
        dryrun sudo apt install preload -y
      fi
      if confirm "💾 Enable ZRAM (compressed RAM swap)?"; then
        dryrun sudo apt install zram-tools -y
        echo "ALGO=zstd" | sudo tee /etc/default/zramswap
        echo "✅ ZRAM enabled. Reboot to apply."
      fi
      ;;
    [9-9]|1[0-6])
      echo "🟩 High RAM (9–16GB): Preload may help, ZRAM is optional."
      if confirm "📦 Install preload to speed up app launches?"; then
        dryrun sudo apt install preload -y
      fi
      if confirm "💾 Enable ZRAM (optional)?"; then
        dryrun sudo apt install zram-tools -y
        echo "ALGO=zstd" | sudo tee /etc/default/zramswap
        echo "✅ ZRAM enabled. Reboot to apply."
      fi
      ;;
    *)
      echo "🟦 Plenty of RAM (>16GB): Preload and ZRAM likely unnecessary, but optional."
      if confirm "📦 Install preload anyway?"; then
        dryrun sudo apt install preload -y
      fi
      if confirm "💾 Enable ZRAM anyway?"; then
        dryrun sudo apt install zram-tools -y
        echo "ALGO=zstd" | sudo tee /etc/default/zramswap
        echo "✅ ZRAM enabled. Reboot to apply."
      fi
      ;;
  esac
}

show_donation_info() {
  echo ""
  echo "     .-. .-.   "
  echo "    (   |   )  💖 Thanks for using sysboost.sh!"
  echo "     \\     /   If you'd like to support this project,"
  echo "      \\   /    visit my Linktree below:"
  echo "       \`-’     "
  echo ""
  echo "🔗 https://linktr.ee/vitorcruzcode"
  echo ""

  if ! $is_dryrun; then
    xdg-open "https://linktr.ee/vitorcruzcode" >/dev/null 2>&1 &
  else
    echo "[dryrun] xdg-open https://linktr.ee/vitorcruzcode"
  fi
}

show_version() {
  echo "sysboost.sh version $VERSION"
}

print_help() {
  echo "Usage: ./sysboost.sh [options]"
  echo ""
  echo "Options:"
  echo "  --clean           Full cleanup and temp file clearing"
  echo "  --update          Run update only (no cleanup)"
  echo "  --harden          Apply security tweaks, disable telemetry, enable firewall"
  echo "  --vm              Install VirtualBox tools"
  echo "  --gaming          Gaming tools, Vulkan, drivers, Steam & FPS tweaks"
  echo "  --trim            Enable SSD TRIM"
  echo "  --performance     Set CPU governor to 'performance'"
  echo "  --media           Install multimedia codecs (restricted-extras)"
  echo "  --store           Add Flatpak, Snap, and GNOME Software support"
  echo "  --librewolf       Replace Snap Firefox with LibreWolf"
  echo "  --compression     Install archive format support (zip, rar, 7z, etc)"
  echo "  --remmina         Install Remmina client with full plugin support (RDP, VNC, etc)"
  echo "  --preload         Suggest and optionally install preload & ZRAM"
  echo "  --donate          Show donation info and open Linktree in browser"
  echo "  --dryrun          Show commands without executing"
  echo "  --all             Run all modules"
  echo "  -v, --version     Show script version"
  echo "  -h, --help        Show help"
}

### Main Entry Point ###
main() {
  print_banner
  echo "💻 Detected machine type: $(detect_machine_type)"

  if [[ $# -eq 0 ]]; then
    print_help
    exit 0
  fi

    while [[ $# -gt 0 ]]; do
    case "$1" in
      --clean) full_cleanup ;;
      --update) system_update ;;
      --harden) disable_telemetry; remove_remote_access_servers; setup_firewall ;;
      --vm) install_vm_tools ;;
      --gaming) install_gaming_tools ;;
      --trim) enable_trim ;;
      --performance) enable_cpu_performance_mode ;;
      --media) install_restricted_packages ;;
      --store) install_flatpak_snap_store ;;
      --librewolf) replace_firefox_with_librewolf ;;
      --compression) install_compression_tools ;;
      --remmina) install_remmina_with_plugins ;;
      --preload) suggest_preload_and_zram ;;
      --donate) show_donation_info ;;
      --dryrun) is_dryrun=true ;;
      --all)
        full_cleanup
        system_update
        disable_telemetry
        remove_remote_access_servers
        setup_firewall
        install_flatpak_snap_store
        replace_firefox_with_librewolf
        install_vm_tools
        install_gaming_tools
        install_remmina_with_plugins
        enable_trim
        enable_cpu_performance_mode
        install_restricted_packages
        install_compression_tools
        suggest_preload_and_zram
        show_donation_info
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

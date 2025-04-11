#!/bin/bash

# Vitor Cruz's General Purpose System Boost Script
# License: GPL v3.0

VERSION="1.6.20"
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
  echo "🌐 Updating instalation cache..."
  dryrun sudo apt update
  echo "🧽 Installing Bleachbit Cleaner..."
  dryrun sudo apt install bleachbit -y
  echo "🌐 Checking for broken dependencies..."
  dryrun sudo apt-get check
  echo "🛠️ Fixing broken dependencies (if any)..."
  dryrun sudo apt-get -f install -y
  echo "🧹 Cleaning useless packages"
  dryrun sudo apt-get --purge autoremove -y
  echo "🧹 Cleaning apt-get cache ..."
  dryrun sudo apt-get autoclean
  dryrun sudo apt-get clean
  echo "🗑️ Cleaning temporary files..."
  dryrun sudo rm -rf /tmp/*
  dryrun rm -rf ~/.cache/*
  echo "✅ Package and temporary files clean!🗑️"
}

system_update() {
  echo "🌐 Updating instalation cache..."
  dryrun sudo apt update
  dryrun sudo apt-get update
  echo "🌐 Checking for broken dependencies..."
  dryrun sudo apt-get check
  dryrun sudo apt-get -f install
  echo "🔄 Performing full system update..."
  dryrun sudo apt-get dist-upgrade -y
  dryrun sudo apt upgrade -y
  dryrun sudo apt full-upgrade -y
  echo "🔄 Performing Snap packages update..."
  dryrun sudo snap refresh
  echo "🔄 Performing Flatpak update..."
  dryrun sudo flatpak update
  echo "✅ Everything updated!"
}

install_restricted_packages() {
  if confirm "🎵 Do you want to install multimedia support (ubuntu-restricted-extras & addons)?"; then
    echo "🎶 Installing ubuntu-restricted-extras, ubuntu-restricted-addons and extended GStreamer plugins..."
    dryrun sudo apt install ubuntu-restricted-extras ubuntu-restricted-addons gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav -y

    if confirm "📽️ Do you also want to install GNOME Videos (Totem)?"; then
      echo "🎞️ Installing GNOME Videos (Totem)..."
      dryrun sudo apt install totem totem-common totem-plugins -y

      if confirm "🎯 Set Totem as the default video player?"; then
        echo "🔧 Setting Totem as the default video player for common formats..."
        formats=("video/mp4" "video/x-matroska" "video/x-msvideo" "video/x-flv" "video/webm" "video/ogg")
          for format in "${formats[@]}"; do
            dryrun xdg-mime default org.gnome.Totem.desktop "$format"
          done
      fi
    fi
# Offer to install Spotify via Snap
if prompt_confirm "🎧 Do you want to install Spotify (Snap version)? Spotify is a popular music streaming service. This installs the official Snap version."; then
    echo "🎶 Installing Spotify (official Snap version)..."
    dryrun sudo snap install spotify
    echo "✅ Spotify (official Snap version) installed."
  fi
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
  echo "🚫 Telemetry and background reporting fully disabled ✅"
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

  echo "🌐 Updating installation cache..."
  dryrun sudo apt update
  echo "🌐 Installing 🧱🔥 UFW/GUFW..."
  dryrun sudo apt install ufw gufw -y
  echo "🔧 Enabling 🧱🔥 UFW/GUFW..."
  dryrun sudo systemctl enable ufw
  echo "🔧 Restarting/Reseting 🧱🔥 UFW/GUFW..."
  dryrun sudo systemctl restart ufw
  dryrun sudo ufw --force reset
  echo "🔧 Setting pretty sick block rule from outside 🧱🔥 UFW/GUFW..."
  dryrun sudo ufw default deny incoming
  echo "✅Denied incomming traffic (from outside) 🧱🔥 UFW/GUFW."
  echo "🔧 Allowing conections started from this system to outside..."
  dryrun sudo ufw default allow outgoing
  echo "✅ Allowed outgoing traffic 🧱🔥 UFW/GUFW."
  echo "🔧 Enabling and applying settings to 🧱🔥 UFW/GUFW..."
  dryrun sudo ufw enable
  echo "✅ Enabled 🧱🔥 UFW/GUFW."
  echo "⚙️ Reloading 🧱🔥 UFW/GUFW..."
  dryrun sudo ufw reload
  echo "✅ Reloaded 🧱🔥 UFW/GUFW."
  
  if confirm "📝 Do you want to enable UFW logging?"; then
    dryrun sudo ufw logging on
    log_status="enabled"
    echo "✅ UFW logging on 📝"
  else
    dryrun sudo ufw logging off
    log_status="disabled"
    echo "✅ UFW logging off 📝"
  fi

  dryrun sudo ufw reload
  echo "🧱 G/UFW Firewall🔥 configured and enabled ✅ — logging $log_status, incoming connections denied 🚫."
}

replace_firefox_with_librewolf() {
  if confirm "🌐 Replace Firefox Snap with LibreWolf its from official repo?"; then
    dryrun sudo snap remove firefox || true
    echo "🌐 Adding LibreWolf repo..."
    dryrun sudo apt update
    dryrun sudo apt install extrepo -y
    dryrun sudo extrepo enable librewolf
    echo "🌐 Updating instalation cache..."
    dryrun sudo apt update
    echo "🌐 Installing LibreWolf..."
    dryrun sudo apt install librewolf -y
    echo "✅ Librewolf installed."
  fi
}

install_chrome() {
    echo "🧭 Google Chrome (from official repository)"
    local prompt_text="Do you want to install Google Chrome (Stable) using the official repository?"
    if prompt_user "$prompt_title" "$prompt_text"; then
        dryrun wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
        dryrun sudo echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
        echo "🌐 Updating instalation cache..."
        dryryn sudo apt update
        echo "🧭 Installing Google Chrome..."
        dryrun sudo apt install google-chrome-stable -y

        if prompt_user "🧭 Set Chrome as default browser?" "Do you want to make Google Chrome your default browser?"; then
            dryrun xdg-settings set default-web-browser google-chrome.desktop
        fi
        echo "✅ Google Chrome installed and configured."
    else
        echo "❎ Skipped Google Chrome installation."
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
  if confirm "✂️ Enable periodic TRIM for SSDs (recommended)?"; then
    dryrun sudo systemctl enable fstrim.timer
    echo "✅ Timer service for TRIM enabled."
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
      echo "🌐 Updating instalation cache..."
      dryrun sudo apt update
      echo "🌐 Updating system..."
      dryrun sudo apt upgrade -y
      echo "🌐 Adding some packages to improve GPU compatibility"
      dryrun sudo apt install mesa-vulkan-drivers mesa-utils vulkan-tools -y
      echo "🌐 Installing NVIDIA drivers using Ubuntu-Drivers..."
      dryrun sudo ubuntu-drivers autoinstall
      echo "✅ NVIDIA drivers installation triggered."
    fi
  elif echo "$gpu_info" | grep -qi amd; then
    echo "🔴 AMD GPU detected."
    if confirm "Install AMD Mesa graphics drivers?"; then
      dryrun sudo apt install mesa-vulkan-drivers mesa-utils vulkan-tools -y
      echo "✅ AMD Mesa drivers installed."
    fi
  elif echo "$gpu_info" | grep -qi intel; then
    echo "🔵 Intel GPU detected."
    if confirm "Install Intel Mesa graphics drivers?"; then
      dryrun sudo apt install mesa-vulkan-drivers mesa-utils vulkan-tools -y
      echo "✅ Intel Mesa drivers installed."
    fi
  elif echo "$gpu_info" | grep -qi vmware; then
    echo "🟠 VMware or VirtualBox GPU detected."
    if confirm "Install Virtual Machine GPU drivers?"; then
      echo "🌐 Updating instalation cache..."    
      dryrun sudo apt update
      echo "🌐 Updating system..."
      dryrun sudo apt upgrade -y
      echo "🌐 Adding some packages to improve GPU compatibility and Open-VM-Tools..."
      dryrun sudo apt install mesa-vulkan-drivers mesa-utils vulkan-tools open-vm-tools -y
      echo "🌐 Installing VM additional drivers using Ubuntu-Drivers (if any)..."
      dryrun sudo ubuntu-drivers autoinstall
      echo "✅ VM GPU drivers installed."
    fi
  else
    echo "❓ GPU vendor not recognized: $gpu_info"
  fi

  # 🔌 Vulkan + Proton/DXVK
  if confirm "🧱 Install Vulkan packages for Proton/DXVK support?"; then
    dryrun sudo apt install mesa-vulkan-drivers mesa-utils vulkan-tools -y
    echo "✅ Vulkan support installed."
  fi
  
  # 🎮 Steam + 32-bit lib support
  if confirm "🎮 Install Steam (official .deb release)?"; then
    tmp_deb="/tmp/steam_latest.deb"
    dryrun sudo dpkg --add-architecture i386
    echo "🌐 Downloading Steam .deb from official servers..."
    dryrun wget -O "$tmp_deb" https://cdn.fastly.steamstatic.com/client/installer/steam.deb
    dryrun sudo apt install "$tmp_deb" -y
    echo "🌐 Updating instalation cache..." 
    dryrun sudo apt update
    echo "🛠️ Fixing dependencies (always happen with Steam deb)..." 
    dryrun sudo apt -f install -y
    echo "🧹 Cleaning temp..." 
    dryrun rm -f "$tmp_deb"
    echo "✅ Steam installed from official .deb package (dependencies resolved)."
  fi
}

install_vm_tools() {
  if confirm "📦 Install latest VirtualBox from Oracle's official repo?"; then
    echo "🌐 Obtaining key from Oracle..." 
    dryrun wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo gpg --dearmor -o /usr/share/keyrings/oracle-virtualbox.gpg
    codename=$(lsb_release -cs)
    echo "🌐 Adding key and repository information..." 
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $codename contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    echo "🌐 Updating instalation cache..." 
    dryrun sudo apt update
    echo "🌐 Installing Virtualbox..."
    dryrun sudo apt install -y virtualbox-7.1
    echo "✅ Virtualbox installed."
  fi
}

install_compression_tools() {
  if confirm "🗜️ Install support for compressed file formats (zip, rar, 7z, xz, bz2, etc)?"; then
    dryrun sudo apt install zip unzip rar unrar p7zip-full xz-utils bzip2 lzma 7zip-rar -y 
  fi
}

setup_sysadmin_tools() {
  echo "🛠️ Preparing sysadmin tools setup..."
  if confirm "📡 Install Remmina (GUI 🪟 - remote desktop client with full plugin support)?"; then
    echo "📡 Installing Remmina..."
    dryrun apt install remmina remmina-plugin-rdp remmina-plugin-vnc remmina-plugin-secret remmina-plugin-spice remmina-plugin-exec -y || echo "⚠️ Remmina installation failed."
  fi

  if confirm "📊 Install htop (CLI 🖥️ - interactive process viewer)?"; then
    dryrun sudo apt install htop -y
  fi

  if confirm "📷 Install screenfetch (CLI 🖥️ - display system info with ASCII logo)?"; then
    dryrun sudo apt install screenfetch -y
  fi

  if confirm "🖥️ Install guake (GUI 🪟 - dropdown terminal for GNOME)?"; then
    dryrun sudo apt install guake -y
  fi

  if confirm "🔐 Install OpenSSH Client (CLI 🖥️ - secure remote terminal access)?"; then
    dryrun sudo apt install openssh-client -y
  fi

  if confirm "🔁 Install lftp (CLI 🖥️ - advanced FTP/HTTP client with scripting support)?"; then
    dryrun sudo apt install lftp -y
  fi

  if confirm "📡 Install telnet (CLI 🖥️ - basic network protocol testing tool)?"; then
    dryrun sudo apt install telnet -y
  fi

  if confirm "🛰️ Install traceroute (CLI 🖥️ - trace path to a network host)?"; then
    dryrun sudo apt install traceroute -y
  fi

  if confirm "📍 Install mtr (CLI 🖥️ - real-time network diagnostic tool)?"; then
    dryrun sudo apt install mtr -y
  fi

  if confirm "🌐 Install whois (CLI 🖥️ - domain and IP ownership lookup)?"; then
    dryrun sudo apt install whois -y
  fi

  if confirm "🧠 Install dnsutils (CLI 🖥️ - includes dig, nslookup, etc.)?"; then
    dryrun sudo apt install dnsutils -y
  fi

  if confirm "🧪 Install nmap (CLI 🖥️ - network scanner and discovery tool)?"; then
    dryrun sudo apt install nmap -y
  fi

  if confirm "🔬 Install Wireshark (GUI 🪟 - network packet analyzer)?"; then
    dryrun sudo apt install wireshark -y
    echo "⚠️ Note: You may need to add your user to the 'wireshark' group to capture packets without sudo."
  fi
  echo "✅ Sysadmin tool installation process completed."
}

install_remmina() {
  if confirm "🖥️ Install Remmina (remote desktop client with full plugin support)?"; then
    echo "🌐 Updating instalation cache..."
    dryrun sudo apt update
    echo "📦 Installing Remmina and plugins..."
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
  echo "  Options:"
  echo "  --clean          🧹 Full cleanup and temp file clearing"
  echo "  --update         🔄 Run update only (no cleanup)"
  echo "  --harden         🔐 Apply security tweaks, disable telemetry, enable firewall"
  echo "  --vm             🖥️  Install VirtualBox tools"
  echo "  --gaming         🎮 Gaming tools, Vulkan, drivers, Steam & FPS tweaks"
  echo "  --trim           ✂️  Enable SSD TRIM"
  echo "  --performance    ⚡ Set CPU governor to 'performance'"
  echo "  --media          🎵 Install multimedia codecs (restricted-extras)"
  echo "  --store          🛍️  Add Flatpak, Snap, and GNOME Software support"
  echo "  --librewolf      🦊 Replace Snap Firefox with LibreWolf"
  echo "  --chrome         🌐 Install Google Chrome from the official repository"
  echo "  --compression    📦 Install archive format support (zip, rar, 7z, etc)"
  echo "  --sysadmin       🧰 Install Remmina and useful system/network tools for sysadmins"
  echo "  --remmina        🖧 Install Remmina client with full plugin support (RDP, VNC, etc)"
  echo "  --preload        🧠 Suggest and optionally install preload & ZRAM"
  echo "  --donate         ❤️ Show donation info and open Linktree in browser"
  echo "  --dryrun         🧪 Show commands without executing"
  echo "  --all            🚀 Run all modules"
  echo "  -v, --version    ℹ️  Show script version"
  echo "  -h, --help       📖 Show help"
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
      --chrome) install_chrome ;;
      --compression) install_compression_tools ;;
      --sysadmin) setup_sysadmin_tools ;;
      --remmina) install_remmina ;;
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
        install_vm_tools
        install_gaming_tools
        install_sysadmin_tools
        install_remmina
        enable_trim
        enable_cpu_performance_mode
        install_restricted_packages
        install_compression_tools
        replace_firefox_with_librewolf
        install_chrome
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

# Run main function
main "$@"

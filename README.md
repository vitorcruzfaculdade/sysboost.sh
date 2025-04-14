⚡ sysboost.sh - Optimize. Harden. Upgrade.
**Version:** 1.7.25  
**Author:** Vitor Cruz  
**License:** GPL v3.0  
**Scope:** Ubuntu 24.04+ (GNOME) — Laptops, Desktops & VMs  
*(Not recommended for servers due to reliance on GUI apps)*

---

## 🧰 What is sysboost?

`sysboost.sh` is your open-source, all-in-one command-line ally to clean, speed up, secure, and enhance your Ubuntu LTS (GNOME) system — without breaking things.

It uses **only official Ubuntu repositories** or trusted sources — no sketchy downloads, no surprises. Every line is human-readable and auditable.

From disabling telemetry and junk cleanup to boosting gaming performance, supporting virtualization, compression formats, l
- 🎮 **Gaming-Ready**: GameMode, MangoHUD, Vulkan, drivers for Intel/AMD/NVIDIA, Steam — and tweaks for maximum FPS.
- 💾 **SSD Friendly**: Enable periodic TRIM with `fstrim.timer`.
- ⚙️ **CPU Performance Mode**: Enable "performance" governor for desktops.
- 🎵 **Multimedia Support**: Install `ubuntu-restricted-extras` and codecs.
- 🌐 **App Store Boost**: Enable Flatpak + Snap + GNOME Software.
- 🦊 **Firefox Rebellion**: Replace Snap Firefox with LibreWolf from its official APT repo.
- 📦 **Compression Support**: Install support for ZIP, RAR, 7z, tar.xz, bzip2, and more.
- 🔁 **Preload & ZRAM**: Suggests `preload` or sets up ZRAM based on system RAM & hardware.
- 🖥️ **SysAdmin Remote Access**: `--remmina` – Installs Remmina with full plugin support (remote desktop client).
  
---

## 🧪 Usage

```bash
# Make it executable:
chmod +x sysboost.sh

# Run all modules (except dry-run)
./sysboost.sh --all

# Example: Gaming Laptop Boost
./sysboost.sh --clean --harden --gaming --trim --media --compression
```

## 📦 Modular Options
```bash
  Option           Description

  --clean          Clean junk, fix broken deps, remove Snap leftovers
  --tempclean      Clean /tmp, ~/.cache, and install BleachBit
  --update         Update package lists and upgrade system (safe apt update + upgrade)
  --harden         Disable telemetry, crash reports, and enable UFW with GUI
  --vm             Install VirtualBox guest additions and DKMS modules
  --gaming         Install GameMode, MangoHUD, and check if GameMode is active
  --trim           Enable SSD TRIM support with fstrim.timer
  --cpuperf        Set CPU governor to "performance" (recommended for desktops)
  --media          Install ubuntu-restricted-extras, codecs, Microsoft fonts
  --store          Enable Flatpak, Snap, and GNOME Software
  --librewolf      Replace Firefox Snap with LibreWolf via official APT repo
  --compression    Install zip, unzip, rar, unrar, 7z, xz-utils, bzip2, and lzma
  --preload        Detect RAM and hardware to suggest preload or configure ZRAM
  --remmina        Install Remmina with full plugin support (remote desktop client)
  --donate         Show donation options and author linktree
  --dryrun         Preview what each option will do (no actual changes)
  --all            Run all modules except --dryrun
  -v,  --version   Show current script version
  -h,  --help      Show help message
```

## 🛡️ License
This project is licensed under the GNU GPL v3.0.
See the LICENSE file or visit:
👉 https://www.gnu.org/licenses/gpl-3.0.html

## 👤 Credits
Crafted with 💻 + ☕ by Vitor Cruz
- Pull requests, forks, and stars and/or donations are always welcome 🌟

## 👋 Follow & Support
Want to support my work, check more tools, or donate?
## 👉 https://linktr.ee/vitorcruzcode

## ⚠️ Disclaimer
This script modifies system-level settings and installs packages.
Use at your own risk. Always make a backup or snapshot beforehand.
No guarantees — just results.
anguage packs, and now even **Office suite setup** — `sysboost.sh` adapts to your needs.

> ⚠️ Based on personal preferences. Review & back up your system before use.

---

## 🔥 Features (Modular & Optional)

✅ **Dry-Run Mode** — Preview all actions before execution  
🧼 **Update & Deep Clean** — Update all packages, fix broken deps, remove leftovers  
🧹 **Temp File Wipe** — Clean `/tmp`, `~/.cache`, and install **BleachBit** GUI  
🔐 **Privacy First** — Disable telemetry, crash reports, background reporting  
🛡️ **Firewall Setup** — Enable UFW with deny-in/allow-out and **GUFW**  
🖥️ **Virtualization Mode** — Full **VirtualBox** support w/ kernel modules  
🎮 **Gaming Tools** — GameMode, MangoHUD, Vulkan, drivers, **Steam**, DXVK  
💾 **SSD Friendly** — Enable **TRIM** support with `fstrim.timer`  
⚙️ **Performance Mode** — Set CPU governor to **performance**  
🎵 **Multimedia Support** — `ubuntu-restricted-extras`, codecs, MS fonts  
🌐 **App Store Setup** — Enable **Flatpak**, **Snap**, and **GNOME Software**  
🦊 **Firefox Rebellion** — Replace Snap Firefox with **LibreWolf (APT)**  
📦 **Compression Support** — zip, rar, 7z, xz, bzip2, lzma, and more  
🔁 **ZRAM & Preload Detection** — Suggest based on your RAM size  
🖧 **SysAdmin Tools** — Install **Remmina**, **Wireshark**, CLI diagnostics  
📝 **Office Suite Installer** — Choose between **LibreOffice** and **OnlyOffice**, with default MIME config and locale detection 🌍  
🧠 **Smart Update Logic** — Detect missing Flatpak/Snap before trying to update them  
❤️ **Donation Info** — Friendly Linktree page for support

---

## 🧪 Usage

```bash
# Make it executable
chmod +x sysboost.sh

# Run all modules (interactive, no dryrun)
./sysboost.sh --all

# Example: Secure and clean gaming setup
./sysboost.sh --clean --harden --gaming --media --trim --compression
```

## 📦 Modular Options

```bash
  Option	     Description
--clean        Clean junk files, fix broken deps, remove old packages
--update       Update package lists, Snap, and Flatpak (with detection)
--harden	     Disable telemetry, remove remote access tools, enable UFW firewall
--vm           Install latest VirtualBox from Oracle repo
--gaming       Install GameMode, MangoHUD, Steam, Vulkan, GPU drivers
--trim         Enable SSD TRIM with fstrim.timer
--performance  Set CPU to performance mode
--media	       Install codecs, ubuntu-restricted-extras, GStreamer plugins
--store	       Enable Flatpak, Snap, and GNOME Software
--librewolf	   Remove Firefox Snap and install LibreWolf (official repo)
--chrome	     Install Google Chrome (official APT repo)
--compression	 Install support for ZIP, RAR, 7z, tar.xz, bzip2, etc.
--preload	     Suggest preload and/or enable ZRAM based on RAM size
--remmina	     Install Remmina (GUI remote desktop client with all plugins)
--sysadmin	   Install common sysadmin tools: htop, nmap, traceroute, ssh, lftp, mtr, Remmina with all plugins, etc.
--office	     Install LibreOffice or OnlyOffice (interactive), and language packs
--donate	     Show donation options and open author Linktree
--dryrun       Preview commands instead of executing
--all	         Run all modules in order (except dryrun and donate)
-v, --version	 Show current script version
-h, --help	   Show help message
```

## 🛡️ License
Licensed under the GNU GPL v3.0
You are free to use, modify, and distribute — just keep it open!

## 👤 Credits
Crafted with 💻 + ☕ by Vitor Cruz

Pull requests, forks, and donations are always welcome 🌟

## 👋 Follow & Support
💖 Like the project? Want to say thanks?

👉 https://linktr.ee/vitorcruzcode

## ⚠️ Disclaimer
This script makes system-level changes. Use responsibly and make backups.
No warranties, no assumptions — just efficient Ubuntu boosting 🚀

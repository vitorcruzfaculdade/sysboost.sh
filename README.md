# ⚡ sysboost.sh - Optimize. Harden. Dominate.

**Version:** 1.3.8  
**Author:** Vitor Cruz  
**License:** GPL v3.0  
**Scope:** Ubuntu 24.04+ (GNOME) — Laptops & Desktops

---

## 🧰 What is sysboost?

`sysboost.sh` is your open-source all-in-one command-line ally to clean, speed up, secure, and enhance your Ubuntu GNOME experience — without breaking stuff.

From disabling telemetry to adding gaming performance tools and virtualization support, this script adapts to you.  
**Note**: It's based on my preferences — use with awareness and make backups!

---

## 🔥 Features

- 🧼 **Deep Clean**: Updates, removes junk, purges leftovers, and trims the fat.  
- 🔐 **Privacy First**: Nukes telemetry, crash reports, and background data leeches.  
- 🛡️ **Firewall Setup**: UFW configured to allow outgoing and deny incoming by default.  
- 🌐 **App Store Boost**: Full Flatpak + Snap + GNOME Software support (optional).  
- 🦊 **Firefox Rebellion**: Replace Snap Firefox with LibreWolf from official APT repo.  
- 🎮 **Gaming-Ready**: Installs GameMode, MangoHUD & tweaks for max FPS.  
- 💾 **SSD Friendly**: Enable `fstrim.timer` for disk health.  
- 🖥️ **VM Beast Mode**: Full VirtualBox support for devs and tinkerers.  
- ⚙️ **CPU Governor Switcher**: Enable 'performance' mode for desktops.  
- 🎵 **Multimedia Support**: Option to install ubuntu-restricted-extras.  
- 📦 **Compression Support**: Installs common file format tools (zip, rar, 7z, etc).  
- 🧹 **Clean Temp Files**: Option to wipe `/tmp`, `~/.cache`, and install BleachBit.  
- ✅ **Dry-Run Mode**: Preview everything before execution.  
- 🧠 **Smart Detection**: Auto-detects Desktop or Laptop and adapts behavior.

---

## 🧪 Usage

```bash
chmod +x sysboost.sh

# Run everything
./sysboost.sh --all

# Example: Targeted Boost for Gaming Laptop
./sysboost.sh --clean --harden --gaming --trim --codecs --compression

📦 Modular Options
Option	Description
--clean	Clean junk, update, remove Snap, fix broken packages
--harden	Disable telemetry, crash reports, and enable firewall
--store	Enable Flatpak, Snap, and GNOME Software
--librewolf	Replace Snap Firefox with LibreWolf
--vm	Install VirtualBox guest additions and kernel modules
--gaming	GameMode, MangoHUD, and gaming tools
--cpuperf	Set CPU governor to performance
--trim	Enable SSD TRIM support
--codecs	Install Ubuntu-restricted-extras & media codecs
--compression	Install zip, unzip, rar, unrar, 7z, xz-utils, bzip2, etc.
--tempclean	Clean temp files/cache (installs BleachBit)
--dryrun	Preview changes without running commands
--all	Run all modules (except dryrun)
-v, --version	Show script version
-h, --help	Show help message



🛡️ License
This project is licensed under the GNU GPL v3.0.
See the LICENSE file or visit:
👉 https://www.gnu.org/licenses/gpl-3.0.html

👤 Credits
Crafted with 💻 + ☕ by Vítor Cruz de Souza
Pull requests, forks, and stars are always welcome 🌟

⚠️ Disclaimer
This script changes system-level settings and installs packages.
Use at your own risk and always make backups or snapshots beforehand.
No guarantees — just results.



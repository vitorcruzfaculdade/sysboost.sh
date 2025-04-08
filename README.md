# ⚡ sysboost.sh - Optimize. Harden. Dominate.

**Version:** 1.3.5  
**Author:** Vítor Cruz de Souza  
**License:** [GPL v3.0](https://www.gnu.org/licenses/gpl-3.0.html)  
**Scope:** Ubuntu 24.04+ (GNOME) - Laptops & Desktops

---

## 🧰 What is sysboost?

`sysboost.sh` is your all-in-one command-line ally to clean, speed up, secure, and enhance your Ubuntu GNOME experience — without breaking stuff.

From disabling telemetry to adding gaming performance tools and virtualization support, this script adapts to **you**.  
*(Note: it's based on my preferences — use with awareness and make backups!)*

---

## 🔥 Features

- 🧼 **Deep Clean:** Updates, removes junk, purges leftovers, and trims the fat.
- 🔐 **Privacy First:** Nukes telemetry, crash reports, and background data leeches.
- 🛡️ **Firewall Setup:** UFW configured to allow outgoing and deny incoming by default.
- 🌐 **App Store Boost:** Full Flatpak + Snap + GNOME Software support (optional).
- 🦊 **Firefox Rebellion:** Replace Snap Firefox with LibreWolf from official APT repo.
- 🎮 **Gaming-Ready:** Installs GameMode, MangoHUD & tweaks for max FPS.
- 💾 **SSD Friendly:** Enable `fstrim.timer` for disk health.
- 🖥️ **VM Beast Mode:** Full VirtualBox support for devs and tinkerers.
- ⚙️ **CPU Governor Switcher:** Enable 'performance' mode for desktops.
- 🎵 **Multimedia Support:** Option to install `ubuntu-restricted-extras`.
- 📦 **Compression Support**: Installs common file format tools (zip, rar, 7z, etc).
- 🧹 **Clean Temp Files:** Option to wipe `/tmp`, `~/.cache`, and install BleachBit.
- ✅ **Dry-Run Mode:** Preview everything before execution.
- 🧠 **Auto-Detects Desktop or Laptop** and adapts some decisions automatically.

---

## 🧪 Usage

```bash
chmod +x sysboost.sh

# Run everything
./sysboost.sh --all

# Individual modules
./sysboost.sh --clean        # Cleanup & updates
./sysboost.sh --store        # Enable GNOME Software + Flatpak/Snap
./sysboost.sh --harden       # Disable telemetry & enable UFW
./sysboost.sh --librewolf    # Replace Firefox Snap with LibreWolf

# Extras (now modular!)
./sysboost.sh --gaming       # Install GameMode and MangoHUD
./sysboost.sh --vm           # VirtualBox setup
./sysboost.sh --trim         # Enable SSD trim
./sysboost.sh --governor     # Set CPU to performance mode
./sysboost.sh --multimedia   # Install restricted multimedia codecs
./sysboost.sh --tempclean    # Clean /tmp and ~/.cache, install BleachBit

# Preview mode (no changes made)
./sysboost.sh --dryrun --all

📦 Modular Options
Option	Description
--clean	Clean junk, update, remove Snap, fix broken packages
--harden	Disable telemetry, crash reports, and enable firewall
--store	Enable Flatpak, Snap, and GNOME Software
--librewolf	Replace Snap Firefox with LibreWolf
--extras	Full VM, gaming, CPU, TRIM, codec, and temp cleaning tools
--vm	Install VirtualBox guest additions and kernel modules
--gaming	GameMode, MangoHUD, and gaming tools
--cpuperf	Set CPU governor to performance
--trim	Enable SSD TRIM support
--codecs	Install Ubuntu-restricted-extras & media codecs
--tempclean	Clean temporary files and cache (installs BleachBit)
--compression	Install support for zip, rar, 7z, xz, bzip2, etc.
--all	Run everything above (EXCEPT dryrun)
--dryrun	Preview changes without running commands
-v, --version	Show script version
-h, --help	Show help message


💬 Example: Targeted Boost for Gaming Laptop
./sysboost.sh --clean --harden --gaming --trim --codecs --compression

🛡️ License
This project is licensed under the GNU GPL v3.0.
See the LICENSE file or visit https://www.gnu.org/licenses/gpl-3.0.html

👤 Credits
Crafted with 💻 + ☕ by Vítor Cruz de Souza
Pull requests, forks, and stars are always welcome 🌟

⚠️ Disclaimer
This script changes system-level settings and installs packages. Use at your own risk and always make backups or snapshots beforehand. No guarantees, just results.

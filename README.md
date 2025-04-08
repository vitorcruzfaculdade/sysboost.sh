# ⚡ sysboost.sh - Optimize. Harden. Dominate.

**Version:** 1.3.3  
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
Option	Action
--clean	Clean junk, update packages, remove leftovers
--store	Add Flatpak, Snap, and GNOME Software support
--harden	Disable telemetry and set up UFW firewall
--librewolf	Replace Firefox Snap with LibreWolf
--gaming	Install GameMode and MangoHUD for gamers
--vm	Install VirtualBox tools and ISO support
--trim	Enable SSD TRIM with fstrim.timer
--governor	Set CPU governor to "performance"
--multimedia	Install ubuntu-restricted-extras & addons
--tempclean	Remove temp/cache files and install BleachBit
--dryrun	Show what would happen, without executing
--all	Run everything in sequence
-v, --version	Show version info
-h, --help	Show help message
🛡️ License
This project is licensed under the GNU GPL v3.0.
See the LICENSE file or visit: https://www.gnu.org/licenses/gpl-3.0.html

👤 Credits
Crafted with care by Vítor Cruz de Souza
Pull requests, forks, and stars are welcome! 🌟

⚠️ Disclaimer
This script modifies system-level settings. Use at your own risk.
Always keep backups or snapshots ready before running system scripts.

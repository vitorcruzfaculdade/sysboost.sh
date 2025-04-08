# sysboost
**Version:** 1.2.0  
**Author:** Vítor Cruz de Souza  
**License:** GPL v3.0  
**Tagline:** Optimize. Harden. Dominate.  
**Scope:** Ubuntu 24.04+ (GNOME) - Laptops & Desktops

---

## 🧰 What is sysboost?

`sysboost.sh` is your all-in-one command-line ally to clean, speed up, secure, and enhance your Ubuntu GNOME experience — without breaking stuff.  
From disabling telemetry to adding gaming performance tools and virtualization support, this script adapts to YOU.

---

## 🔥 Features

- 🧼 **Deep Clean:** Updates, removes junk, purges leftovers, and trims the fat.
- 🔐 **Privacy First:** Nukes telemetry, crash reports, and background data leeches.
- 🛡️ **Firewall Setup:** UFW configured to allow outgoing and deny all incoming by default.
- 🌐 **App Store Boost:** Full Flatpak + Snap + GNOME Software support (optional).
- 🦊 **Firefox Rebellion:** Replace Snap Firefox with LibreWolf from official APT repo.
- 🎮 **Gaming-Ready:** Installs GameMode, MangoHUD & tweaks for max FPS.
- 💾 **SSD Friendly:** Enable fstrim.timer for disk health.
- 🖥️ **VM Beast Mode:** Full VirtualBox support for devs and tinkerers.
- ⚙️ **CPU Governor Switcher:** ‘Performance’ mode available for socketed systems.
- ✅ **DRY-RUN Mode:** Preview everything before execution.
- 🧠 **Auto-Detects** Desktop or Laptop and adapts.

---

## 🧪 Usage

```bash
chmod +x sysboost.sh
./sysboost.sh --all         # Full system boost
./sysboost.sh --clean       # Cleanup only
./sysboost.sh --store       # Enable GNOME Software + Snap/Flatpak
./sysboost.sh --harden      # Disable telemetry + enable firewall
./sysboost.sh --extras      # Gaming, VMs, TRIM, CPU governor
./sysboost.sh --librewolf   # Replace Snap Firefox with LibreWolf
./sysboost.sh --dryrun --all
📦 Modular Options
Option	Action
--clean	Clean junk, update packages
--store	Add Flatpak, Snap, GNOME Software Center
--harden	Disable tracking, secure your network
--extras	Enable VM & gaming tweaks, TRIM, CPU governor
--librewolf	Replace Snap Firefox with LibreWolf
--all	Run everything in order
--dryrun	Show commands without executing
-v, --version	Show version info
-h, --help	Show help info
🛡️ License
This project is licensed under the GNU GPL v3.0.
See LICENSE file or visit: [https://www.gnu.org/licenses/gpl-3.0.html]

👤 Credits
Crafted with care by José Vítor Cruz de Souza
Pull requests, forks and stars welcome 🌟

⚠️ Disclaimer
This script modifies system-level settings. Use at your own risk and always keep backups or snapshots ready. No guarantees, just results.

⚡ sysboost.sh — Optimize. Harden. Dominate.
Version: 1.3.8
Author: Vítor Cruz
License: GPL v3.0
Scope: Ubuntu 24.04+ (GNOME) — Laptops & Desktops

🧰 What is sysboost?
sysboost.sh is your open-source, all-in-one command-line ally to clean, speed up, secure, and enhance your Ubuntu GNOME experience — without breaking stuff.

From disabling telemetry to boosting gaming performance and enabling virtualization tools, this script adapts to you.

⚠️ Based on my personal preferences — use with awareness and always back up your system!

🔥 Key Features
Feature	Description
🧼 Deep Clean	Update, remove junk, purge leftovers, and trim the fat
🔐 Privacy First	Disable telemetry, crash reports, and background data leeches
🛡️ Firewall Setup	UFW set to allow outgoing / deny incoming by default
🌐 App Store Boost	Enable Flatpak, Snap, and GNOME Software
🦊 Firefox Rebellion	Replace Snap Firefox with LibreWolf via APT
🎮 Gaming-Ready	Install GameMode, MangoHUD & performance tweaks
💾 SSD Friendly	Enable fstrim.timer for disk health
🖥️ VM Beast Mode	VirtualBox support (Oracle repo + kernel modules)
⚙️ CPU Governor	Enable "performance" mode on desktops
🎵 Multimedia Support	Install ubuntu-restricted-extras (codecs, fonts)
📦 Compression Tools	Install support for zip, rar, 7z, xz, bzip2, and more
🧹 Temp File Cleanup	Wipe /tmp, ~/.cache, and install BleachBit
✅ Dry-Run Mode	Preview all actions before running
🧠 Smart Detection	Detects if running on laptop or desktop and adapts accordingly


🧪 Usage
Make it executable:
chmod +x sysboost.sh

Run Everything
./sysboost.sh --all

Run Specific Modules
./sysboost.sh --clean        # Cleanup & updates
./sysboost.sh --store        # Enable Flatpak, Snap & GNOME Software
./sysboost.sh --harden       # Disable telemetry & enable firewall
./sysboost.sh --librewolf    # Replace Firefox Snap with LibreWolf
./sysboost.sh --gaming       # Gaming tools: GameMode, MangoHUD, tweaks
./sysboost.sh --vm           # Install VirtualBox (Oracle repo)
./sysboost.sh --trim         # Enable SSD trim
./sysboost.sh --governor     # Set CPU governor to performance
./sysboost.sh --multimedia   # Install restricted media codecs
./sysboost.sh --tempclean    # Clean temp/cache, install BleachBit
./sysboost.sh --compression  # Install zip, rar, 7z, xz, bzip2, etc.
Dry-Run Mode
bash
Copy
Edit
./sysboost.sh --dryrun --all
📦 Modular Options
Option	Description
--clean	Clean junk, update system, fix broken packages
--harden	Disable telemetry, crash reporting, and enable UFW
--store	Enable Flatpak, Snap, and GNOME Software
--librewolf	Replace Firefox Snap with LibreWolf via APT
--vm	Install VirtualBox from Oracle repo
--gaming	Install GameMode, MangoHUD, and gaming tweaks
--cpuperf	Set CPU governor to performance mode
--trim	Enable SSD TRIM support
--codecs	Install ubuntu-restricted-extras codecs
--compression	Install archive format tools: zip, rar, 7z, etc.
--tempclean	Clean /tmp, ~/.cache, and install BleachBit
--all	Run all of the above (except dryrun)
--dryrun	Preview changes without executing
-v, --version	Show script version
-h, --help	Display help message
💬 Example: Boost Your Gaming Laptop
bash
Copy
Edit
./sysboost.sh --clean --harden --gaming --trim --codecs --compression
🛡️ License
This project is licensed under the GNU GPL v3.0.
See the LICENSE file for more details.

👤 Credits
Crafted with 💻 + ☕ by Vítor Cruz de Souza
Pull requests, forks, and stars are always welcome! 🌟

⚠️ Disclaimer
This script modifies system-level settings and installs packages.
Use at your own risk. Always make backups or snapshots beforehand.
No guarantees — just results.


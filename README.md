# Rubait's Dotfiles 🖥️

A specialized, two-tier symlinking system for managing Linux configurations on Arch-based systems (OmarchyOS).

## ⚠️ Warning: New Machine Setup
If you are running these scripts on a fresh installation, **DO NOT** run them individually if you are currently in a Wayland/Hyprland session. Moving active configurations without immediate symlinking will cause the compositor to crash. 

Always run the sync scripts to ensure the "Source of Truth" in `~/.dotfiles` is correctly linked to your system.

---

## 🛠️ The Scripts

### 1. `dotsync.sh` (The Config Manager)
Handles the `~/.config` directory. 
- **Adoption**: Automatically finds new, real folders in `~/.config`, moves them to `~/.dotfiles`, and creates a symlink.
- **Repair**: If an app replaces a symlink with a real file, it backs up the "rogue" file and restores your dotfile link.
- **Requirement**: Requires `dotskip.list` to exist in `~/.dotfiles`.

**Usage:**
```bash
./dotsync.sh            # Run actual sync
./dotsync.sh --dry-run  # Preview changes without touching files
```

### 2. `homesync.sh` (The Identity Manager)
Handles core profile files in the Home (`~/`) directory.
- **Strict Logic**: Only touches files explicitly listed in `dotallow.list`.
- **Adoption**: If a file in the allow-list is in `~/` but not in `~/.dotfiles`, it will "adopt" it.
- **Targeted**: Designed for `.zshrc`, `.bashrc`, `.XCompose`, etc.

**Usage:**
```bash
./homesync.sh           # Run actual sync
./homesync.sh -d        # Dry-run
```

---

## 📋 Mandatory Lists

### `dotskip.list`
Items in `~/.config` that should **never** be moved to dotfiles (e.g., large browser caches).
- `chromium`
- `google-chrome`
- `config.old`

### `dotallow.list`
Specific hidden files in `~/` that you want to manage.
- `.zshrc`
- `.bashrc`
- `.XCompose`

---

## 🔧 Troubleshooting: The `mise` Trust Issue

When moving your `mise` configuration (Node, Python, etc.) into the dotfiles directory, `mise` will flag the config as "untrusted" because the physical path has changed. You will see errors like:
`mise ERROR Config files in ~/.dotfiles/mise/config.toml are not trusted.`

**The Fix:**
You must explicitly trust both the physical path and the symlink path for `mise` to function correctly:

```bash
mise trust ~/.dotfiles/mise
mise trust ~/.dotfiles/mise/config.toml
mise trust ~/.config/mise/config.toml
mise trust ~/.config/mise
```

---

## 📂 Backup System
All scripts use `~/.config.old/` as a safety net. 
- `*_original_*`: Initial backup before moving to dotfiles.
- `*_replaced_*`: A rogue file found blocking a symlink.
- `*_collision_*`: General safety backup.



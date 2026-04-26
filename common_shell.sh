# ~/.dotfiles/common_shell.sh

# The "dot" alias was here by default. I don't use it, so I commented it out.
# I'm not sure if other system tools depend on it yet, so I haven't deleted it.
# alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'


 gdot() {
    local msg="${1:-update configs}"
    
    # 1. Sync Limine config from /boot to your repo (Overwrites old version)
    # We use sudo to read /boot and chown so git can track it
    if [ -f /boot/limine.conf ]; then
        mkdir -p ~/.dotfiles/boot/
        sudo cp -f /boot/limine.conf ~/.dotfiles/boot/limine.conf
        sudo chown $(id -u):$(id -g) ~/.dotfiles/boot/limine.conf
        echo "📥 Limine config synced to repo."
    fi

    # 2. Show summary of what changed
    echo "--- Current Status ---"
    git -C ~/.dotfiles status --short
    
    # 3. Standard Git workflow
    # Note: Ensure your .gitignore is set up to handle the "garbage" files!
    git -C ~/.dotfiles add .
    
    # Only commit if there are actually changes to avoid "nothing to commit" errors
    if ! git -C ~/.dotfiles diff --cached --quiet; then
        git -C ~/.dotfiles commit -m "$msg"
        git -C ~/.dotfiles push
        echo "🚀 Dotfiles pushed to GitHub!"
    else
        echo "✨ No changes detected. Nothing to push."
    fi
}
# My SSH Keys
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 < /dev/null 2>/dev/null
fi

# Safely unmount the 2TB HDD
eject-hdd() {
    if mountpoint -q /mnt/hdd; then
        echo "bullseye Flushing cache..."
        sync
        echo "󱑟 Unmounting /mnt/hdd..."
        if sudo umount /mnt/hdd; then
            echo "✅ Safe to remove the drive."
        else
            echo "❌ Failed to unmount. Check if Obsidian or a terminal is open."
            # Optional: Show what's blocking it
            fuser -mv /mnt/hdd
        fi
    else
        echo "ℹ️  Drive is not mounted (or already unmounted)."
    fi
}

# this is for nvim so that nvim can use "sudo" and have the configs working.
sudo() {
    if [[ "$1" == "nvim" ]]; then
        shift
        EDITOR=nvim SUDO_EDITOR=nvim command sudoedit "$@"
    else
        command sudo "$@"
    fi
}

# --- PORTRAIT MODES ---

# 1. Portrait - Stretched (Full Screen)
part() {
    printf "\033[?2026h"
    chafa -f symbols --symbols=sextant --colors=full --work=9 --stretch --dither=diffusion --size=$(tput cols)x$(tput lines) "$1"
    printf "\033[?2026l"
}

# 2. Portrait - Fixed Width (154), Auto Height
part-n() {
    printf "\033[?2026h"
    chafa -f symbols --symbols=sextant --colors=full --work=9 --dither=diffusion --size=154x "$1"
    printf "\033[?2026l"
}

# 3. Portrait - Fixed Height (175), Auto Width
part-l() {
    printf "\033[?2026h"
    chafa -f symbols --symbols=sextant --colors=full --work=9 --dither=diffusion --size=x175 "$1"
    printf "\033[?2026l"
}

# 4. Portrait - Landscape Width (327), Auto Height
part-nl() {
    printf "\033[?2026h"
    chafa -f symbols --symbols=sextant --colors=full --work=9 --dither=diffusion --size=$(tput cols)x "$1"
    printf "\033[?2026l"
}

# --- LANDSCAPE MODES ---

# 5. Landscape - Stretched (Full Screen)
land() {
    printf "\033[?2026h"
    chafa -f symbols --symbols=sextant --colors=full --work=9 --stretch --dither=diffusion --size=$(tput cols)x$(tput lines) "$1"
    printf "\033[?2026l"
}

# 6. Landscape - Auto Width, Fixed Height (74)
land-n() {
    printf "\033[?2026h"
    chafa -f symbols --symbols=sextant --colors=full --work=9 --dither=diffusion --size=x$(tput lines) "$1"
    printf "\033[?2026l"
}

# 7. Landscape - Fixed Width (327), Auto Height
land-l() {
    printf "\033[?2026h"
    chafa -f symbols --symbols=sextant --colors=full --work=9 --dither=diffusion --size=$(tput cols)x "$1"
    printf "\033[?2026l"
}

# --- ULTRA FIDELITY MODES ---

# Portrait Ultra - Max Width (327), Auto Height, Max Detail
# Use this for the highest possible resolution; requires scrolling.
part-ultra() {
    printf "\033[?2026h"
    chafa -f symbols --symbols all \
          --colors full \
          --color-space din99d \
          --work=9 \
          --dither fs \
          --dither-grain 1x1 \
          --size 1876x "$1"
    printf "\033[?2026l"
}

# High-Fidelity Portrait (Adaptive) - Fits standard portrait width
part-max() {
    printf "\033[?2026h"
    chafa -f symbols --symbols all \
          --colors full \
          --color-space din99d \
          --work=9 \
          --dither fs \
          --dither-grain 1x1 \
          --size 154x "$1"
    printf "\033[?2026l"
}

# High-Fidelity Landscape (Adaptive) - Fits standard landscape height
land-max() {
    printf "\033[?2026h"
    chafa -f symbols --symbols all \
          --colors full \
          --color-space din99d \
          --work=9 \
          --dither fs \
          --dither-grain 1x1 \
          --size x$(tput lines) "$1"
    printf "\033[?2026l"
}


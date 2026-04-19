# ~/.dotfiles/common_shell.sh

# My Git Dotfile Management
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'


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

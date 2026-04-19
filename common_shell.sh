# ~/.dotfiles/common_shell.sh

# My Git Dotfile Management
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

gdot() {
    local msg="${1:-update configs}"
    git -C ~/.dotfiles status --short  # <--- Add this to see a summary first
    git -C ~/.dotfiles add .
    git -C ~/.dotfiles commit -m "$msg"
    git -C ~/.dotfiles push
    echo "🚀 Dotfiles pushed to GitHub!"
}
# My SSH Keys
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 < /dev/null 2>/dev/null
fi

# Safely unmount the Obsidian HDD
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

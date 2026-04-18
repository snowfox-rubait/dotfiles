#!/bin/bash

# --- Configuration ---
DOTFILES_DIR="$HOME/.dotfiles"
HOME_DIR="$HOME"
BACKUP_DIR="$HOME/.config.old"
ALLOW_FILE="$DOTFILES_DIR/dotallow.list"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# --- Argument Parsing ---
DRY_RUN=false
[[ "$1" == "--dry-run" || "$1" == "-d" ]] && DRY_RUN=true && echo "🔍 DRY RUN: Home Identity Sync"

# 1. Mandatory Allow List Check
if [[ ! -f "$ALLOW_FILE" ]]; then
    echo "❌ Error: Allow list not found at $ALLOW_FILE"
    echo "   Create it with the hidden filenames you want to manage (e.g., .zshrc)."
    exit 1
fi

if [[ "$DRY_RUN" == false ]]; then mkdir -p "$BACKUP_DIR"; fi

# 2. Process the Allow List
# FIX: Corrected variable $file in the EOF guard check
while IFS= read -r file || [[ -n "$file" ]]; do
    [[ -z "$file" || "$file" =~ ^# ]] && continue

    target="$DOTFILES_DIR/$file"
    link="$HOME_DIR/$file"

    # CASE 1: File is in Allow List but NOT in .dotfiles (ADOPT)
    if [[ ! -e "$target" ]]; then
        if [[ -e "$link" && ! -L "$link" ]]; then
            echo "🆕 [Adopt to Home] $file"
            if [[ "$DRY_RUN" == false ]]; then
                # FIX: Backup first, then move (Safer atomicity)
                cp -r "$link" "$BACKUP_DIR/${file}_home_orig_$TIMESTAMP"
                mv "$link" "$target"
                # Link back using relative path for portability
                ln -sf ".dotfiles/$file" "$link"
                echo "   ➡ Remember to: git -C $DOTFILES_DIR add $file"
            else
                echo "   (Would backup original, move to dotfiles, and link)"
            fi
        else
            echo "⏭️  Skipping $file: Not in .dotfiles and no local file to adopt."
        fi
        continue
    fi

    # CASE 2: File is in .dotfiles, check the link (SYNC/REPAIR)
    if [[ -L "$link" && "$(readlink -f "$link")" == "$target" ]]; then
        continue # Already perfect
    fi

    # Collision/Repair: Handle real files sitting where links should be
    if [[ -e "$link" && ! -L "$link" ]]; then
        echo "🩹 [Repair Home] $file"
        if [[ "$DRY_RUN" == false ]]; then
            mv "$link" "$BACKUP_DIR/${file}_home_replaced_$TIMESTAMP"
        else
            echo "   (Would move existing ~/$file to backup)"
        fi
    fi

    # Final Symlink Creation
    echo "🔗 [Link Home] $file"
    if [[ "$DRY_RUN" == false ]]; then
        # FIX: Switched to relative path for consistency with dotsync.sh
        ln -sf ".dotfiles/$file" "$link"
    else
        echo "   (Would link .dotfiles/$file -> $file)"
    fi

done < "$ALLOW_FILE"

echo "✨ Home sync complete!"

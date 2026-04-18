#!/bin/bash

# --- Configuration ---
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.old"
SKIP_FILE="$DOTFILES_DIR/dotskip.list"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Robustness: Prevent loop errors if directories are empty
shopt -s nullglob

# --- Argument Parsing ---
DRY_RUN=false
if [[ "$1" == "--dry-run" || "$1" == "-d" ]]; then
    DRY_RUN=true
    echo "🔍 DRY RUN MODE: No changes will be made to your filesystem."
fi

# 1. Mandatory Skip List Check
if [[ ! -f "$SKIP_FILE" ]]; then
    echo "❌ Error: Skip list not found at $SKIP_FILE"
    echo "   Please create it (e.g., touch $SKIP_FILE) before running dotsync."
    exit 1
fi

# Only create backup dir if we are actually making changes
if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$BACKUP_DIR"
fi

# 2. Load Skip List
declare -A skip_list
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    skip_list["$line"]=1
done < "$SKIP_FILE"

# Track actions for dry-run simulation to prevent Phase 1 -> 2 bleed
declare -A dry_run_handled

echo "🚀 Starting Dotfiles Sync..."

# --- PHASE 1: Adoption & Repair (Scanning .config) ---
for item in "$CONFIG_DIR"/*; do
    base_item=$(basename "$item")

    [[ -L "$item" ]] && continue 
    [[ ${skip_list["$base_item"]} ]] && continue

    if [[ -e "$DOTFILES_DIR/$base_item" ]]; then
        echo "🩹 [Repair] $base_item"
        if [[ "$DRY_RUN" == false ]]; then
            mv "$item" "$BACKUP_DIR/${base_item}_replaced_$TIMESTAMP"
        else
            echo "   (Would move $item to $BACKUP_DIR)"
            dry_run_handled["$base_item"]=1
        fi
    else
        echo "🆕 [Adopt] $base_item"
        if [[ "$DRY_RUN" == false ]]; then
            cp -r "$item" "$BACKUP_DIR/${base_item}_original_$TIMESTAMP"
            mv "$item" "$DOTFILES_DIR/"
            echo "   ➡ Remember to: git -C $DOTFILES_DIR add $base_item"
        else
            echo "   (Would copy to $BACKUP_DIR and move to $DOTFILES_DIR)"
            dry_run_handled["$base_item"]=1
        fi
    fi
done

# --- PHASE 2: Linking (Scanning .dotfiles) ---
for item in "$DOTFILES_DIR"/*; do
    base_item=$(basename "$item")

    [[ ${skip_list["$base_item"]} ]] && continue
    [[ "$base_item" == ".git" || "$base_item" == "README.md" ]] && continue
    [[ "$base_item" == "$(basename "$SKIP_FILE")" ]] && continue
    [[ "$base_item" =~ \.sh$ ]] && continue

    target="$DOTFILES_DIR/$base_item"
    link="$CONFIG_DIR/$base_item"

    # Verify if link is already correct
    if [ -L "$link" ] && [ "$(readlink -f "$link")" == "$target" ]; then
        continue
    fi

    # Phase 2 Collision Check
    if [ -e "$link" ] && [ ! -L "$link" ]; then
        # Skip collision warning if Phase 1 already simulated handling it
        if [[ ${dry_run_handled["$base_item"]} ]]; then
            : # Silent skip - handled by simulation
        else
            echo "⚠️  [Collision] $base_item"
            if [[ "$DRY_RUN" == false ]]; then
                mv "$link" "$BACKUP_DIR/${base_item}_collision_$TIMESTAMP"
            else
                echo "   (Would move $link to backup directory)"
            fi
        fi
    fi

    # Consistent UI for Linking
    echo "🔗 [Link] $base_item"
    if [[ "$DRY_RUN" == false ]]; then
        ln -sfv "../.dotfiles/$base_item" "$link"
    else
        echo "   (Would link ../.dotfiles/$base_item -> $link)"
    fi
done

echo "✨ Sync complete!"

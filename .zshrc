# ~/.zshrc

# --- 1. HISTORY SETTINGS ---
# (Must be at the top so plugins have data to suggest from)
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt APPEND_HISTORY          # Immediately append to history file
setopt SHARE_HISTORY           # Share history between all open terminals
setopt HIST_IGNORE_ALL_DUPS    # Don't record duplicates
setopt HIST_REDUCE_BLANKS      # Remove extra blanks from commands

# --- 2. IMPORT OMARCHY SYSTEM (Bash Crossover) ---
# Borrowing the polished Envs, Aliases, and Functions from the system
[ -f ~/.local/share/omarchy/default/bash/envs ] && . ~/.local/share/omarchy/default/bash/envs
[ -f ~/.local/share/omarchy/default/bash/aliases ] && . ~/.local/share/omarchy/default/bash/aliases
[ -f ~/.local/share/omarchy/default/bash/functions ] && . ~/.local/share/omarchy/default/bash/functions

# --- 3. TOOL INITIALIZATION ---
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Modern Zsh completion (Mimics your Omarchy inputrc behavior)
autoload -Uz compinit && compinit -u
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# --- 4. PLUGINS ---
# Autosuggestions (The "Ghost Text")
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    # Makes the ghost text a clearly visible gray
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8' 
fi

# Syntax Highlighting (Always load this last)
[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- 5. YOUR PERSONAL IDENTITY ---
# Sourced last so your personal overrides take priority
if [ -f ~/.dotfiles/common_shell.sh ]; then
    . ~/.dotfiles/common_shell.sh
fi

# --- 6. KEYBINDINGS ---
# History search: type a partial command and hit Up to filter
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# Word Navigation: Skip words with Ctrl + Left/Right Arrow
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

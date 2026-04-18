# ~/.bashrc

# Interactive check
[[ $- != *i* ]] && return

# Omarchy Defaults
source ~/.local/share/omarchy/default/bash/rc

# Source the common ground
if [ -f ~/.dotfiles/common_shell.sh ]; then
    . ~/.dotfiles/common_shell.sh
fi

# Bash-only tweaks below


if [[ $- == *i* ]] && [ -f /usr/share/blesh/ble.sh ]; then
    source /usr/share/blesh/ble.sh --attach=prompt
fi

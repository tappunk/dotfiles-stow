export PAGER='less'
export COLORTERM="truecolor"
export XDG_CONFIG_HOME="$HOME/.config"

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export UV_TOOL_BIN_DIR="$HOME/.local/bin"

if [[ -d "$HOME/.local/bin" ]]; then
    path=("$HOME/.local/bin" $path)
fi

if [[ -d "/opt/homebrew/opt/rustup/bin" ]]; then
    path=("/opt/homebrew/opt/rustup/bin" $path)
fi

if [[ -d "$HOME/.cargo/bin" ]]; then
    path=("$HOME/.cargo/bin" $path)
fi

typeset -U path fpath

setopt HIST_IGNORE_ALL_DUPS HIST_SAVE_NO_DUPS SHARE_HISTORY APPEND_HISTORY
setopt PIPE_FAIL
setopt HIST_REDUCE_BLANKS HIST_VERIFY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_SPACE
setopt CORRECT AUTO_PUSHD PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB

export GPG_TTY=$(tty)
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE="$HOME/.zsh_history"

export PATH="$HOME/.local/npm/globals/bin:$PATH"

autoload -Uz compinit
if [[ -n "$HOME/.zcompdump"(#qN.m+1) ]]; then
    compinit -u
else
    compinit -C -u
fi

if command -v brew &>/dev/null; then
    BREW_PREFIX="$(brew --prefix)"

    [[ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    if [[ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]]; then
        source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
    elif [[ -f "$BREW_PREFIX/share/fzf/key-bindings.zsh" ]]; then
        source "$BREW_PREFIX/share/fzf/key-bindings.zsh"
    fi

    if [[ -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ]]; then
        source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
    elif [[ -f "$BREW_PREFIX/share/fzf/completion.zsh" ]]; then
        source "$BREW_PREFIX/share/fzf/completion.zsh"
    fi
fi

export SSH_AUTH_SOCK=$(launchctl getenv SSH_AUTH_SOCK)
if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
    for sock in /tmp/ssh-*/agent*(N); do
        export SSH_AUTH_SOCK="$sock"
        break
    done
fi

eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"

alias ls='eza --icons --group-directories-first'
alias l='eza -1 --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first --git'
alias la='eza -a --icons --group-directories-first'
alias lla='eza -lah --icons --group-directories-first --git'
alias ff='fd'

[[ -f "$HOME/.cache/muthr/opencode-profile" ]] && source "$HOME/.cache/muthr/opencode-profile"
[[ -f "$HOME/.zshrc.secrets" ]] && source "$HOME/.zshrc.secrets"
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

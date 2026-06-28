#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles-stow"

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ── Install Homebrew if missing ────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

# ── Install stow itself ────────────────────────────────────────────────────────
if ! command -v stow &>/dev/null; then
    echo "Installing stow..."
    brew install stow
fi

# ── Install muthr (Explicitly tapped & trusted) ───────────────────────────────
echo "Installing muthr..."
brew tap tappunk/muthr
brew tap lablup/tap

# 2. Pre-emptively trust the tap to eliminate the warning completely
if command -v brew-trust &>/dev/null || brew respond-to trust &>/dev/null 2>&1 || true; then
    brew trust tappunk/muthr 2>/dev/null || true
    brew trust lablup/tap 2>/dev/null || true
fi

# 3. Cleanly install the formula
brew install tappunk/muthr/muthr

# ── Clean stale cache files (fixes parallel download errors) ────────────────────
find "$HOME/Library/Caches/Homebrew/downloads" -name '*.incomplete' -delete 2>/dev/null || true

# ── Bundle install (formulae + casks) ──────────────────────────────────────────
echo "Installing Homebrew packages..."
brew bundle --file "$DOTFILES_DIR/Brewfile"

# ── Ensure npm global path settings and directories ────────────────────────────
mkdir -p "$HOME/.local/npm/globals" "$HOME/.local/npm/cache"

if [ ! -f "$HOME/.npmrc" ] || ! grep -q 'prefix=~/.local/npm/globals' "$HOME/.npmrc"; then
    cat >"$HOME/.npmrc" <<'EOF'
prefix=~/.local/npm/globals
cache=~/.local/npm/cache
EOF
fi

# ── Install global MCP servers required by opencode ───────────────────────────
echo "Installing MCP servers for opencode..."
npm install -g \
    @modelcontextprotocol/server-memory \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-sequential-thinking

# ── Initialize Rust toolchain via rustup if missing ───────────────────────────
if ! command -v rustc &>/dev/null; then
    echo "Initializing Rust toolchain..."
    RUSTUP_BIN="$(brew --prefix rustup)/bin/rustup"
    "$RUSTUP_BIN" toolchain install stable
    "$RUSTUP_BIN" default stable
    "$RUSTUP_BIN" component add rustfmt clippy
fi

# ── Create runtime directories ─────────────────────────────────────────────────
echo "Creating runtime directories..."
mkdir -p "$HOME/.cache/muthr"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/opt/models"

# ── Symlink dotfiles with stow ─────────────────────────────────────────────────
echo "Linking dotfiles with stow..."
cd "$DOTFILES_DIR"
stow -vt "$HOME" git
stow -vt "$HOME" zsh
stow -vt "$HOME" ghostty
stow -vt "$HOME" nvim
stow -vt "$HOME" starship
stow -vt "$HOME" eza
stow -vt "$HOME" fastfetch

# ── Ensure GPG pinentry matches macOS GUI pinentry ─────────────────────────────
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.gnupg"

GPG_AGENT_CONF="$HOME/.gnupg/gpg-agent.conf"
PINENTRY_BIN="$(brew --prefix)/bin/pinentry-mac"
MANAGED_LINE="pinentry-program $PINENTRY_BIN"

if [ -f "$GPG_AGENT_CONF" ]; then
    if grep -q '^pinentry-program ' "$GPG_AGENT_CONF"; then
        if ! grep -q "^$MANAGED_LINE$" "$GPG_AGENT_CONF"; then
            python3 - <<'PY' "$GPG_AGENT_CONF" "$MANAGED_LINE"
import sys
from pathlib import Path

conf = Path(sys.argv[1])
managed = sys.argv[2]
lines = conf.read_text().splitlines()

replaced = False
out = []
for line in lines:
    if line.startswith("pinentry-program ") and not replaced:
        out.append(managed)
        replaced = True
    else:
        out.append(line)

conf.write_text("\n".join(out) + "\n")
PY
        fi
    else
        printf "\n%s\n" "$MANAGED_LINE" >>"$GPG_AGENT_CONF"
    fi
else
    printf "%s\n" "$MANAGED_LINE" >"$GPG_AGENT_CONF"
fi

chmod 600 "$GPG_AGENT_CONF"
gpgconf --kill gpg-agent 2>/dev/null || true

# ── Initialize muthr specs ─────────────────────────────────────────────────────
muthr init --force

# ── Post-bootstrap reminder ────────────────────────────────────────────────────
echo ""
echo "Bootstrap complete."
echo ""

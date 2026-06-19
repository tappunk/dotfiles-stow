#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles-stow"

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

# ── Install muthr (matches upstream docs exactly) ─────────────────────────────
echo "Installing muthr..."
brew install tappunk/homebrew-muthr/muthr

# ── Clean stale cache files (fixes parallel download errors) ────────────────────
find "$HOME/Library/Caches/Homebrew/downloads" -name '*.incomplete' -delete 2>/dev/null || true

# ── Bundle install (formulae + casks) ──────────────────────────────────────────
echo "Installing Homebrew packages..."
brew bundle --file "$DOTFILES_DIR/Brewfile"

# ── Create runtime directories ─────────────────────────────────────────────────
echo "Creating runtime directories..."
mkdir -p "$HOME/.cache/muthr"
mkdir -p "$HOME/.lima"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/src/projects"
mkdir -p "$HOME/opt/models"

# ── Symlink dotfiles with stow ─────────────────────────────────────────────────
echo "Linking dotfiles with stow..."
cd "$DOTFILES_DIR"
stow git --adopt
stow zsh --adopt
stow ghostty --adopt
stow nvim --adopt
stow starship --adopt
stow eza --adopt
stow fastfetch --adopt

# ── Create .npmrc if missing ───────────────────────────────────────────────────
if [ ! -f "$HOME/.npmrc" ] || ! grep -q 'prefix=~/.local/npm/globals' "$HOME/.npmrc"; then
    cat > "$HOME/.npmrc" <<'EOF'
prefix=~/.local/npm/globals
cache=~/.local/npm/cache
EOF
fi

# ── Post-bootstrap reminder ────────────────────────────────────────────────────
echo ""
echo "Bootstrap complete."
echo "Run 'muthr init' to clone muthr configs from tappunk/muthr-configs"
echo ""

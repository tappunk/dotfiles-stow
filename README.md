![dotfiles-stow](https://raw.githubusercontent.com/tappunk/.github/refs/heads/main/assets/dotfiles-banner.webp)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![X Follow](https://img.shields.io/twitter/follow/tappunk?style=social)](https://x.com/tappunk)

# dotfiles-stow

**Hardened macOS dotfiles for a zero-trust local AI workstation. A stow + Homebrew reference implementation for [muthr](https://github.com/tappunk/muthr) that shows secure AI orchestration on Apple Silicon with reproducible Brewfile-managed dependencies.**

## Architecture

- **Inference** — `llama-server` on the host with configurable presets and auto VRAM management
- **Agent isolation** — Debian 13 VMs via Lima (`vmType: vz`) that provide agent isolation; VMs stay running until stopped with `muthr down`
- **MCP services** — Dedicated Lima VM for potentially dangerous MCPs, isolated from the host
- **System management** — GNU Stow symlinks + Homebrew bundle (Ghostty + Neovim + Starship)

## Prerequisites

macOS (Apple Silicon), Xcode Command Line Tools, ≥48 GB RAM for 35B models.

> [!NOTE]
> The ≥48GB RAM requirement applies to 35B models. Smaller models run on machines with less memory.

## Usage

```bash
# 0. Install Ghostty (recommended)
# [https://ghostty.org/download](https://ghostty.org/download)

# 1. Xcode Command Line Tools + bootstrap
xcode-select --install
git clone https://github.com/tappunk/dotfiles-stow.git ~/dotfiles-stow
cd ~/dotfiles-stow
./bootstrap.sh
exec zsh

# 2. Clone muthr specs from tappunk/muthr-specs
muthr init
```

## Configuration

Stow symlinks dotfiles from `~/dotfiles-stow/` to `~/.config/`:

- `ghostty/` → `~/.config/ghostty/config`
- `nvim/` → `~/.config/nvim`
- `zsh/` → `~/.zshrc`, `~/.zshenv`, `~/.zprofile`
- `git/` → `~/.gitconfig`, `~/.gitignore_global`
- `starship/starship.toml` → `~/.config/starship.toml`
- `eza/theme.yml` → `~/.config/eza/theme.yml`
- `fastfetch/config.jsonc` → `~/.config/fastfetch/config.jsonc`

Homebrew packages installed from `Brewfile`. muthr stores runtime state (PIDs, logs, generated JSON) in `~/.cache/muthr/`.

## Installation

```bash
git clone https://github.com/tappunk/dotfiles-stow.git ~/dotfiles-stow
cd ~/dotfiles-stow
./bootstrap.sh
```

Run `./bootstrap.sh` again after pulling changes to update packages and symlinks.

![dotfiles-stow](https://raw.githubusercontent.com/tappunk/.github/refs/heads/main/assets/dotfiles-stow.webp)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![X Follow](https://img.shields.io/twitter/follow/tappunk?style=social)](https://x.com/tappunk)

# dotfiles-stow

**Hardened macOS dotfiles via GNU Stow for a zero-trust AI workstation.** Symlinked dotfiles with Homebrew and muthr integration.

[What's installed](#whats-installed) • [Quick start](#quick-start) • [Architecture](#architecture) • [Updating](#updating)

## What's installed

- **Ghostty** — terminal emulator
- **Neovim** — editor
- **Zsh** — shell with Starship prompt
- **Git** — with global ignore rules
- **Eza** — modern ls replacement
- **Fastfetch** — system info display
- **muthr** — zero-trust AI orchestrator (installed via Homebrew tap during bootstrap)

### Configuration files

| Config       | Source                   | Installed at                           |
| ------------ | ------------------------ | -------------------------------------- |
| `ghostty/`   | `ghostty/`               | `~/.config/ghostty/config`             |
| `nvim/`      | `nvim/`                  | `~/.config/nvim/`                      |
| `zsh/`       | `zsh/`                   | `~/.zshrc`, `~/.zshenv`, `~/.zprofile` |
| `git/`       | `git/`                   | `~/.gitconfig`, `~/.gitignore_global`  |
| `starship/`  | `starship/starship.toml` | `~/.config/starship.toml`              |
| `eza/`       | `eza/theme.yml`          | `~/.config/eza/theme.yml`              |
| `fastfetch/` | `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc`     |

Dotfiles are symlinked via GNU Stow. Homebrew packages are installed from the `Brewfile`. muthr stores runtime state (PIDs, logs, generated JSON) in `~/.cache/muthr/`.

## Quick start

```bash
git clone https://github.com/tappunk/dotfiles-stow ~/dotfiles-stow
cd ~/dotfiles-stow
./bootstrap.sh
exec zsh
```

Requires Xcode Command Line Tools. Homebrew, stow, and muthr are installed automatically during bootstrap.

## Architecture

- **Inference** — `llama-server` on the host with configurable presets and auto VRAM management
- **Agent isolation** — Debian 13 VMs via Lima (`vmType: vz`) that provide agent isolation; VMs stay running until stopped with `muthr down`
- **MCP services** — Dedicated Lima VM for potentially dangerous MCPs, isolated from the host
- **System management** — GNU Stow symlinks + Homebrew bundle (Ghostty + Neovim + Starship)

## Updating

```bash
cd ~/dotfiles-stow
git pull
./bootstrap.sh
```

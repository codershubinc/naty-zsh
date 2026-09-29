# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.1.0] - 2026-09-29

### Added
- **Dynamic Kaomoji Doodles**: Random ASCII/Kaomoji face expressions (e.g. `( ✦ ‿ ✦ )`, `( ಠ_ಠ )`, `♥( ◡‿◡ )`) displayed in prompt on each command execution.
- **Git Porcelain Status**: Fast, unbuffered git prompt indicator with live dirty file counts (`+added`, `~modified`, `-deleted`), branch name, and random action phrases.
- **Pre-cached Runtime Badges**: Auto-detects language runtimes with directory-change caching (`_last_pwd` check) to prevent prompt lag:
  - Go (``)
  - Node.js (``)
  - Python (``)
  - Rust (``)
- **Execution Timer**: Measures execution time for long-running commands (duration &ge; 2 seconds) and displays cleanly in `RPROMPT`.
- **Media Player Integration**: Right prompt track status via `playerctl` (Spotify, browser, local media players).
- **Standalone & Oh My Zsh Support**: Works natively in plain Zsh without requiring Oh My Zsh, while also functioning as a drop-in OMZ theme.
- **One-Liner Installer (`install.sh`)**: Automated installer with shell detection, automatic `~/.zshrc` configuration, backup creation, and automatic **Nerd Font detection & installation** (JetBrains Mono Nerd Font).
- **Showcase Website**: Interactive web landing page with live prompt playground, screenshot gallery, and Nerd Font webfont fallback.
- **License**: Released under the GNU General Public License v3.0 (GPL-3.0).

---

[v0.1.0]: https://github.com/codershubinc/naty-zsh/releases/tag/v0.1.0

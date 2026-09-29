#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

REPO_RAW_URL="https://raw.githubusercontent.com/codershubinc/naty-zsh/main"

echo -e "${PURPLE}"
cat << "EOF"
  _   _    _  _____ __   __     _____ ____  _   _ 
 | \ | |  / \|_   _|\ \ / /    |__  // ___|| | | |
 |  \| | / _ \ | |   \ V / _____ / / \___ \| |_| |
 | |\  |/ ___ \| |    | | |_____/ /_  ___) |  _  |
 |_| \_/_/   \_\_|    |_|      /____||____/|_| |_|
EOF
echo -e "${CYAN}★ Fast, witty, doodle-packed Zsh theme ★${NC}\n"

# 1. Detect Oh My Zsh or Standalone Zsh path
if [ -d "$HOME/.oh-my-zsh" ]; then
    THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
    IS_OMZ=1
else
    THEME_DIR="$HOME/.zsh/themes/naty-zsh"
    IS_OMZ=0
fi

echo -e "${BLUE}==>${NC} Installing theme to: ${CYAN}${THEME_DIR}${NC}"
mkdir -p "$THEME_DIR"

# 2. Download theme and phrase list
echo -e "${BLUE}==>${NC} Downloading naty-zsh.zsh-theme..."
curl -fsSL "${REPO_RAW_URL}/naty-zsh.zsh-theme" -o "${THEME_DIR}/naty-zsh.zsh-theme"

echo -e "${BLUE}==>${NC} Downloading naty-zsh-random-texts.txt..."
curl -fsSL "${REPO_RAW_URL}/naty-zsh-random-texts.txt" -o "${THEME_DIR}/naty-zsh-random-texts.txt"

echo -e "${GREEN}✔ Theme files successfully downloaded!${NC}\n"

# 3. Configure ~/.zshrc
ZSHRC="$HOME/.zshrc"

if [ "$IS_OMZ" -eq 1 ]; then
    if [ -f "$ZSHRC" ]; then
        if grep -q '^ZSH_THEME="naty-zsh"' "$ZSHRC"; then
            echo -e "${GREEN}✔ ZSH_THEME=\"naty-zsh\" is already set in ~/.zshrc${NC}"
        elif grep -q '^ZSH_THEME=' "$ZSHRC"; then
            echo -e "${YELLOW}! Detected existing ZSH_THEME in ~/.zshrc.${NC}"
            cp "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
            echo -e "${BLUE}==>${NC} Backed up ~/.zshrc"
            sed -i 's/^ZSH_THEME=.*/ZSH_THEME="naty-zsh"/' "$ZSHRC"
            echo -e "${GREEN}✔ Updated ZSH_THEME to \"naty-zsh\" in ~/.zshrc${NC}"
        else
            echo 'ZSH_THEME="naty-zsh"' >> "$ZSHRC"
            echo -e "${GREEN}✔ Added ZSH_THEME=\"naty-zsh\" to ~/.zshrc${NC}"
        fi
    fi
else
    # Standalone Zsh
    if [ -f "$ZSHRC" ]; then
        if ! grep -q "naty-zsh.zsh-theme" "$ZSHRC"; then
            echo "" >> "$ZSHRC"
            echo "# naty-zsh theme" >> "$ZSHRC"
            echo "source ${THEME_DIR}/naty-zsh.zsh-theme" >> "$ZSHRC"
            echo -e "${GREEN}✔ Added source line to ~/.zshrc${NC}"
        fi
    fi
fi

# 4. Check for Nerd Fonts & Offer Installation
echo -e "\n${BLUE}==>${NC} Checking for Nerd Font (required for Arch, Git & runtime icons)..."

has_nerd_font=0
if command -v fc-list &> /dev/null; then
    if fc-list : family | grep -iq "nerd font"; then
        has_nerd_font=1
    fi
elif [ -d "$HOME/Library/Fonts" ]; then
    # macOS check
    if ls "$HOME/Library/Fonts" 2>/dev/null | grep -iq "nerd"; then
        has_nerd_font=1
    fi
elif [ -d "$HOME/.local/share/fonts" ]; then
    if ls "$HOME/.local/share/fonts" 2>/dev/null | grep -iq "nerd"; then
        has_nerd_font=1
    fi
fi

if [ "$has_nerd_font" -eq 1 ]; then
    echo -e "${GREEN}✔ Nerd Font detected! Your icons and kaomojis will render properly.${NC}"
else
    echo -e "${YELLOW}! No Nerd Font detected.${NC}"
    echo -e "  Without a Nerd Font, icons (Git branch, runtime badges, kaomojis) may appear as boxes [?]."

    # Determine default font directory based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        FONT_DIR="$HOME/Library/Fonts"
    else
        FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
    fi

    install_font="y"
    # If running interactively, ask; if piped via curl | bash, default to yes
    if [ -t 0 ]; then
        read -p "  Would you like to install JetBrains Mono Nerd Font now? [Y/n]: " choice
        case "$choice" in
            [nN][oO]|[nN]) install_font="n" ;;
            *) install_font="y" ;;
        esac
    fi

    if [ "$install_font" = "y" ]; then
        echo -e "${BLUE}==>${NC} Installing JetBrains Mono Nerd Font to ${CYAN}${FONT_DIR}${NC}..."
        mkdir -p "$FONT_DIR"

        JETBRAINS_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
        TEMP_FONT_DIR=$(mktemp -d)

        if curl -fsSL "$JETBRAINS_URL" | tar -xJ -C "$TEMP_FONT_DIR" 2>/dev/null; then
            cp "$TEMP_FONT_DIR"/*.ttf "$FONT_DIR/" 2>/dev/null || true
            rm -rf "$TEMP_FONT_DIR"

            # Update font cache on Linux
            if command -v fc-cache &> /dev/null; then
                fc-cache -f "$FONT_DIR" &>/dev/null || true
            fi
            echo -e "${GREEN}✔ JetBrains Mono Nerd Font installed successfully!${NC}"
            echo -e "${YELLOW}  Remember to select 'JetBrainsMono Nerd Font' in your terminal emulator settings.${NC}"
        else
            echo -e "${RED}✘ Could not download font archive.${NC}"
            echo -e "  You can manually download any font from: ${CYAN}https://www.nerdfonts.com${NC}"
        fi
    else
        echo -e "${YELLOW}ℹ Skipping font installation. You can install a Nerd Font manually from: https://www.nerdfonts.com${NC}"
    fi
fi

echo -e "\n${PURPLE}🎉 naty-zsh installed successfully!${NC}"
echo -e "${CYAN}Run this to apply immediately:${NC}"
echo -e "   ${YELLOW}source ~/.zshrc${NC}\n"

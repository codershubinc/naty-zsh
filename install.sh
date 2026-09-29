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

# Detect Oh My Zsh or custom ZSH path
if [ -d "$HOME/.oh-my-zsh" ]; then
    THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
    IS_OMZ=1
else
    THEME_DIR="$HOME/.zsh/themes/naty-zsh"
    IS_OMZ=0
fi

echo -e "${BLUE}==>${NC} Installing to: ${CYAN}${THEME_DIR}${NC}"
mkdir -p "$THEME_DIR"

# Download theme and phrase list with progress bar
echo -e "${BLUE}==>${NC} Downloading ${CYAN}naty-zsh.zsh-theme${NC}..."
curl -fL --progress-bar "${REPO_RAW_URL}/naty-zsh.zsh-theme" -o "${THEME_DIR}/naty-zsh.zsh-theme"

echo -e "${BLUE}==>${NC} Downloading ${CYAN}naty-zsh-random-texts.txt${NC}..."
curl -fL --progress-bar "${REPO_RAW_URL}/naty-zsh-random-texts.txt" -o "${THEME_DIR}/naty-zsh-random-texts.txt"

echo -e "\n${GREEN}✔ Theme files successfully downloaded!${NC}\n"

# Configure ~/.zshrc if user wants or Oh My Zsh is detected
ZSHRC="$HOME/.zshrc"

if [ "$IS_OMZ" -eq 1 ]; then
    if [ -f "$ZSHRC" ]; then
        if grep -q '^ZSH_THEME="naty-zsh"' "$ZSHRC"; then
            echo -e "${GREEN}✔ ZSH_THEME=\"naty-zsh\" is already set in ~/.zshrc${NC}"
        elif grep -q '^ZSH_THEME=' "$ZSHRC"; then
            echo -e "${YELLOW}! Detected existing ZSH_THEME in ~/.zshrc.${NC}"
            # Backup .zshrc
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

echo -e "\n${PURPLE}🎉 naty-zsh installed successfully!${NC}"
echo -e "${CYAN}Run this to apply immediately:${NC}"
echo -e "   ${YELLOW}source ~/.zshrc${NC}\n"

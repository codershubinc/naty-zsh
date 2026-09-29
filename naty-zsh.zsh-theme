# Enable prompt substitution so functions/vars update every time
setopt prompt_subst

# --- Configuration & Assets ---
NATY_ZSH_VERSION="v0.0.1"
THEME_DIR="${0:A:h}"

# 1. Random Text (kept for potential future use)
git_texts=("Keep Coding" "Stay Hard" "Focus" "Ship It" "Debug Mode" "Arch User" "Terminal Addict")
if [[ -f "$THEME_DIR/naty-zsh-random-texts.txt" ]]; then
  git_texts=(${(f)"$(<"$THEME_DIR/naty-zsh-random-texts.txt")"})
fi

# 2. Doodles
random_doodles=(


  "( ✦ ‿ ✦ )" "✧( ु•⌄• )" "[ ✦_✦ ]" "*( ◕ ◡ ◕ )*" "⟡"
  "✧･ﾟ: *" "<( ✦ )>" "☾˙❀" "【 ✦ 】" "⚡"


  "くコ:彡" "[ ⚠_⚠ ]" "( 0_0 )" "⊂(▀¯▀⊂)"
  "〈 0x0 〉" "⌁☍" "【 ✖_✖ 】"
   
  "( ˘ ɜ˘) ♬" "♫ ꒰･◡･꒱ ♫" "( ~*-*)~"
  "♥( ◡‿◡ )" "♪♪(o_o)♪♪"


  "(≧◡≦)" "(¬‿¬)" "♡( ━_━ )"
  "*:･ﾟ✧" "(◕‿◕✿)" "uwu"

"( ಠ_ಠ )"
"( ╯°□°)╯ ┻━━┻"
)

# --- Helper Functions ---
get_random_doodle() {
  local index=$(( RANDOM % ${#random_doodles[@]} + 1 ))
  echo "${random_doodles[$index]}"
}

get_random_git_text() {
  local index=$(( RANDOM % ${#git_texts[@]} + 1 ))
  echo "${git_texts[$index]}"
}

# --- Heavy Logic: Version Detection ---
# We define the function, but we will call it smartly in precmd
detect_project_versions_logic() {
  local versions=""
  
  # Go
  [[ -f "go.mod" ]] && versions+=" %B%F{cyan} $(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')%f%b"
  
  # Node
  [[ -f "package.json" ]] && versions+=" %B%F{green} $(node --version 2>/dev/null | sed 's/v//')%f%b"
  
  # Python
  [[ -f "requirements.txt" || -f "pyproject.toml" ]] && versions+=" %B%F{blue} $(python3 --version 2>/dev/null | awk '{print $2}')%f%b"
  
  # Rust
  [[ -f "Cargo.toml" ]] && versions+=" %B%F{red} $(rustc --version 2>/dev/null | awk '{print $2}')%f%b"

  echo "$versions"
}

# --- Git Prompt (Optimized) ---
git_custom_prompt() {
  # Fast check: are we in a git repo?
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local ref
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) || ref=$(git rev-parse --short HEAD 2> /dev/null)

  # Use --porcelain for speed
  local git_status=$(git status --porcelain 2>/dev/null)
  
  local modified=$(echo "$git_status" | grep -c "^.M")
  local total_add=$(echo "$git_status" | grep -c -E "^(A|\?\?)")
  local deleted=$(echo "$git_status" | grep -c "^.D")
  
  local status_text=""
  if [[ -n $git_status ]]; then
    [[ $total_add -gt 0 ]] && status_text+=" %F{green}+${total_add}"
    [[ $modified -gt 0 ]]  && status_text+=" %F{yellow}~${modified}"
    [[ $deleted -gt 0 ]]   && status_text+=" %F{red}-${deleted}"
    status_text="%f${status_text}"
  else
    status_text=" %F{cyan}✦%f"
  fi

  echo "  { %B%F{magenta}$(get_random_git_text)  ${ref}${status_text}%f%b}"
}

# --- Performance Hook (The Fix) ---
# Initialize variables
typeset -g _last_pwd=""
typeset -g _cached_versions=""
typeset -g cmd_start_time=""

function preexec() {
  cmd_start_time=$SECONDS
}

function precmd() {
  # 1. Timer Logic
  local timer_show=""
  if [[ -n $cmd_start_time ]]; then
    local elapsed=$(($SECONDS - $cmd_start_time))
    if [[ $elapsed -ge 2 ]]; then
      timer_show="%F{yellow}⏱ ${elapsed}s%f "
    fi
    unset cmd_start_time
  fi
  # Exporting it so RPROMPT can see it
  typeset -g RPROMPT_TIME="$timer_show"

  # 2. Smart Cache for Versions (The lag fix)
  if [[ "$PWD" != "$_last_pwd" ]]; then
    _cached_versions=$(detect_project_versions_logic)
    _last_pwd="$PWD"
  fi
}

get_music_status() {
  
  if command -v playerctl &> /dev/null; then
    # Quick check first to avoid timeout lag 
      local song_full=$(playerctl metadata title 2>/dev/null | head -n 1)
      local song=$song_full
      [[ ${#song_full} -gt 25 ]] && song="${song_full:0:25}..."
      echo " %F{green}🎵 ${song}%f" 
  fi
}

# --- The Prompt Layout ---

# Left Prompt
# We use ${_cached_versions} directly because precmd updates it
PROMPT='
%B%F{blue}╭─%F{cyan}  %n%f%b %F{magenta}$(get_random_doodle)%f %B%F{blue} %~%f%b$(git_custom_prompt)${_cached_versions}
%B%F{blue}╰─%F{magenta} ✦ %* ✦%f '

# Right Prompt
# Note: Single quotes are important here so variables expand at render time
RPROMPT='${RPROMPT_TIME}%b$(get_music_status)%f'

# --- Shell Helper Commands ---
naty-version() {
  local ver="${NATY_ZSH_VERSION:-unknown}"
  if [[ -f "$THEME_DIR/VERSION" ]]; then
    ver=$(<"$THEME_DIR/VERSION")
  fi
  echo "naty-zsh ${ver}"
}

naty-update() {
  local remote_ver
  remote_ver=$(curl -fsSL --connect-timeout 2 "https://raw.githubusercontent.com/codershubinc/naty-zsh/main/VERSION" 2>/dev/null)
  local local_ver="${NATY_ZSH_VERSION:-unknown}"
  [[ -f "$THEME_DIR/VERSION" ]] && local_ver=$(<"$THEME_DIR/VERSION")

  if [[ -n "$remote_ver" && "$remote_ver" != "$local_ver" ]]; then
    echo -e "\n%F{yellow}★ naty-zsh update available:%f %F{green}${local_ver}%f -> %F{cyan}${remote_ver}%f"
    echo -n "  Update now? [Y/n]: "
    read -r ans
    if [[ "$ans" =~ ^[Yy]?$ ]]; then
      curl -fsSL https://naty-zsh.codershubinc.com/install.sh | bash
    fi
  else
    echo -e "%F{green}✔ naty-zsh is up to date (${local_ver})%f"
  fi
}

# --- Optional Package Manager Upgrade Hook ---
if [[ "$NATY_ZSH_AUTO_UPGRADE" == "1" ]]; then
  # Arch Linux (yay)
  if command -v yay &>/dev/null; then
    yay() {
      command yay "$@"
      local ret=$?
      if [[ $ret -eq 0 && ( "$1" =~ "-S.*u" || -z "$1" ) ]]; then
        naty-update
      fi
      return $ret
    }
  fi

  # Arch Linux (pacman)
  if command -v pacman &>/dev/null; then
    pacman() {
      command pacman "$@"
      local ret=$?
      if [[ $ret -eq 0 && "$1" =~ "-S.*u" ]]; then
        naty-update
      fi
      return $ret
    }
  fi

  # Debian / Ubuntu (apt)
  if command -v apt &>/dev/null; then
    apt() {
      command apt "$@"
      local ret=$?
      if [[ $ret -eq 0 && ( "$1" == "upgrade" || "$1" == "dist-upgrade" || "$1" == "full-upgrade" ) ]]; then
        naty-update
      fi
      return $ret
    }
  fi
fi

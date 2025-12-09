# Enable prompt substitution
setopt prompt_subst

# --- Configuration & Assets ---
THEME_DIR="${0:A:h}"

# 1. Random Text (Generic / Motivational)
# No more "Gemini" text, back to coding vibes
git_texts=("Keep Coding" "Stay Hard" "Focus" "Ship It" "Debug Mode" "Arch User" "Terminal Addict")
if [[ -f "$THEME_DIR/nauty-zsh-random-texts.txt" ]]; then
  git_texts=(${(f)"$(<"$THEME_DIR/nauty-zsh-random-texts.txt")"})
fi

# 2. "Starlight" Doodles (The ones you liked)
# Stars, sparkles, and cool vibes
random_doodles=(
  "( ✦ ‿ ✦ )" "✧( ु•⌄• )" "[ ✦_✦ ]" "*( ◕ ◡ ◕ )*" "⟡"
  "✧･ﾟ: *" "<( ✦ )>" "☾˙❀" "【 ✦ 】" "⚡"
)

# --- Helper Functions ---

get_random_doodle() {
  local index=$(( RANDOM % ${#random_doodles[@]} + 1 ))
  echo "${random_doodles[$index]}"
}

get_random_msg() {
  echo "${git_texts[$RANDOM % ${#git_texts[@]} + 1]}"
}

# --- Version Detection (Fixed Width) ---
detect_project_versions() {
  local versions=""
  
  # Go (Cyan)
  [[ -f "go.mod" ]] && versions+=" %B%F{cyan}$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')%f%b"
  
  # Node (Green)
  [[ -f "package.json" ]] && versions+=" %B%F{green}$(node --version 2>/dev/null | sed 's/v//')%f%b"
  
  # Bun (Yellow)
  [[ -f "bun.lockb" || -f "bunfig.toml" ]] && versions+=" %B%F{yellow}$(bun --version 2>/dev/null)%f%b"
  
  # Python (Blue)
  [[ -f "requirements.txt" || -f "pyproject.toml" ]] && versions+=" %B%F{blue}$(python3 --version 2>/dev/null | awk '{print $2}')%f%b"
  
  # Rust (Red)
  [[ -f "Cargo.toml" ]] && versions+=" %B%F{red}$(rustc --version 2>/dev/null | awk '{print $2}')%f%b"

  # Java (Red)
  [[ -f "pom.xml" || -f "build.gradle" ]] && versions+=" %B%F{red}$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')%f%b"

  # PHP (Blue)
  [[ -f "composer.json" ]] && versions+=" %B%F{blue}$(php --version 2>/dev/null | head -n 1 | cut -d' ' -f2)%f%b"

  # Ruby (Red)
  [[ -f "Gemfile" ]] && versions+=" %B%F{red}$(ruby --version 2>/dev/null | awk '{print $2}')%f%b"

  # Docker (Blue)
  [[ -f "Dockerfile" || -f "docker-compose.yml" ]] && versions+=" %B%F{blue}%f%b"

  # C/C++ (Blue)
  [[ -f "CMakeLists.txt" || -f "Makefile" ]] && versions+=" %B%F{blue}$(gcc --version 2>/dev/null | head -n 1 | awk '{print $3}')%f%b"
  
  # Lua (Blue)
  [[ -f ".lua-version" ]] && versions+=" %B%F{blue}$(lua -v 2>&1 | awk '{print $2}')%f%b"

  echo "$versions"
}

# --- Git Prompt (Fixed Width) ---
git_custom_prompt() {
  local ref
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) || return

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
    status_text=" %F{cyan}✦%f" # Clean state is a sparkle
  fi

  echo " %B%F{magenta} ${ref}${status_text}%f%b"
}

# Put this with your other functions
function preexec() {
  timer=${timer:-$SECONDS}
}

function precmd() {
  if [ $timer ]; then
    local timer_show=$(($SECONDS - $timer))
    if [[ $timer_show -ge 2 ]]; then
      # Show time if > 2 seconds (e.g., "3s" or "1m 5s")
      export RPROMPT_TIME="%F{yellow}⏱ ${timer_show}s%f "
    else
      export RPROMPT_TIME=""
    fi
    unset timer
  fi
}
get_music_status() {
  # Check if playerctl is installed
  if command -v playerctl &> /dev/null; then
    # Get status of the first available player (usually the active one)
    
      local song_full=$(playerctl metadata title 2>/dev/null | head -n 1)
      
      local song=$song_full
      [[ ${#song_full} -gt 25 ]] && song="${song_full:0:25}..."
      
      # Show: 🎵 Song - Artist
      echo " %F{green}🎵 ${song}"
  fi
}

# --- The Prompt Layout ---

# Line 1: [Arch Icon] [User] [Sparkle Doodle] [Path] [Git] [Versions]
# Line 2: [Time] ✦ 
# Added $(get_music_status) before the time
PROMPT='
%B%F{blue}╭─%F{cyan}  %n%f%b %F{magenta}$(get_random_doodle)%f %B%F{blue} %~%f%b$(git_custom_prompt)$(detect_project_versions)
%B%F{blue}╰─%F{magenta} ✦ %* ✦%f '

# Right Prompt: Random Text (Grey)
RPROMPT='%b$(get_music_status) %F{grey}'
# Google Cloud SDK setup
if [ -f '/Users/abhinav/Downloads/google-cloud-sdk/path.zsh.inc' ]; then 
  . '/Users/abhinav/Downloads/google-cloud-sdk/path.zsh.inc'
fi

if [ -f '/Users/abhinav/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then 
  . '/Users/abhinav/Downloads/google-cloud-sdk/completion.zsh.inc'
fi

# Add Go binaries to PATH
export PATH=$PATH:$(go env GOPATH)/bin

# Enable colors
autoload -U colors && colors

# Enable command substitution in prompts
setopt PROMPT_SUBST

# Git branch function
git_branch() {
  local branch=$(git symbolic-ref --short HEAD 2> /dev/null || git describe --tags --exact-match 2> /dev/null)
  [ -n "$branch" ] && echo " $branch"
}

# Left prompt: user@host ~/current-dir ❯
PROMPT='%F{yellow}%n@%m%f %F{cyan}%~%f ❯ '

# Right prompt: show git branch (if in a git repo)
RPROMPT='$(git_branch)'

# Load zsh-syntax-highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Command highlighting styles
ZSH_HIGHLIGHT_STYLES[command]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[path]='fg=yellow'

# Auto-detect terminal theme and adjust colors
detect_terminal_theme() {
  local mode=$(osascript -e 'tell application "System Events" to tell appearance preferences to return dark mode')
  if [ "$mode" = "true" ]; then
    ZSH_HIGHLIGHT_STYLES[default]='fg=white'
    PROMPT='%F{yellow}%n@%m%f %F{cyan}%~%f ❯ '
  else
    ZSH_HIGHLIGHT_STYLES[default]='fg=black'
    PROMPT='%F{blue}%n@%m%f %F{green}%~%f ❯ '
  fi
}

# Ensure the theme is checked before every prompt
precmd() {
  detect_terminal_theme
  printf "\033[0m"
}

# Ensure "echo" works as expected
unalias echo 2>/dev/null

# Reset terminal colors after every prompt
precmd() {
  printf "\033[0m"}
#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# ANSI Color codes (note: terminal will render these in dimmed colors)
CYAN='\e[36m'
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
RED_BLK='\e[31;5m'
BLUE='\e[34m'
MAGENTA='\e[35m'
RESET='\e[0m'

# Extract model display name
model=$(echo "$input" | jq -r '.model.display_name')

# Get current directory (basename only)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")

# Calculate context usage percentage
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    pct=$((current * 100 / size))

    # Color code based on usage percentage
    if [ "$pct" -ge 75 ]; then
        ctx_color="$RED_BLK"
    elif [ "$pct" -ge 70 ]; then
        ctx_color="$RED"
    elif [ "$pct" -ge 60 ]; then
        ctx_color="$MAGENTA"
    elif [ "$pct" -ge 40 ]; then
        ctx_color="$YELLOW"
    elif [ "$pct" -ge 20 ]; then
        ctx_color="$GREEN"
    else
        ctx_color="$CYAN"
    fi
    if [ "$pct" -ge 80 ]; then
        context_info=$(printf "${ctx_color}??%%${RESET}")
    else
        context_info=$(printf "${ctx_color}%d%%${RESET}" "$pct")
    fi
else
    context_info=$(printf "${CYAN}0%%${RESET}")
fi

# Get git status (use --no-optional-locks to avoid lock issues)
git_info=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || printf "${RED_BLK}detached${MAGENTA}<%s>${RESET}" "$(git -C "$target_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)")
    counts=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count HEAD...@{u} 2>/dev/null)

    # Check for changes
    if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || \
       ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null || \
       [ -n "$(git -C "$cwd" ls-files --others --exclude-standard | head -n 1)" ]; then
        git_status=$(printf "${RED}*${RESET}")
    else
        git_status=""
    fi

    if [ -n "$counts" ]; then
        # 탭 구분을 공백으로 변환하여 배열화
        read -r ahead behind <<< "$counts"

        [[ "$ahead" -gt 0 ]] && status+=$(printf "${GREEN}↑${ahead}${RESET}")
        [[ "$behind" -gt 0 ]] && status+=$(printf "${RED}↓${behind}${RESET}")
        [ -n "$status" ] && git_status=$(printf "%s (%s)" "$git_status" "$status")
    fi

    git_info=$(printf " ${YELLOW}[${RESET}git:${MAGENTA}%s${RESET}%s${YELLOW}]${RESET}" "$branch" "$git_status")
fi

# Combine all info with colors
printf "${CYAN}[${RESET}%s${CYAN}]${RESET}%s ${YELLOW}[${RESET}ctx:%s${YELLOW}]${RESET} ${BLUE}[${RESET}%s${BLUE}]${RESET}" "$dir" "$git_info" "$context_info" "$model"

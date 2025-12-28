#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# ANSI Color codes (note: terminal will render these in dimmed colors)
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'
MAGENTA='\033[35m'
RESET='\033[0m'

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
    if [ "$pct" -ge 70 ]; then
        ctx_color="$RED"
    elif [ "$pct" -ge 55 ]; then
        ctx_color="$MAGENTA"
    elif [ "$pct" -ge 40 ]; then
        ctx_color="$YELLOW"
    elif [ "$pct" -ge 20 ]; then
        ctx_color="$GREEN"
    else
        ctx_color="$CYAN"
    fi
    context_info=$(printf "${ctx_color}%d%%${RESET}" "$pct")
else
    context_info=$(printf "${CYAN}0%%${RESET}")
fi

# Get git status (use --no-optional-locks to avoid lock issues)
git_info=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || echo "detached")

    # Check for changes
    if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || \
       ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
        git_status=$(printf "${RED}*${RESET}")
    else
        git_status=""
    fi

    git_info=$(printf " ${YELLOW}[${RESET}git:${MAGENTA}%s${RESET}%s${YELLOW}]${RESET}" "$branch" "$git_status")
fi

# Combine all info with colors
printf "${CYAN}[${RESET}%s${CYAN}]${RESET}%s ${YELLOW}[${RESET}ctx:%s${YELLOW}]${RESET} ${BLUE}[${RESET}%s${BLUE}]${RESET}" "$dir" "$git_info" "$context_info" "$model"

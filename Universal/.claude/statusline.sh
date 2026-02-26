#!/bin/bash

# Read JSON input from stdin
input=$(cat)
(echo "$input" | jq '.' > /run/user/${UID}/statusline-debug.json) # 디버그용

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

# Get current directory & venv name
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
if [ -n "$VIRTUAL_ENV" ]; then
    dir=$(basename "$cwd"):venv
else
    dir=$(basename "$cwd")
fi

# Calculate context usage percentage
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .output_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
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
        context_info=$(printf "${ctx_color}RL${RESET}")
    else
        context_info=$(printf "${ctx_color}%d%%${RESET}" "$pct")
    fi
else
    context_info=$(printf "${CYAN}0%%${RESET}")
fi

# Get git status (use --no-optional-locks to avoid lock issues)
git_status=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || printf "${RED_BLK}detached${MAGENTA}<%s>${RESET}" "$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)")
    counts=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count HEAD...@{u} 2>/dev/null)

    # Check for changes
    staged=$(git -C "$cwd" --no-optional-locks diff --cached --name-status 2>/dev/null | grep -c "^[AM]")
    deleted=$(git -C "$cwd" --no-optional-locks diff --cached --name-status 2>/dev/null | grep -c "^D")
    modified=$(git -C "$cwd" --no-optional-locks diff --name-only 2>/dev/null | wc -l)
    untracked=$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l)
    stashed=$(git -C "$cwd" stash list 2> /dev/null | wc -l)
    diffs=$(git -C "$cwd" rev-parse --verify origin/HEAD >/dev/null 2>&1 && git -C "$cwd" log --oneline origin/HEAD..HEAD | wc -l || echo 0)

    # 변경사항 문자열 구성
    [[ $staged -gt 0 ]] && changes+=$(printf "${GREEN}+%d${RESET}" "$staged")
    [[ $modified -gt 0 ]] && changes+=$(printf "${YELLOW}~%d${RESET}" "$modified")
    [[ $deleted -gt 0 ]] && changes+=$(printf "${RED}-%d${RESET}" "$deleted")
    [[ $untracked -gt 0 ]] && changes+=$(printf "${CYAN}?%d${RESET}" "$untracked")
    [[ $stashed -gt 0 ]] && changes+=$(printf "${BLUE}≡%d${RESET}" "$stashed")
    [ -n "$changes" ] && git_status=$(printf " (%s)" "$changes")

    if [ -n "$counts" ]; then
        # 탭 구분을 공백으로 변환하여 배열화
        read -r ahead behind <<< "$counts"

        [[ "$ahead" -gt 0 ]] && status+=$(printf "${GREEN}↑${ahead}${RESET}")
        [[ "$ahead" -gt 0 && "$behind" -gt 0 ]] && status+=$(printf "${RED_BLK}⇄${RESET}")
        [[ "$behind" -gt 0 ]] && status+=$(printf "${RED}↓${behind}${RESET}")
        [[ $diffs -gt 0 ]] && status+=$(printf "${MAGENTA}Δ%d${RESET}" "$diffs")
        [ -n "$status" ] && {
            if [ -n "$git_status" ]; then
                git_status=$(printf "%s <%s>" "$git_status" "$status")
            else
                git_status=$(printf " <%s>" "$status")
            fi
        }
    fi

    git_info=$(printf " ${YELLOW}[${RESET}git:${MAGENTA}%s${RESET}%s${YELLOW}]${RESET}" "$branch" "$git_status")
fi

# Combine all info with colors
which jq &> /dev/null
if [ $? -eq 0 ]; then
    printf "${CYAN}[${RESET}%s${CYAN}]${RESET}%s ${YELLOW}[${RESET}ctx:%s${YELLOW}]${RESET} ${BLUE}[${RESET}%s${BLUE}]${RESET}" "$dir" "$git_info" "$context_info" "$model"
else
    printf "${CYAN}[${RESET}%s${CYAN}]${RESET}%s ${YELLOW}[${RESET}ctx:%s${YELLOW}]${RESET} ${BLUE}[${RESET}%s${BLUE}]${RESET}" '`jq` not found' "$git_info" 'NaN%' 'N/A'
fi

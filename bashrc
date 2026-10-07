#── Aliases ────────────────────────────────────────────────

alias v="nvim"
alias vi=vim
alias py="python3"
alias docker-compose="docker compose"
alias reload='source ~/.zshrc'
alias c='clear'
alias ssh='TERM=xterm-256color ssh'

# ls
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias lls='du -sh * .* 2>/dev/null | sort -hr | column -t'

# Safety
alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Quick directory bookmarks
alias mark='pwd > ~/.lastdir'
alias jump='cd $(cat ~/.lastdir 2>/dev/null || echo ~)'

# Grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Disk
alias df='df -h'

# Docker
alias dsa='docker stop $(docker ps -a -q)'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'

# System
alias top10='ps aux --sort=-%mem | head -11'
alias ramcheck='watch -n 2 "free -h && echo && zramctl && echo && swapon --show"'

# Network
alias myip='curl -s myip.dnsomatic.com'


alias localip='ip -4 addr show | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | grep -v 127.0.0.1'
alias ports='ss -tulanp'
alias lsof-port='lsof -i'

# Files
alias ff='find . -type f -name'
alias fdir='find . -type d -name'
alias tf='tail -f'
alias count='find . -maxdepth 1 -type f | wc -l'

# Misc
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%Y-%m-%d"'
alias ping='ping -c 5'
alias diff='colordiff'
alias serve='python3 -m http.server 8000'
alias cwd='pwd | tr -d "\n" | xclip -selection clipboard && echo "PWD copied: $(pwd)"'
alias clast='fc -ln -1 | tr -d "\n" | xclip -selection clipboard && echo "Last command copied."'

# Git
alias gd='git diff'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --decorate --graph'
alias gla='git log --oneline --decorate --graph --all'

git_test() {
  ssh-add ~/.ssh/fd 2>/dev/null
  ssh -T git@github.com
}


alias tree="command tree -I 'node_modules|dist|.git|.next|.gitignore|.DS_Store|.env|.env.local|.cache|.vscode|.idea|coverage|build|out|tmp|.turbo|.eslintcache'"

#── Functions ────────────────────────────────────────────────
# ── clip / clip_show (works in zsh and bash) ─────────────

# zsh only: rewrite a trailing "| clip" or "| clip_show" into "|& ..." so
# stderr is piped too. In bash, type "|& clip" yourself (needs bash 4+),
# or use "2>&1 | clip".
if [ -n "$ZSH_VERSION" ]; then
    _clip_accept_line() {
        if [[ $BUFFER == *"| clip" ]]; then
            BUFFER="${BUFFER%"| clip"}|& clip"
        elif [[ $BUFFER == *"| clip_show" ]]; then
            BUFFER="${BUFFER%"| clip_show"}|& clip_show"
        fi
        zle .accept-line
    }
    zle -N accept-line _clip_accept_line
fi

# ── progress helpers (all draw on stderr, only when it's a terminal) ──

# Spinner line. Usage: _clip_spinner <index> <label>
_clip_spinner() {
    [ -t 2 ] || return 0
    local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=$(( $1 % 10 ))
    printf '\r\033[K%s %s' "${frames:$i:1}" "$2" >&2
}

# Progress bar. Usage: _clip_bar <bytes-done> <bytes-total>
_clip_bar() {
    [ -t 2 ] || return 0
    local cur=$1 total=$2 width=30 pct filled i bar=""
    [ "$total" -gt 0 ] || total=1
    if [ "$cur" -gt "$total" ]; then cur=$total; fi
    pct=$(( cur * 100 / total ))
    filled=$(( pct * width / 100 ))
    for (( i = 0; i < width; i++ )); do
        if [ "$i" -lt "$filled" ]; then bar+="█"; else bar+="░"; fi
    done
    printf '\r\033[K[%s] %3d%%  %d/%d KB' "$bar" "$pct" $(( cur / 1024 )) $(( total / 1024 )) >&2
}

_clip_progress_clear() {
    [ -t 2 ] || return 0
    printf '\r\033[K' >&2
}

# Stream a file to stdout in chunks, drawing the bar unless quiet.
# Usage: _clip_stream <file> <total-bytes> [quiet]
_clip_stream() {
    local f=$1 total=$2 q=$3 chunk=65535 off=0 i=0 cur
    while [ "$off" -lt "$total" ]; do
        dd if="$f" bs=$chunk skip=$i count=1 2>/dev/null
        off=$(( off + chunk ))
        i=$(( i + 1 ))
        cur=$off
        if [ "$cur" -gt "$total" ]; then cur=$total; fi
        if [ -z "$q" ]; then _clip_bar "$cur" "$total"; fi
    done
}

# Copy a file's exact bytes to the clipboard.
# With "quiet" it draws nothing (used for periodic refreshes while streaming).
# Usage: _clip_send_file <file> [quiet]
_clip_send_file() {
    local f=$1 q=$2 total rc=0 b64="" chunk=65535 off=0 i=0 cur
    total=$(wc -c <"$f" | tr -d ' ')

    if [[ "$OSTYPE" == "darwin"* ]]; then
        _clip_stream "$f" "$total" "$q" | pbcopy; rc=$?
    elif [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        # OSC 52: encode in chunks (multiple of 3 bytes so base64 joins cleanly)
        while [ "$off" -lt "$total" ]; do
            b64+=$(dd if="$f" bs=$chunk skip=$i count=1 2>/dev/null | base64 | tr -d '\n')
            off=$(( off + chunk ))
            i=$(( i + 1 ))
            cur=$off
            if [ "$cur" -gt "$total" ]; then cur=$total; fi
            if [ -z "$q" ]; then _clip_bar "$cur" "$total"; fi
        done
        if [ -n "$TMUX" ]; then
            printf '\033Ptmux;\033\033]52;c;%s\a\033\\' "$b64" > /dev/tty
        else
            printf '\033]52;c;%s\a' "$b64" > /dev/tty
        fi
        rc=0
    elif command -v xclip &> /dev/null; then
        _clip_stream "$f" "$total" "$q" | xclip -selection clipboard; rc=$?
    elif command -v xsel &> /dev/null; then
        _clip_stream "$f" "$total" "$q" | xsel --clipboard --input; rc=$?
    elif command -v wl-copy &> /dev/null; then
        _clip_stream "$f" "$total" "$q" | wl-copy; rc=$?
    else
        if [ -z "$q" ]; then _clip_progress_clear; fi
        echo "Error: No clipboard utility found" >&2
        return 1
    fi

    if [ -z "$q" ]; then _clip_progress_clear; fi
    return $rc
}

# ── clip: copies silently with progress (nothing printed to the terminal) ──
# Usage: clip <file> | clip <command> [args...] | <cmd> | clip
clip() {
    local tmp line n=0 interrupted=0 last=$SECONDS rc=0 size pid i=0
    local is_file=0 had_monitor=0

    # ── Piped input (streaming-friendly) ──
    if [ $# -eq 0 ]; then
        if [ -t 0 ]; then
            echo "Usage: clip <file> | clip <command> [args...] | <cmd> | clip"
            return 1
        fi
        tmp=$(mktemp) || return 1
        exec 3>>"$tmp"
        trap 'interrupted=1' INT

        while [ "$interrupted" -eq 0 ] && { IFS= read -r line || [ -n "$line" ]; }; do
            printf '%s\n' "$line" >&3
            n=$((n + 1))
            if [ "$n" -eq 1 ] || [ $((n % 20)) -eq 0 ]; then
                _clip_spinner "$n" "Streaming… $n lines, $(( $(wc -c <"$tmp") / 1024 )) KB"
            fi
            # Refresh the clipboard every ~2s so partial results are never lost
            if [ $((SECONDS - last)) -ge 2 ]; then
                _clip_send_file "$tmp" quiet
                last=$SECONDS
            fi
        done

        trap - INT
        exec 3>&-
        _clip_progress_clear

        # Stream ended (or was interrupted): total is known now, final copy with bar
        _clip_send_file "$tmp"
        rc=$?
        size=$(wc -c <"$tmp" | tr -d ' ')
        rm -f "$tmp"
        if [ "$rc" -ne 0 ]; then
            echo "Error: Failed to copy piped input" >&2
        elif [ "$interrupted" -eq 1 ]; then
            echo "✓ Interrupted. Copied $n lines so far ($(( size / 1024 )) KB)" >&2
            return 130
        else
            echo "✓ Copied piped input to clipboard ($n lines, $(( size / 1024 )) KB)" >&2
        fi
        return $rc
    fi

    # ── Decide: file or command ──
    if [ $# -eq 1 ] && [ -f "$1" ] && [ -r "$1" ]; then
        is_file=1
    elif [ $# -gt 1 ] && [ -e "$1" ]; then
        echo "Error: '$1' exists as a file, but you passed extra arguments ($*)." >&2
        echo "If the filename has spaces, quote it: clip \"$*\"" >&2
        return 1
    fi

    # ── File mode ──
    if [ "$is_file" -eq 1 ]; then
        _clip_send_file "$1"
        rc=$?
        if [ "$rc" -ne 0 ]; then
            echo "Error: Failed to copy '$1'" >&2
            return 1
        fi
        echo "✓ Copied contents of '$1' to clipboard"
        return 0
    fi

    # ── Command mode (streaming-friendly) ──
    tmp=$(mktemp) || return 1

    # Silence background-job messages ([1] 1234 / Done) in each shell
    if [ -n "$ZSH_VERSION" ]; then
        setopt local_options no_monitor no_notify
    else
        case $- in *m*) had_monitor=1; set +m ;; esac
    fi

    trap 'interrupted=1' INT
    { "$@" >"$tmp" 2>&1 & } 2>/dev/null
    pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        if [ "$interrupted" -eq 1 ]; then
            kill "$pid" 2>/dev/null
            break
        fi
        _clip_spinner "$i" "Running '$*'… $(( $(wc -c <"$tmp") / 1024 )) KB captured"
        i=$((i + 1))
        # Refresh the clipboard every ~2s with output captured so far
        if [ $((SECONDS - last)) -ge 2 ]; then
            _clip_send_file "$tmp" quiet
            last=$SECONDS
        fi
        sleep 0.1
    done

    wait "$pid" 2>/dev/null
    rc=$?
    trap - INT
    if [ "$had_monitor" -eq 1 ]; then set -m; fi
    _clip_progress_clear

    if [ "$interrupted" -eq 1 ]; then
        _clip_send_file "$tmp"
        rm -f "$tmp"
        echo "✓ Interrupted. Copied output so far to clipboard" >&2
        return 130
    fi

    if [ "$rc" -ne 0 ]; then
        echo "Error: Command failed" >&2
        cat "$tmp" >&2
        rm -f "$tmp"
        return 1
    fi

    _clip_send_file "$tmp"
    rc=$?
    rm -f "$tmp"
    if [ "$rc" -eq 0 ]; then
        echo "✓ Copied output of '$*' to clipboard"
    fi
    return $rc
}

# ── clip_show: like clip, but also prints the content to the terminal ──
# Usage: clip_show <file> | clip_show <command> [args...] | <cmd> | clip_show
clip_show() {
    local tmp line n=0 interrupted=0 last=$SECONDS rc=0 size rcf

    # ── Piped input: print each line live, copy as it arrives ──
    if [ $# -eq 0 ]; then
        if [ -t 0 ]; then
            echo "Usage: clip_show <file> | clip_show <command> [args...] | <cmd> | clip_show"
            return 1
        fi
        tmp=$(mktemp) || return 1
        exec 3>>"$tmp"
        trap 'interrupted=1' INT

        while [ "$interrupted" -eq 0 ] && { IFS= read -r line || [ -n "$line" ]; }; do
            printf '%s\n' "$line"          # show in terminal
            printf '%s\n' "$line" >&3      # save for clipboard
            n=$((n + 1))
            # Refresh the clipboard every ~2s so partial results are never lost
            if [ $((SECONDS - last)) -ge 2 ]; then
                _clip_send_file "$tmp" quiet
                last=$SECONDS
            fi
        done

        trap - INT
        exec 3>&-

        _clip_send_file "$tmp" quiet
        rc=$?
        size=$(wc -c <"$tmp" | tr -d ' ')
        rm -f "$tmp"
        if [ "$rc" -ne 0 ]; then
            echo "Error: Failed to copy piped input" >&2
        elif [ "$interrupted" -eq 1 ]; then
            echo "✓ Interrupted. Copied $n lines so far ($(( size / 1024 )) KB)" >&2
            return 130
        else
            echo "✓ Copied piped input to clipboard ($n lines, $(( size / 1024 )) KB)" >&2
        fi
        return $rc
    fi

    # ── File mode: show the file, then copy it ──
    if [ $# -eq 1 ] && [ -f "$1" ] && [ -r "$1" ]; then
        cat "$1"
        if ! _clip_send_file "$1" quiet; then
            echo "Error: Failed to copy '$1'" >&2
            return 1
        fi
        echo "✓ Copied contents of '$1' to clipboard" >&2
        return 0
    elif [ $# -gt 1 ] && [ -e "$1" ]; then
        echo "Error: '$1' exists as a file, but you passed extra arguments ($*)." >&2
        echo "If the filename has spaces, quote it: clip_show \"$*\"" >&2
        return 1
    fi

    # ── Command mode: run it, show output live, copy as it arrives ──
    rcf=$(mktemp) || return 1
    { "$@" 2>&1; echo $? >"$rcf"; } | clip_show
    rc=$(cat "$rcf" 2>/dev/null)
    rm -f "$rcf"
    if [ -z "$rc" ]; then rc=130; fi
    if [ "$rc" -ne 0 ] && [ "$rc" -ne 130 ]; then
        echo "⚠ Command exited with status $rc (output was still copied)" >&2
    fi
    return "$rc"
}

#── PORT ────────────────────────────────────────────────

kill_port() {
    if [ -z "$1" ]; then
        echo "Usage: kill_port <port_number> [port_number2 ...]"
        return 1
    fi

    local port
    for port in "$@"; do
        local info
        info=$(sudo ss -lptn "sport = :$port" 2>/dev/null)
        if [ -z "$(echo "$info" | tail -n +2)" ]; then
            echo "No process found listening on port $port"
            continue
        fi
        echo "$info"
        sudo fuser -k "$port"/tcp 2>/dev/null
        sleep 0.5
        if sudo ss -lptn "sport = :$port" 2>/dev/null | grep -q LISTEN; then
            echo "⚠ Port $port may still be in use"
        else
            echo "✓ Port $port is now free"
        fi
    done
}

kill9() {
  sudo fuser -k "$1"/tcp
}

check_port() {
    if [[ -z "$1" ]]; then
        echo "Usage: check_port <port> [port2] [port3] ..."
        return 1
    fi

    local ss_output
    ss_output=$(sudo ss -tuln)

    local port
    local any_closed=0

    for port in "$@"; do
        if echo "$ss_output" | grep -q ":${port}[[:space:]]"; then
            echo "Port $port is OPEN"
            sudo ss -ltunp "( sport = :$port )"
        else
            echo "Port $port is CLOSED"
            any_closed=1
        fi
        echo "---"
    done

    return $any_closed
}

# ssh_port_forward local_port:remote_port m@5.161.157.120
# ssh_port_forward 8080:8080 m@5.161.157.120
ssh_port_forward() {
  local mapping="$1"
  local target="$2"

  if [[ -z "$mapping" || -z "$target" ]]; then
    echo "usage: ssh_port_forward local_port:remote_port user@host"
    return 1
  fi

  local local_port="${mapping%%:*}"
  local remote_port="${mapping##*:}"

  echo "forwarding localhost:$local_port → $target:$remote_port"
  ssh -L "${local_port}:localhost:${remote_port}" "$target" -N
}

#── PROCESS ────────────────────────────────────────────────

kill_process() {
    if [ -z "$1" ]; then
        echo "Usage: killprocess <process_name>"
        echo "Example: killprocess v2ray"
        return 1
    fi
    local process_name="$1"
    if ! pgrep -x "$process_name" > /dev/null && ! pgrep -f "$process_name" > /dev/null; then
        echo "No processes found matching: $process_name"
        return 0
    fi
    echo "Found processes matching '$process_name':"
    ps aux | grep -i "$process_name" | grep -v grep
    echo ""
    echo "Killing all processes matching '$process_name'..."
    killall -9 "$process_name" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Successfully killed processes"
    else
        echo "✓ Processes killed"
    fi
}

find_process() {
    if [ -z "$1" ]; then
        echo "Usage: find_process <process_name>"
        echo "Example: find_process v2rayN"
        return 1
    fi
    local process_name="$1"
    local results=$(ps aux | grep "$process_name" | grep -v grep)
    if [ -z "$results" ]; then
        echo "No processes found matching: $process_name"
        return 0
    fi
    echo "Processes matching '$process_name':"
    echo ""
    ps aux | grep "$process_name" | grep -v grep
    echo ""
    local count=$(echo "$results" | wc -l)
    echo "Found $count process(es)"
}

# kill_apt: free apt/dpkg when it's locked or left in a broken state.
# Usage:  kill_apt        # kill lock holders, clear stale locks, repair dpkg
# Paste-safe: no "set -e" and no "exit" (uses "return").

kill_apt() {
  local SUDO=""
  [ "$(id -u)" -ne 0 ] && SUDO="sudo"

  local locks=(
    /var/lib/dpkg/lock-frontend
    /var/lib/dpkg/lock
    /var/lib/apt/lists/lock
    /var/cache/apt/archives/lock
  )
  local procs='apt|apt-get|aptitude|dpkg|unattended-upgr|apt.systemd.dai|apt-daily|packagekitd|aptd|update-manager|synaptic|gnome-software'

  _kill_apt_held() {
    local f
    for f in "${locks[@]}"; do
      [ -e "$f" ] || continue
      if command -v fuser >/dev/null 2>&1; then
        $SUDO fuser "$f" >/dev/null 2>&1 && return 0
      fi
    done
    $SUDO pgrep -x "($procs)" >/dev/null 2>&1 && return 0
    return 1
  }

  echo "[kill_apt] Stopping apt-related services..."
  $SUDO systemctl stop unattended-upgrades apt-daily.service apt-daily-upgrade.service packagekit 2>/dev/null

  echo "[kill_apt] Killing apt/dpkg processes..."
  $SUDO pkill -9 -x "($procs)" 2>/dev/null
  if command -v fuser >/dev/null 2>&1; then
    local f
    for f in "${locks[@]}"; do
      [ -e "$f" ] && $SUDO fuser -k -9 "$f" >/dev/null 2>&1
    done
  fi

  # Wait up to ~15s for everything to let go
  local i=0
  while _kill_apt_held && [ "$i" -lt 15 ]; do sleep 1; i=$((i + 1)); done

  if _kill_apt_held; then
    echo "[kill_apt] Something still holds the lock. Inspect with: ps aux | grep -E 'apt|dpkg'"
    unset -f _kill_apt_held
    return 1
  fi

  echo "[kill_apt] Removing stale lock files (nothing holds them)..."
  $SUDO rm -f "${locks[@]}"

  echo "[kill_apt] Clearing partial downloads..."
  $SUDO rm -rf /var/lib/apt/lists/partial/* 2>/dev/null

  echo "[kill_apt] Repairing dpkg state..."
  $SUDO dpkg --configure -a
  $SUDO apt-get -o DPkg::Lock::Timeout=60 -f install -y

  unset -f _kill_apt_held
  echo "[kill_apt] apt is free."
}

# kill_dnf: free dnf/rpm on Fedora/RHEL when it's locked or left in a broken state.
# Usage:  kill_dnf
# Paste-safe: no "set -e" and no "exit" (uses "return").

kill_dnf() {
  local SUDO=""
  [ "$(id -u)" -ne 0 ] && SUDO="sudo"

  local locks=(
    /var/run/dnf.pid
    /var/run/yum.pid
    /var/lib/rpm/.rpm.lock
    /var/lib/rpm/.dbenv.lock
  )
  local procs='dnf|dnf5|dnf-3|yum|rpm|dnf-automatic|packagekitd|dnfdaemon-syste|dnfdaemon-serve|gnome-software'

  _kill_dnf_held() {
    local f
    for f in "${locks[@]}"; do
      [ -e "$f" ] || continue
      if command -v fuser >/dev/null 2>&1; then
        $SUDO fuser "$f" >/dev/null 2>&1 && return 0
      fi
    done
    $SUDO pgrep -x "($procs)" >/dev/null 2>&1 && return 0
    return 1
  }

  echo "[kill_dnf] Stopping dnf-related services..."
  $SUDO systemctl stop dnf-makecache.service dnf-automatic.service dnf-automatic-install.service \
    dnf-automatic-download.service dnf-automatic-notifyonly.service dnfdaemon.service packagekit 2>/dev/null

  echo "[kill_dnf] Killing dnf/rpm processes..."
  $SUDO pkill -9 -x "($procs)" 2>/dev/null
  if command -v fuser >/dev/null 2>&1; then
    local f
    for f in "${locks[@]}"; do
      [ -e "$f" ] && $SUDO fuser -k -9 "$f" >/dev/null 2>&1
    done
  fi

  # Wait up to ~15s for everything to let go
  local i=0
  while _kill_dnf_held && [ "$i" -lt 15 ]; do sleep 1; i=$((i + 1)); done

  if _kill_dnf_held; then
    echo "[kill_dnf] Something still holds the lock. Inspect with: ps aux | grep -E 'dnf|yum|rpm'"
    unset -f _kill_dnf_held
    return 1
  fi

  echo "[kill_dnf] Removing stale lock files (nothing holds them)..."
  $SUDO rm -f "${locks[@]}"
  $SUDO rm -f /var/lib/rpm/__db.* 2>/dev/null

  echo "[kill_dnf] Rebuilding rpm database..."
  $SUDO rpm --rebuilddb

  echo "[kill_dnf] Cleaning dnf cache..."
  $SUDO dnf clean all

  unset -f _kill_dnf_held
  echo "[kill_dnf] dnf is free."
}

# kill_pacman: free pacman on Manjaro/Arch when the database is locked.
# Usage:  kill_pacman
# Paste-safe: no "set -e" and no "exit" (uses "return").

kill_pacman() {
  local SUDO=""
  [ "$(id -u)" -ne 0 ] && SUDO="sudo"

  local lock=/var/lib/pacman/db.lck
  local procs='pacman|yay|paru|pamac|pamac-daemon|pamac-manager|pamac-tray|pamac-tray-appi|octopi|packagekitd|gnome-software|discover'

  _kill_pacman_held() {
    if [ -e "$lock" ] && command -v fuser >/dev/null 2>&1; then
      $SUDO fuser "$lock" >/dev/null 2>&1 && return 0
    fi
    $SUDO pgrep -x "($procs)" >/dev/null 2>&1 && return 0
    return 1
  }

  echo "[kill_pacman] Stopping package-manager services..."
  $SUDO systemctl stop pamac-daemon packagekit 2>/dev/null

  echo "[kill_pacman] Killing pacman/pamac/AUR-helper processes..."
  $SUDO pkill -9 -x "($procs)" 2>/dev/null
  if [ -e "$lock" ] && command -v fuser >/dev/null 2>&1; then
    $SUDO fuser -k -9 "$lock" >/dev/null 2>&1
  fi

  # Wait up to ~15s for everything to let go
  local i=0
  while _kill_pacman_held && [ "$i" -lt 15 ]; do sleep 1; i=$((i + 1)); done

  if _kill_pacman_held; then
    echo "[kill_pacman] Something still holds the lock. Inspect with: ps aux | grep -E 'pacman|pamac|yay|paru'"
    unset -f _kill_pacman_held
    return 1
  fi

  echo "[kill_pacman] Removing stale lock (nothing holds it)..."
  $SUDO rm -f "$lock"

  echo "[kill_pacman] Clearing partial downloads..."
  $SUDO rm -rf /var/cache/pacman/pkg/download-* 2>/dev/null
  $SUDO find /var/cache/pacman/pkg -name '*.part' -delete 2>/dev/null

  unset -f _kill_pacman_held
  echo "[kill_pacman] pacman is free."
}


#── PROXY ────────────────────────────────────────────────
function ssh() {
    if [[ "$TERM" == "xterm-ghostty" ]]; then
        TERM=xterm-256color command ssh "$@"
    else
        command ssh "$@"
    fi
}

# Route the current terminal through an SSH SOCKS tunnel: set_ssh_terminal user@host [port]
set_ssh_terminal() {
  local target="$1"
  local port="${2:-10810}"
  local url="socks5h://127.0.0.1:$port"
  local sock="$HOME/.ssh/proxy-${target//[^a-zA-Z0-9]/_}.sock"

  if [[ "$target" != *@* ]]; then
    echo "Usage: proxy user@host [port]"
    return 1
  fi

  if ! ssh -S "$sock" -O check "$target" 2>/dev/null; then
    ssh -fN -D "127.0.0.1:$port" \
      -M -S "$sock" \
      -o ServerAliveInterval=30 \
      -o ServerAliveCountMax=3 \
      -o ExitOnForwardFailure=yes \
      "$target" || { echo "Failed to start tunnel"; return 1; }
  fi

  export ALL_PROXY="$url" all_proxy="$url" \
         HTTP_PROXY="$url" http_proxy="$url" \
         HTTPS_PROXY="$url" https_proxy="$url" \
         NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1"

  echo "This terminal now goes through $target (socks5h://127.0.0.1:$port)"
}

# Route the ENTIRE system through an SSH server: set_ssh_all user@host
# Stop with: set_ssh_all off
# set_ssh_all root@45.38.23.244
# curl https://ifconfig.me        # should show the server's IP, from any terminal or app
# set_ssh_all off
set_ssh_all() {
  local target="$1"
  local pidfile="/tmp/set_ssh_all.pid"

  if [[ "$target" == "off" || "$target" == "stop" ]]; then
    if sudo test -f "$pidfile"; then
      sudo kill "$(sudo cat "$pidfile")" 2>/dev/null
      sudo rm -f "$pidfile"
      echo "System-wide tunnel stopped"
    else
      echo "System-wide tunnel not running"
    fi
    return
  fi

  if [[ "$target" != *@* ]]; then
    echo "Usage: set_ssh_all user@host   |   set_ssh_all off"
    return 1
  fi

  if ! command -v sshuttle >/dev/null; then
    echo "sshuttle not installed. Install it with:"
    echo "  macOS:  brew install sshuttle"
    echo "  Debian/Ubuntu:  sudo apt install sshuttle"
    echo "  other:  pip install sshuttle"
    return 1
  fi

  if sudo test -f "$pidfile" && sudo kill -0 "$(sudo cat "$pidfile")" 2>/dev/null; then
    echo "Already running. Use: set_ssh_all off"
    return 1
  fi

  local host="${target#*@}"

  sudo sshuttle -D --pidfile="$pidfile" \
    -r "$target" 0.0.0.0/0 \
    --dns \
    -x "$host" \
    && echo "Entire system now routed through $target (stop with: set_ssh_all off)"
}

# SSH SOCKS tunnel on a chosen local port: set_ssh_port port user@host
# Stop with: set_ssh_port off port
# set_ssh_port 10808 root@45.38.23.244
# curl https://ifconfig.me          # shows the server's IP
# set_ssh_port off 10808
set_ssh_port() {
  local port="$1"
  local target="$2"
  local sock="$HOME/.ssh/sshport-${port}.sock"
  local url="socks5h://127.0.0.1:$port"

  if [[ "$port" == "off" || "$port" == "stop" ]]; then
    local p="$2"
    sock="$HOME/.ssh/sshport-${p}.sock"
    unset ALL_PROXY all_proxy HTTP_PROXY http_proxy HTTPS_PROXY https_proxy NO_PROXY no_proxy
    ssh -S "$sock" -O exit dummy 2>/dev/null \
      && echo "Tunnel on port $p stopped, env vars cleared" \
      || echo "No tunnel on port $p, env vars cleared"
    return
  fi

  if [[ ! "$port" =~ ^[0-9]+$ || "$target" != *@* ]]; then
    echo "Usage: set_ssh_port port user@host   |   set_ssh_port off port"
    return 1
  fi

  if ssh -S "$sock" -O check dummy 2>/dev/null; then
    echo "Tunnel already running on port $port"
  else
    ssh -fN -D "127.0.0.1:$port" \
      -M -S "$sock" \
      -o ServerAliveInterval=30 \
      -o ServerAliveCountMax=3 \
      -o ExitOnForwardFailure=yes \
      "$target" || { echo "Failed to start tunnel (is port $port in use?)"; return 1; }
  fi

  export ALL_PROXY="$url" all_proxy="$url" \
         HTTP_PROXY="$url" http_proxy="$url" \
         HTTPS_PROXY="$url" https_proxy="$url" \
         NO_PROXY="localhost,127.0.0.1,::1" no_proxy="localhost,127.0.0.1,::1"

  echo "SOCKS5 on 127.0.0.1:$port via $target (this terminal is using it)"
}

# Undo everything from proxy, set_ssh_port and set_ssh_all: unset_ssh
unset_ssh() {
  local pidfile="/tmp/set_ssh_all.pid"
  local sock count=0

  # 1) Stop the system-wide sshuttle tunnel (set_ssh_all)
  if sudo test -f "$pidfile"; then
    sudo kill "$(sudo cat "$pidfile")" 2>/dev/null
    sudo rm -f "$pidfile"
    echo "Stopped system-wide tunnel (set_ssh_all)"
  fi

  # 2) Close every SOCKS tunnel (set_ssh_port and proxy)
  while IFS= read -r sock; do
    [[ -n "$sock" ]] || continue
    if ssh -S "$sock" -O exit dummy 2>/dev/null; then
      echo "Closed tunnel: $(basename "$sock")"
      count=$((count + 1))
    fi
    rm -f "$sock"   # remove stale sockets too
  done < <(find "$HOME/.ssh" -maxdepth 1 \( -name 'sshport-*.sock' -o -name 'proxy-*.sock' \) 2>/dev/null)

  # 3) Clear proxy variables in this terminal
  unset ALL_PROXY all_proxy HTTP_PROXY http_proxy HTTPS_PROXY https_proxy NO_PROXY no_proxy
  echo "Proxy env vars cleared in this terminal ($count SOCKS tunnel(s) closed)"
}

# jump
set_ssh_proxy_jump() {
    local vps1="$1"
    local vps2="$2"

    if [ -z "$vps1" ] || [ -z "$vps2" ]; then
        echo "Error: Please provide both VPS user@ip"
        echo "Usage: set_ssh_proxy <user1@vps1_ip> <user2@vps2_ip>"
        return 1
    fi

    local vps1_ip="${vps1##*@}"
    local vps2_ip="${vps2##*@}"

    sshuttle -r "$vps2" \
        --dns --to-ns 8.8.8.8 --to-ns 8.8.4.4 \
        --no-latency-control \
        --auto-hosts \
        --exclude "$vps1_ip" \
        --exclude "$vps2_ip" \
        --exclude 127.0.0.0/8 \
        --exclude 10.0.0.0/8 \
        --exclude 172.16.0.0/12 \
        --exclude 192.168.0.0/16 \
        --method=auto \
        -e "ssh -o Compression=no -o TCPKeepAlive=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=6 -o 'IPQoS=lowdelay throughput' -o Ciphers=chacha20-poly1305@openssh.com,aes128-gcm@openssh.com -o KexAlgorithms=curve25519-sha256 -o ProxyCommand='ssh -W %h:%p $vps1'" \
        0/0
}

# set_terminal_proxy_socks 192.168.1.2 10808
set_terminal_proxy_socks() {
    local default_host="127.0.0.1"
    local host="$default_host"
    local port

    case "$#" in
        1)
            if [[ "$1" == *:* ]]; then
                host="${1%:*}"
                port="${1##*:}"
            else
                port="$1"
            fi
            ;;
        2)
            host="$1"
            port="$2"
            ;;
        *)
            echo "Usage: set_terminal_socks [host] <port>"
            echo "   or: set_terminal_socks <host:port>"
            echo "Default host: $default_host"
            echo "Examples:"
            echo "  set_terminal_socks 1080"
            echo "  set_terminal_socks 192.168.1.10 1080"
            echo "  set_terminal_socks 127.0.0.1:1080"
            return 1
            ;;
    esac

    # Fall back to the default if host was left empty (e.g. ":1080")
    host="${host:-$default_host}"

    if [[ ! "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
        echo "Error: invalid port '$port'"
        return 1
    fi

    export http_proxy="socks5h://$host:$port"
    export https_proxy="socks5h://$host:$port"
    export ALL_PROXY="socks5h://$host:$port"

    echo "✓ Terminal proxy set to socks5h://$host:$port"
}


set_terminal_proxy_v2raya() {
    export http_proxy="http://127.0.0.1:20171"
    export https_proxy="http://127.0.0.1:20171"
    export all_proxy="socks5h://127.0.0.1:20170"
}

set_terminal_proxy_v2rayn() {
    export http_proxy="http://127.0.0.1:10808"
    export https_proxy="http://127.0.0.1:10808"
    export all_proxy="socks5://127.0.0.1:10808"
}

set_terminal_proxy_hiddify() {
    export http_proxy="http://127.0.0.1:12334"
    export https_proxy="http://127.0.0.1:12334"
    export all_proxy="socks5://127.0.0.1:12334"
}

set_terminal_proxy_mhm() {
    export http_proxy="socks5://127.0.0.1:8085"
    export https_proxy="socks5://127.0.0.1:8085"
    export all_proxy="socks5://127.0.0.1:8085"
}

function ssh_proxy_v2rayn() {
    /usr/bin/ssh -o "ProxyCommand=nc -X 5 -x 127.0.0.1:10808 %h %p" "$1"
}

function ssh_proxy_v2raya() {
    /usr/bin/ssh -o "ProxyCommand=nc -X 5 -x 127.0.0.1:20170 %h %p" "$1"
}

# Clear proxy variables set by the v2rayA / v2rayN / Hiddify functions (and any others)
unset_terminal_proxy() {
  unset http_proxy https_proxy all_proxy ftp_proxy no_proxy \
        HTTP_PROXY HTTPS_PROXY ALL_PROXY FTP_PROXY NO_PROXY
  echo "Terminal proxy variables cleared"
}

# Clear everything: SSH tunnels, sshuttle, and all proxy variables
unset_proxy() {
  unset_ssh
  unset_terminal_proxy
  echo "Everything cleared: SSH tunnels, system-wide tunnel, and terminal proxy variables"
}

function vnc-tunnel() {
    if [[ -z "$1" ]]; then
        echo "Usage: vnc-tunnel <ip>"
        echo "Example: vnc-tunnel 95.182.100.214"
        return 1
    fi
    echo "🔒 Starting VNC tunnel to $1..."
    echo "Then connect TigerVNC to localhost:1 (not the remote IP)."
    ssh -o ProxyCommand="nc -X 5 -x 127.0.0.1:1080 %h %p" \
        -L 5901:localhost:5901 \
        -N root@$1
}

function unset_terminal_proxy() {
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy NO_PROXY no_proxy
}

# check_share_proxy 192.168.1.5 8080  #for check_share_proxy
check_shared_proxy() {
  local host="${1:-192.168.1.2}"
  local port="${2:-10808}"
  nc -zv -w 5 "$host" "$port"
}

_detect_port_protocol() {
  local host="$1" port="$2"
  local found=() hex line code banner svc

  # 1) SOCKS5 handshake: offer "no auth", read the 2-byte reply
  hex=$( (printf '\x05\x01\x00'; sleep 1) | nc -w 2 "$host" "$port" 2>/dev/null \
         | head -c 2 | od -An -tx1 | tr -d ' \n')
  case "$hex" in
    0500) found+=("SOCKS5 (no auth)") ;;
    0502) found+=("SOCKS5 (user/pass auth)") ;;
    05ff) found+=("SOCKS5 (auth required, none accepted)") ;;
  esac

  # 2) SOCKS4 CONNECT probe: reply starts with 00 5a/5b/5c/5d
  hex=$( (printf '\x04\x01\x00\x50\x01\x01\x01\x01\x00'; sleep 1) \
         | nc -w 2 "$host" "$port" 2>/dev/null | head -c 2 | od -An -tx1 | tr -d ' \n')
  case "$hex" in
    005a|005b|005c|005d) found+=("SOCKS4") ;;
  esac

  # 3) HTTP proxy probe: send CONNECT, read the status line
  line=$( (printf 'CONNECT example.com:443 HTTP/1.1\r\nHost: example.com:443\r\n\r\n'; sleep 1) \
          | nc -w 2 "$host" "$port" 2>/dev/null | head -1 | tr -d '\r\0')
  if [[ "$line" == HTTP/* ]]; then
    code=$(awk '{print $2}' <<< "$line")
    case "$code" in
      200)         found+=("HTTP proxy (CONNECT ok)") ;;
      407)         found+=("HTTP proxy (auth required)") ;;
      403|502|503) found+=("HTTP proxy (CONNECT refused/failed: $code)") ;;
      *)           found+=("HTTP server (not a proxy, status $code)") ;;
    esac
  fi

  # 4) Banner grab for services that talk first
  if [ ${#found[@]} -eq 0 ]; then
    banner=$( (sleep 1) | nc -w 2 "$host" "$port" 2>/dev/null \
              | head -c 80 | tr -cd '[:print:]\n' | head -1)
    case "$banner" in
      SSH-*)        found+=("SSH") ;;
      220*FTP*|220*ftp*) found+=("FTP") ;;
      220*)         found+=("SMTP/FTP (banner: ${banner:0:40})") ;;
      RFB*)         found+=("VNC") ;;
      *mysql*|*MariaDB*) found+=("MySQL/MariaDB") ;;
      "")           ;;
      *)            found+=("Unknown (banner: ${banner:0:40})") ;;
    esac
  fi

  # 5) Fallback: standard service name
  if [ ${#found[@]} -eq 0 ]; then
    svc=$(getent services "$port/tcp" 2>/dev/null | awk '{print $1}')
    found+=("${svc:+$svc (by port number)}")
    [ -z "${found[0]}" ] && found=("Unknown / silent (maybe TLS or custom)")
  fi

  # Join multiple matches (e.g. mixed-mode proxies answer both SOCKS5 and HTTP)
  local IFS=','
  echo "${found[*]}" | sed 's/,/ + /g'
}

# scan_shared_proxy 192.168.1.2
scan_shared_proxy() {
  local host="${1:-192.168.1.2}"
  local mode="${2:-common}"   # common | all | START-END | single port
  local extra="1080 1081 1082 1086 1087 1088 1089 2080 2081 3128 3129 3306 3389 \
5432 5900 6379 7890 7891 7892 7893 7897 8000 8001 8008 8080 8081 8082 8088 8118 \
8123 8388 8443 8888 8889 9000 9050 9090 9150 9999 10800 10801 10802 10808 10809 \
10810 10811 12345 20170 20171 20172 20173 33210"

  local ports
  case "$mode" in
    common) ports=$({ seq 1 1024; tr ' ' '\n' <<< "$extra"; } | sort -un) ;;
    all)    ports=$(seq 1 65535) ;;
    *-*)    ports=$(seq "${mode%-*}" "${mode#*-}") ;;
    *)      ports="$mode" ;;
  esac

  echo "Scanning $host ($mode: $(wc -w <<< "$ports" | tr -d ' ') ports) ..."
  printf '\n%-8s %s\n' "PORT" "PROTOCOL"
  printf '%-8s %s\n' "----" "--------"

  # Make the helper visible to the child shells spawned by xargs
  local helper_file results_file found
  helper_file=$(mktemp)
  results_file=$(mktemp)
  {
    declare -f _detect_port_protocol 2>/dev/null || typeset -f _detect_port_protocol
  } > "$helper_file"

  echo "$ports" | tr ' ' '\n' \
    | xargs -P 200 -I{} bash -c '
        host="$1"; port="$2"; helper="$3"
        nc -z -w 1 "$host" "$port" 2>/dev/null || exit 0
        source "$helper"
        printf "%-8s %s\n" "$port" "$(_detect_port_protocol "$host" "$port")"
      ' _ "$host" {} "$helper_file" \
    | tee "$results_file"

  found=$(wc -l < "$results_file" | tr -d ' ')
  rm -f "$helper_file" "$results_file"

  echo
  if [ "${found:-0}" -eq 0 ]; then
    echo "No open ports found on $host."
    return 1
  fi
  echo "Done: $found open port(s) on $host."
}


brave_proxy() {
    brave --proxy-server="socks5://127.0.0.1:10808" "$@" &
}

thorium_proxy() {
    thorium-browser --proxy-server="socks5://127.0.0.1:10808" "$@" &
}


#── WIFI ────────────────────────────────────────────────

wifi_me() {
    nmcli con show
}

wifi_list() {
    nmcli device wifi list
}

wifi_active() {
    nmcli connection show --active
}

wifi_on() {
    nmcli radio wifi on
}

wifi_off() {
    nmcli radio wifi off
}

wifi_connect() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Error: Please provide a wifi name"
        echo "Usage: wifi_connect <wifi_name>"
        return 1
    fi
    nmcli --ask device wifi connect "$name"
}

wifi_disconnect() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Error: Please provide a connection name"
        echo "Usage: wifi_disconnect <wifi_name>"
        return 1
    fi
    nmcli connection down "$name"
}

# bonus: rescan available networks
wifi_scan() {
    nmcli device wifi rescan && nmcli device wifi list
}

# bonus: show current signal/bitrate/channel for connected wifi
wifi_status() {
    nmcli -f IN-USE,SSID,SIGNAL,BARS,CHAN,RATE device wifi list | grep '^\*'
}


#── NET ────────────────────────────────────────────────

set_shecan_dns() {
    local conn_name="${1:-DialupInternet}"
    local dns_servers="${2:-178.22.122.101,185.51.200.1}"
    if [ $# -eq 1 ]; then
        dns_servers="$1"
        conn_name="DialupInternet"
    fi
    echo "=== Setting Shecan DNS ==="
    echo "Connection   : $conn_name"
    echo "DNS Servers  : $dns_servers"
    echo "--------------------------------"
    nmcli connection modify "$conn_name" ipv4.dns "$dns_servers"
    nmcli connection modify "$conn_name" ipv4.ignore-auto-dns yes
    echo "Restarting connection..."
    nmcli connection down "$conn_name" && nmcli connection up "$conn_name"
    echo "=== Done! Current resolv.conf ==="
    cat /etc/resolv.conf
}

unset_shecan_dns() {
    local conn_name="${1:-DialupInternet}"
    echo "=== Resetting DNS for: $conn_name ==="
    nmcli connection modify "$conn_name" ipv4.dns ""
    nmcli connection modify "$conn_name" ipv4.ignore-auto-dns no
    nmcli connection up "$conn_name"
    echo "=== DNS Reset Completed ==="
    cat /etc/resolv.conf
}

curl_test() {
    curl https://api.ipify.org
}

scan_ports() {
    if [[ -z "$1" ]]; then
        echo "Usage: scan_ports <IP>"
        return 1
    fi
    sudo nmap -sS -sU --top-ports 100 -T5 --open "$1"
}


bat_info() {
    cat /sys/class/power_supply/BAT*/{status,capacity}
}

ping_all() {
  local count=3
  while [ $# -gt 0 ]; do
    case "$1" in
      -c) count="$2"; shift 2 ;;
      *)  break ;;
    esac
  done

  if [ $# -lt 1 ]; then
    echo "Usage: ping_all [-c count] host1 host2 ..."
    return 1
  fi

  local host tmp i=0 failed=0 f wait_opt limit=$((count * 2 + 3))
  local -a tmo

  # -W means seconds on Linux but milliseconds on macOS
  if [ "$(uname)" = "Darwin" ]; then wait_opt=2000; else wait_opt=2; fi

  if command -v timeout >/dev/null 2>&1; then
    tmo=(timeout "$limit")
  elif command -v gtimeout >/dev/null 2>&1; then
    tmo=(gtimeout "$limit")
  else
    tmo=(perl -e 'alarm shift; exec @ARGV' "$limit")
  fi

  tmp=$(mktemp -d)

  printf '%-26s %-8s %-12s %s\n' "HOST" "LOSS" "AVG" "RESULT"
  printf '%-26s %-8s %-12s %s\n' "----" "----" "---" "------"

  # Subshell keeps zsh/bash from printing "[1] 1234" job messages
  (
    for host in "$@"; do
      i=$((i + 1))
      (
        out=$("${tmo[@]}" ping -c "$count" -W "$wait_opt" "$host" 2>&1)
        rc=$?

        loss=$(grep -Eo '[0-9.]+% packet loss' <<< "$out" | grep -Eo '^[0-9.]+')
        avg=$(grep -E 'min/avg/max' <<< "$out" | awk -F'=' '{print $2}' | awk -F'/' '{print $2}')

        up=0
        if grep -qiE 'cannot resolve|unknown host|not known|name or service' <<< "$out"; then
          result="DNS FAILED"; loss="-"; avg="-"
        elif [ -z "$loss" ]; then
          if [ $rc -eq 124 ] || [ $rc -eq 142 ]; then
            result="HUNG (no reply before timeout)"
          else
            result="FAILED: $(head -1 <<< "$out")"
          fi
          loss="-"; avg="-"
        elif awk -v l="$loss" 'BEGIN{exit !(l >= 100)}'; then
          result="DOWN (no replies)"; loss="100%"; avg="-"
        elif awk -v l="$loss" 'BEGIN{exit !(l > 0)}'; then
          result="UP (packet loss)"; loss="${loss}%"; avg="${avg} ms"; up=1
        else
          result="UP"; loss="0%"; avg="${avg} ms"; up=1
        fi

        echo "$up" > "$tmp/$i.up"
        # One printf per line, printed as soon as this host finishes
        printf '%-26s %-8s %-12s %s\n' "$host" "$loss" "$avg" "$result"
      ) < /dev/null &
    done
    wait
  )

  for f in "$tmp"/*.up; do
    [ "$(cat "$f" 2>/dev/null)" != "1" ] && failed=1
  done

  rm -rf "$tmp"
  return $failed
}

# scan_ssh_server 217.60.39.156 31.56.146.152 104.252.111.25      # user = root
# scan_ssh_server ubuntu 217.60.39.156 31.56.146.152              # user = ubuntu
# scan_ssh_server -u ubuntu 217.60.39.156 31.56.146.152:2222      # explicit user
# scan_ssh_server -p 2222 217.60.39.156 31.56.146.152             # root, default port 2222
scan_ssh_server() {
  local default_port=22 user=root user_set=0
  while [ $# -gt 0 ]; do
    case "$1" in
      -p) default_port="$2"; shift 2 ;;
      -u) user="$2"; user_set=1; shift 2 ;;
      *)  break ;;
    esac
  done

  # No -u given: if the first arg doesn't look like a host, it's the user name
  if [ $user_set -eq 0 ] && [ $# -ge 2 ] \
     && ! [[ "$1" =~ ^[0-9]+(\.[0-9]+){3}(:[0-9]+)?$ ]] && [[ "$1" != *.* ]]; then
    user="$1"; shift
  fi

  if [ $# -lt 1 ]; then
    echo "Usage: check_ssh_port [-u user] [-p default_port] [user_name] host1[:port] host2[:port] ..."
    echo "Default user: root"
    return 1
  fi

  local target host port tmp i=0 failed=0 f
  local -a tmo

  if command -v timeout >/dev/null 2>&1; then
    tmo=(timeout 12)
  elif command -v gtimeout >/dev/null 2>&1; then
    tmo=(gtimeout 12)
  else
    tmo=(perl -e 'alarm shift; exec @ARGV' 12)
  fi

  tmp=$(mktemp -d)

  printf '%-28s %s\n' "TARGET" "RESULT"
  printf '%-28s %s\n' "------" "------"

  (
    for target in "$@"; do
      i=$((i + 1))
      host="${target%%:*}"
      port="$default_port"
      [[ "$target" == *:* ]] && port="${target##*:}"

      (
        out=$("${tmo[@]}" ssh -n \
                  -o BatchMode=yes \
                  -o ConnectTimeout=5 \
                  -o ConnectionAttempts=1 \
                  -o ServerAliveInterval=3 \
                  -o ServerAliveCountMax=1 \
                  -o StrictHostKeyChecking=accept-new \
                  -p "$port" "$user@$host" exit 2>&1)
        rc=$?

        if [ $rc -eq 0 ]; then
          result="OK (login works)"
        elif [ $rc -eq 124 ] || [ $rc -eq 142 ]; then
          result="HUNG (TCP connects but SSH never answers, likely firewall/tarpit)"
        elif grep -qi "permission denied" <<< "$out"; then
          result="PORT OPEN, auth failed (no key / wrong user)"
        elif grep -qi "host key verification failed\|identification has changed" <<< "$out"; then
          result="HOST KEY CHANGED (check ~/.ssh/known_hosts)"
        elif grep -qi "refused" <<< "$out"; then
          result="CONNECTION REFUSED (nothing listening on port $port)"
        elif grep -qi "timed out" <<< "$out"; then
          result="TIMEOUT (host down or port filtered)"
        elif grep -qi "no route\|unreachable" <<< "$out"; then
          result="UNREACHABLE (no route to host)"
        elif grep -qi "could not resolve" <<< "$out"; then
          result="DNS FAILED"
        else
          result="FAILED: $(head -1 <<< "$out")"
        fi

        echo "$rc" > "$tmp/$i.rc"
        printf '%-28s %s\n' "$user@$host:$port" "$result"
      ) < /dev/null &
    done
    wait
  )

  for f in "$tmp"/*.rc; do
    [ "$(cat "$f" 2>/dev/null)" != "0" ] && failed=1
  done

  rm -rf "$tmp"
  return $failed
}

# scan_server_ports                              # common ports on this server
# scan_server_ports 104.252.111.25 all           # all 65535 ports
# scan_server_ports 127.0.0.1 10000-11000        # custom range
# scan_server_ports 104.252.111.25 10808         # single port
scan_server_ports() {
  local host="${1:-127.0.0.1}"
  local mode="${2:-common}"   # common | all | START-END | single port
  local extra="1080 1081 3128 3306 3389 5432 5900 6379 7890 8000 8080 8081 8088 \
8118 8388 8443 8888 9000 9050 9090 10800 10808 10809 10810 12345 20170 27017"

  local ports
  case "$mode" in
    common) ports=$({ seq 1 1024; tr ' ' '\n' <<< "$extra"; } | sort -un) ;;
    all)    ports=$(seq 1 65535) ;;
    *-*)    ports=$(seq "${mode%-*}" "${mode#*-}") ;;
    *)      ports="$mode" ;;
  esac

  echo "Scanning $host ($mode: $(wc -w <<< "$ports") ports) ..."

  local open
  open=$(printf '%s\n' $ports \
    | xargs -P 200 -I{} timeout 1 bash -c \
        '(echo > /dev/tcp/$0/$1) 2>/dev/null && echo $1' "$host" {} \
    | sort -n)

  if [ -z "$open" ]; then
    echo "No open ports found on $host."
    return 1
  fi

  local is_local=0
  case "$host" in 127.*|localhost|"$(hostname -I 2>/dev/null | awk '{print $1}')"|104.252.111.25) is_local=1 ;; esac

  printf '\n%-8s %-16s %s\n' "PORT" "SERVICE" "PROCESS"
  printf '%-8s %-16s %s\n' "----" "-------" "-------"

  local p svc proc
  for p in $open; do
    svc=$(getent services "$p/tcp" 2>/dev/null | awk '{print $1}')
    proc="-"
    if [ $is_local -eq 1 ]; then
      proc=$(sudo ss -Hltnp "sport = :$p" 2>/dev/null \
             | grep -o 'users:(("[^"]*"' | head -1 | sed 's/users:(("//; s/"$//')
      [ -z "$proc" ] && proc="-"
    fi
    printf '%-8s %-16s %s\n' "$p" "${svc:--}" "$proc"
  done
}


#── flush ────────────────────────────────────────────────
#flush save
#flush restore

flush() {
    local ACTION="${1:-restore}"
    local STATE_DIR="$HOME/.config/net-state"

    save_state() {
        mkdir -p "$STATE_DIR"
        echo "[*] Saving clean network state..."
        ip route show default > "$STATE_DIR/default_route"
        nmcli -t -f NAME,STATE,DEVICE con show --active > "$STATE_DIR/active_connections"
        resolvectl status 2>/dev/null > "$STATE_DIR/dns_state"
        cp /etc/resolv.conf "$STATE_DIR/resolv.conf.bak" 2>/dev/null
        ip route | grep default | awk '{print $5}' | head -n1 > "$STATE_DIR/primary_iface"
        echo "[✓] State saved to $STATE_DIR"
        echo "    Primary interface : $(cat $STATE_DIR/primary_iface)"
        echo "    Active connections: $(awk -F: '{print $1}' $STATE_DIR/active_connections | tr '\n' ', ')"
    }

    restore_state() {
        echo "=== Network Hard Reset ==="

        echo "[1/7] Killing VPN/proxy processes..."
        sudo pkill -9 -f openvpn  2>/dev/null
        sudo pkill -9 -f sshuttle 2>/dev/null
        sudo pkill -9 -f v2ray    2>/dev/null
        sudo pkill -9 -f xray     2>/dev/null
        sudo pkill -9 -f v2rayA   2>/dev/null
        sleep 1

        echo "[2/7] Removing virtual interfaces..."
        for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(tun|tap|wg|vpn)'); do
            echo "  ↳ removing $iface"
            sudo ip link set "$iface" down  2>/dev/null
            sudo ip link delete "$iface"    2>/dev/null
        done

        echo "[3/7] Resetting routing tables..."
        sudo ip route flush table main  2>/dev/null
        sudo ip route flush cache       2>/dev/null
        sudo ip rule flush              2>/dev/null
        sudo ip rule add priority 0     lookup local   2>/dev/null
        sudo ip rule add priority 32766 lookup main    2>/dev/null
        sudo ip rule add priority 32767 lookup default 2>/dev/null

        echo "[4/7] Restarting NetworkManager..."
        sudo systemctl stop NetworkManager
        sleep 2
        sudo systemctl start NetworkManager
        sleep 4

        echo "[5/7] Reconnecting..."
        if [[ -f "$STATE_DIR/active_connections" ]]; then
            while IFS=: read -r name state device; do
                echo "  ↳ bringing up: $name (was on $device)"
                nmcli con up "$name" 2>/dev/null && break
            done < "$STATE_DIR/active_connections"
        else
            echo "  ↳ no saved state, using nmcli networking cycle..."
            nmcli networking off
            sleep 2
            nmcli networking on
        fi
        sleep 3

        echo "[6/7] Checking default route..."
        if ! ip route | grep -q default; then
            echo "  ↳ default route missing, restoring..."
            [[ -f "$STATE_DIR/default_route" ]] && sudo ip route add $(cat "$STATE_DIR/default_route") 2>/dev/null
            PRIMARY=$(cat "$STATE_DIR/primary_iface" 2>/dev/null \
                      || ip -o link show | grep -v lo | awk -F': ' '{print $2}' | head -n1)
            nmcli dev connect "$PRIMARY" 2>/dev/null
        else
            echo "  ↳ default route OK: $(ip route | grep default | head -n1)"
        fi

        echo "[7/7] Resetting DNS..."
        sudo resolvectl flush-caches        2>/dev/null
        sudo systemctl restart systemd-resolved 2>/dev/null
        if [[ -f "$STATE_DIR/resolv.conf.bak" ]]; then
            grep -q "nameserver" /etc/resolv.conf 2>/dev/null || \
                sudo cp "$STATE_DIR/resolv.conf.bak" /etc/resolv.conf
        fi

        echo ""
        echo "=== Testing ==="
        sleep 2
        if ping -c 2 -W 3 8.8.8.8 &>/dev/null; then
            echo "✓ Internet OK"
            echo "  Route : $(ip route | grep default | head -n1)"
            echo "  DNS   : $(resolvectl status 2>/dev/null | grep 'DNS Servers' | head -n1 \
                              || grep nameserver /etc/resolv.conf | head -n1)"
        else
            echo "✗ Still no internet."
            echo "  1. sudo systemctl restart NetworkManager && nmcli networking off && nmcli networking on"
            echo "  2. sudo reboot"
        fi
    }

    status() {
        echo "=== Current Network State ==="
        echo "Default route : $(ip route | grep default | head -n1)"
        echo "Active cons   : $(nmcli -t -f NAME,STATE con show --active | head -n3)"
        echo "DNS           : $(resolvectl status 2>/dev/null | grep 'DNS Servers' | head -n1 \
                                || grep nameserver /etc/resolv.conf | head -n1)"
        echo "Interfaces    : $(ip -o link show up | awk -F': ' '{print $2}' | tr '\n' ' ')"
        echo ""
        [[ -d "$STATE_DIR" ]] \
            && echo "Saved state   : $STATE_DIR (clean state exists)" \
            || echo "Saved state   : none — run 'flush save' while network is clean"
    }

    case "$ACTION" in
        save)    save_state    ;;
        restore) restore_state ;;
        status)  status        ;;
        *)
            echo "Usage: flush save | restore | status"
            echo "  save     — snapshot current working network state"
            echo "  restore  — hard reset network back to saved state"
            echo "  status   — show current network + saved state info"
            ;;
    esac
}

#── FORMAT ────────────────────────────────────────────────

clean_claude() {
  local input="$1"
  local output="${2:-cleaned.txt}"

  if [ -z "$input" ]; then
    echo "Usage: clean_claude <input_file> [output_file]"
    return 1
  fi

  sed -e "s/<[^>]*>//g" \
      -e $'s/\xe2\x80\x98/\'/g' \
      -e $'s/\xe2\x80\x99/\'/g' \
      "$input" > "$output"
}


# ==============================================================================
# ALIASES
# ==============================================================================

# --- General ------------------------------------------------------------------
alias vi=vim
alias py="python3"
alias docker-compose="docker compose"
alias reload='source ~/.zshrc'
alias c='clear'

# --- Safety (ask before overwriting / deleting) -------------------------------

alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# --- Navigation ---------------------------------------------------------------

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias mark='pwd > ~/.lastdir'
alias jump='cd $(cat ~/.lastdir 2>/dev/null || echo ~)'

# --- Listing files (the "ls family") ------------------------------------------

alias l='command ls -CF --color=auto'

function ll() {
    printf "\033[1;36m%-4s %-3s %-3s %-3s %-4s  %-10s %-10s %-12s %s\033[0m\n" TYPE USR GRP OTH MODE OWNER GROUP DATE NAME
    printf "\033[2m%-4s %-3s %-3s %-3s %-4s\033[0m\n" "|" rwx rwx rwx oct
    if (( $# == 0 )); then
        command ls -lA
    else
        command ls -ld -- "$@"
    fi | awk 'function o(t){return (substr(t,1,1)=="r"?4:0)+(substr(t,2,1)=="w"?2:0)+(substr(t,3,1)~/[xst]/?1:0)} function s(n){return (n ~ /^\.env/ || n ~ /\.env$/ || n ~ /\.(pem|key|p12|pfx|jks|keystore|ppk|gpg|asc|kdbx|tfvars|tfstate)$/ || n ~ /^id_(rsa|dsa|ecdsa|ed25519)$/ || n ~ /^\.(npmrc|pypirc|netrc|pgpass|my\.cnf|git-credentials|htpasswd|dockercfg|boto|s3cfg|vault_pass)$/ || n ~ /^(credentials|secrets?|token|kubeconfig|wp-config\.php|service-account.*)(\..*)?$/)} $1!="total" {p=$1; ty=substr(p,1,1); name=$9; for(i=10;i<=NF;i++) name=name " " $i; oth=substr(p,8,3); x=substr(oth,3,1); mode=o(substr(p,2,3)) o(substr(p,5,3)) o(oth); sp=(substr(p,4,1)~/[sS]/?4:0)+(substr(p,7,1)~/[sS]/?2:0)+(substr(p,10,1)~/[tT]/?1:0); if (sp) mode=sp mode; d=0; if (ty!="l") { if (substr(p,9,1)=="w" && !(ty=="d" && substr(p,10,1)~/[tT]/)) d=1; if (substr(p,4,1)~/[sS]/ || substr(p,7,1)~/[sS]/) d=1; if (s(tolower(name)) && substr(p,8,1)=="r") d=1 } mp=sprintf("%-4s",mode); if (d) { mp="\033[1;31m" mp "\033[0m"; name="\033[1;31m" name "\033[0m" } if (x=="x" || x=="t") oth=substr(oth,1,2) "\033[1;31m" x "\033[0m"; printf "%-4s %s %s %s %s  %-10s %-10s %-12s %s\n", ty, substr(p,2,3), substr(p,5,3), oth, mp, $3, $4, sprintf("%s %2s %5s",$6,$7,$8), name}'
}

alias ls='printf "\033[1;36m%-4s %-3s %-3s %-3s %-4s  %-10s %-10s %-7s %-12s %s\033[0m\n" TYPE USR GRP OTH MODE OWNER GROUP SIZE DATE NAME; printf "\033[2m%-4s %-3s %-3s %-3s %-4s\033[0m\n" "|" rwx rwx rwx oct; command ls -lAhS | awk '\''function o(t){return (substr(t,1,1)=="r"?4:0)+(substr(t,2,1)=="w"?2:0)+(substr(t,3,1)~/[xst]/?1:0)} function s(n){return (n ~ /^\.env/ || n ~ /\.env$/ || n ~ /\.(pem|key|p12|pfx|jks|keystore|ppk|gpg|asc|kdbx|tfvars|tfstate)$/ || n ~ /^id_(rsa|dsa|ecdsa|ed25519)$/ || n ~ /^\.(npmrc|pypirc|netrc|pgpass|my\.cnf|git-credentials|htpasswd|dockercfg|boto|s3cfg|vault_pass)$/ || n ~ /^(credentials|secrets?|token|kubeconfig|wp-config\.php|service-account.*)(\..*)?$/)} NR>1 {p=$1; ty=substr(p,1,1); name=$9; for(i=10;i<=NF;i++) name=name " " $i; oth=substr(p,8,3); x=substr(oth,3,1); mode=o(substr(p,2,3)) o(substr(p,5,3)) o(oth); sp=(substr(p,4,1)~/[sS]/?4:0)+(substr(p,7,1)~/[sS]/?2:0)+(substr(p,10,1)~/[tT]/?1:0); if (sp) mode=sp mode; d=0; if (ty!="l") { if (substr(p,9,1)=="w" && !(ty=="d" && substr(p,10,1)~/[tT]/)) d=1; if (substr(p,4,1)~/[sS]/ || substr(p,7,1)~/[sS]/) d=1; if (s(tolower(name)) && substr(p,8,1)=="r") d=1 } mp=sprintf("%-4s",mode); if (d) { mp="\033[1;31m" mp "\033[0m"; name="\033[1;31m" name "\033[0m" } if (x=="x" || x=="t") oth=substr(oth,1,2) "\033[1;31m" x "\033[0m"; line=sprintf("%-4s %s %s %s %s  %-10s %-10s %-7s %-12s %s", ty, substr(p,2,3), substr(p,5,3), oth, mp, $3, $4, $5, sprintf("%s %2s %5s",$6,$7,$8), name); if (ty=="d") dd[++nd]=line; else f[++nf]=line} END {for(i=1;i<=nd;i++) print dd[i]; for(i=1;i<=nf;i++) print f[i]}'\'''

alias lb='printf "\033[1;36m%-4s %-3s %-3s %-3s  %-10s %-10s %-7s %-12s %s\033[0m\n" TYPE USR GRP OTH OWNER GROUP SIZE DATE NAME; printf "\033[2m%-4s %-3s %-3s %-3s\033[0m\n" "|" rwx rwx rwx; command ls -lAhS | awk '\''NR>1 {p=$1; name=$9; for(i=10;i<=NF;i++) name=name " " $i; line=sprintf("%-4s %s %s %s  %-10s %-10s %-7s %-12s %s", substr(p,1,1), substr(p,2,3), substr(p,5,3), substr(p,8,3), $3, $4, $5, sprintf("%s %2s %5s",$6,$7,$8), name); if (substr(p,1,1)=="d") d[++nd]=line; else f[++nf]=line} END {for(i=1;i<=nd;i++) print d[i]; for(i=1;i<=nf;i++) print f[i]}'\'''

alias lm='command ls -lhtA'
alias ld='command ls -d .[!.]*/ */ 2>/dev/null'
alias lh='command ls -d .[!.]*'
alias lf='command ls -lhA | grep -v "^d"'
                                                         #   (overrides an older `lf='ls -FA'`)
alias l@='command ls -lA | grep "^l"'
alias lx='find . -maxdepth 1 -type f -executable'
alias lt='du -sh .'

# --- Disk usage ---------------------------------------------------------------

alias df='df -h'
alias dus='ls -lSh'
alias duz='ls -lSh'
alias dud='du -sh .'

# --- Search / colors ----------------------------------------------------------

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='colordiff'
alias tree="command tree -C -I 'node_modules|dist|.git|.next|.gitignore|.DS_Store|.env|.env.local|.cache|.vscode|.idea|coverage|build|out|tmp|.turbo|.eslintcache'"

# --- Files --------------------------------------------------------------------

alias ff='find . -type f -name'
alias fdir='find . -type d -name'
alias tf='tail -f'
alias count='find . -maxdepth 1 -type f | wc -l'

# --- Git ----------------------------------------------------------------------

alias gd='git diff'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --decorate --graph'
alias gla='git log --oneline --decorate --graph --all'

# --- Docker -------------------------------------------------------------------

alias dsa='docker stop $(docker ps -a -q)'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'

# --- Network ------------------------------------------------------------------

alias myip='curl -s myip.dnsomatic.com'
alias localip='ip -4 addr show | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | grep -v 127.0.0.1'
alias ports='ss -tulanp'
alias lsof-port='lsof -i'
alias ping='ping -c 5'

# --- Misc ---------------------------------------------------------------------

alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%Y-%m-%d"'
alias serve='python3 -m http.server 8000'
alias cwd='pwd | tr -d "\n" | xclip -selection clipboard && echo "PWD copied: $(pwd)"'
alias clast='fc -ln -1 | tr -d "\n" | xclip -selection clipboard && echo "Last command copied."'


# ==============================================================================
# FILE PERMISSIONS & GROUPS
# ==============================================================================

# chp <file|dir>... <u|g|o|a combo> <perms>
#   perms: rwx, rw-, r-x, r--, ---  (exact, like r-x)  or  -  (no permissions)
#   chp d1 u rwx
#   chp d1 j.js g r-x
#   chp d1 go r--
#   chp d1 o -
chp() {
    if (( $# < 3 )); then
        echo "usage: chp <file|dir>... <u|g|o|a combo> <rwx|r--|... | ->" >&2
        return 1
    fi
    local who="${@[-2]}" perms="${@[-1]}"
    local files=("${@[1,-3]}")
    local re_who='^[ugoa]+$'
    local re_perms='^([r-][w-][x-]|[rwx]+|-)$'

    [[ "$who" =~ $re_who ]]     || { echo "chp: class must be letters from u,g,o,a" >&2; return 1; }
    [[ "$perms" =~ $re_perms ]] || { echo "chp: perms must look like rwx, r-x, r--, rw or - (none)" >&2; return 1; }

    perms="${perms//-/}"

    chmod "${who}=${perms}" -- "${files[@]}"
}

# setg <file|dir>... <group> [perms]
#   Add a group (via ACL) to files/folders. Default perms: rwx.
#   perms is an optional last arg like rx, rw, r (detected automatically).
setg() {
    if (( $# < 2 )); then
        echo "usage: setg <file|dir>... <group> [perms]" >&2
        return 1
    fi
    local perms="rwx" group re='^([r-][w-][x-]|[rwx]+)$'
    local args=("$@")
    if (( $# >= 3 )) && [[ "${args[-1]}" =~ $re ]]; then
        perms="${args[-1]}"
        args=("${args[1,-2]}")
    fi
    group="${args[-1]}"
    local files=("${args[1,-2]}")
    setfacl -m "g:${group}:${perms}" -- "${files[@]}" 2>/dev/null \
        || sudo setfacl -m "g:${group}:${perms}" -- "${files[@]}"
}

rmg() {
    if (( $# < 2 )); then
        echo "usage: rmg <file|dir>... <group>" >&2
        return 1
    fi
    local group="${@[-1]}"
    local files=("${@[1,-2]}")
    setfacl -x "g:${group}" -- "${files[@]}" 2>/dev/null \
        || sudo setfacl -x "g:${group}" -- "${files[@]}"
}

lg() {
    if (( $# == 0 )); then
        echo "usage: lg <file|dir>..." >&2
        return 1
    fi
    getfacl --omit-header --absolute-names -- "$@" | command grep -E '^(# file|group)'
}

lga() {
    if [[ "$(uname)" == "Darwin" ]]; then
        dscl . list /Groups | sort
    else
        getent group | cut -d: -f1 | sort
    fi
}


# ==============================================================================
# GIT HELPERS
# ==============================================================================

gittest() {
  ssh-add ~/.ssh/fd 2>/dev/null
  ssh -T git@github.com
}

# gitadd [KEY_PATH | -ssh_private KEY_PATH] [-name NAME] [-email EMAIL]
#   Load an SSH key into a fresh agent and set the global git identity.
#   gitadd ~/.ssh/fd
#   gitadd -ssh_private ~/.ssh/fd
#   gitadd -ssh_private ~/.ssh/fd -name "Other" -email other@example.com
gitadd() {
  local key="" arg_name="fadedreams" arg_email="fadedreams7@gmail.com"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -name)
        [[ -z "$2" ]] && { echo "-name needs a value"; return 1; }
        arg_name="$2"; shift 2 ;;
      -email)
        [[ -z "$2" ]] && { echo "-email needs a value"; return 1; }
        arg_email="$2"; shift 2 ;;
      -ssh_private)
        [[ -z "$2" ]] && { echo "-ssh_private needs a path"; return 1; }
        key="$2"; shift 2 ;;
      -*)
        echo "Unknown option: $1"
        echo "Usage: gitadd [KEY_PATH | -ssh_private KEY_PATH] [-name NAME] [-email EMAIL]"
        return 1 ;;
      *)
        key="$1"; shift ;;
    esac
  done

  if [[ -n "$key" ]]; then
    key="${key/#\~/$HOME}"

    if [[ ! -f "$key" ]]; then
      echo "Key not found: $key"
      return 1
    fi

    eval "$(ssh-agent -s)" && ssh-add -k "$key" || return 1
  fi

  git config --global user.name "$arg_name"
  git config --global user.email "$arg_email"

  gitme
}

gitme() {
  local name email
  name=$(git config user.name)
  email=$(git config user.email)

  if [[ -z "$name" && -z "$email" ]]; then
    echo "No git user configured."
    return 1
  fi

  echo "Name:   ${name:-<not set>}"
  echo "Email:  ${email:-<not set>}"
  echo "Source: $(git config --show-origin --get user.email | cut -f1)"
}


# ==============================================================================
# CLIPBOARD: clip / clip_show
#    Works in zsh and bash. Handles macOS, SSH (OSC 52), xclip, xsel, wl-copy.
#
#      clip <file>                 copy a file's contents
#      clip <command> [args...]    run a command and copy its output
#      <cmd> | clip                copy piped output
#      clip_show ...               same, but also prints to the terminal
# ==============================================================================

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

# --- Progress helpers (draw on stderr, only when it's a terminal) --------------

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

# --- Low-level: send a file's exact bytes to the right clipboard ---------------
# With "quiet" it draws nothing (used for periodic refreshes while streaming).
# Usage: _clip_send_file <file> [quiet]
_clip_send_file() {
    local f=$1 q=$2 total rc=0 b64="" chunk=65535 off=0 i=0 cur
    total=$(wc -c <"$f" | tr -d ' ')

    if [[ "$OSTYPE" == "darwin"* ]]; then
        _clip_stream "$f" "$total" "$q" | pbcopy; rc=$?
    elif [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
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

# --- clip: copy silently with progress (nothing printed to the terminal) -------
# Usage: clip <file> | clip <command> [args...] | <cmd> | clip
clip() {
    local tmp line n=0 interrupted=0 last=$SECONDS rc=0 size pid i=0
    local is_file=0 had_monitor=0

    # ---- Piped input (streaming-friendly) ----
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
            if [ $((SECONDS - last)) -ge 2 ]; then
                _clip_send_file "$tmp" quiet
                last=$SECONDS
            fi
        done

        trap - INT
        exec 3>&-
        _clip_progress_clear

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

    # ---- Decide: file or command ----
    if [ $# -eq 1 ] && [ -f "$1" ] && [ -r "$1" ]; then
        is_file=1
    elif [ $# -gt 1 ] && [ -e "$1" ]; then
        echo "Error: '$1' exists as a file, but you passed extra arguments ($*)." >&2
        echo "If the filename has spaces, quote it: clip \"$*\"" >&2
        return 1
    fi

    # ---- File mode ----
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

    # ---- Command mode (streaming-friendly) ----
    tmp=$(mktemp) || return 1

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

# --- clip_show: like clip, but also prints the content to the terminal ---------
# Usage: clip_show <file> | clip_show <command> [args...] | <cmd> | clip_show
clip_show() {
    local tmp line n=0 interrupted=0 last=$SECONDS rc=0 size rcf

    # ---- Piped input: print each line live, copy as it arrives ----
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

    # ---- File mode: show the file, then copy it ----
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

    # ---- Command mode: run it, show output live, copy as it arrives ----
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


# ==============================================================================
# PORTS & PROCESSES
# ==============================================================================

# --- Ports --------------------------------------------------------------------

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

# ssh_port_forward <local_port:remote_port> <user@host>
#   ssh_port_forward 8080:8080 m@5.161.157.120
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

# --- Processes ----------------------------------------------------------------

kill_process() {
    if [ -z "$1" ]; then
        echo "Usage: kill_process <process_name>"
        echo "Example: kill_process v2ray"
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
    pkill -9 -f "$process_name" 2>/dev/null

    sleep 0.5
    if pgrep -f "$process_name" > /dev/null; then
        echo "✗ Some processes are still running (you may need sudo):"
        pgrep -fa "$process_name"
        return 1
    else
        echo "✓ Successfully killed processes"
    fi
}
alias killprocess='kill_process'

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


# ==============================================================================
# PACKAGE MANAGER UNLOCK HELPERS
#    Use when apt / dnf / pacman is stuck on a lock or half-finished state.
#    Paste-safe: no "set -e" and no "exit" (they use "return").
# ==============================================================================

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


# ==============================================================================
# PROXY & SSH TUNNELS
# ==============================================================================

# --- Internal helpers ---------------------------------------------------------

_set_no_proxy() {
  local base="${NO_PROXY:-$no_proxy}" item
  for item in localhost 127.0.0.1 ::1; do
    case ",$base," in
      *",$item,"*) ;;
      *) base="${base:+$base,}$item" ;;
    esac
  done
  export NO_PROXY="$base" no_proxy="$base"
}

_clear_proxy_vars() {
  unset ALL_PROXY all_proxy \
        HTTP_PROXY http_proxy \
        HTTPS_PROXY https_proxy \
        FTP_PROXY ftp_proxy
  _set_no_proxy
}

# Export proxy URLs in both upper and lower case.
# Usage: _export_proxy_vars <http_url> <https_url> <all_url>
_export_proxy_vars() {
  export HTTP_PROXY="$1"  http_proxy="$1" \
         HTTPS_PROXY="$2" https_proxy="$2" \
         ALL_PROXY="$3"   all_proxy="$3"
  _set_no_proxy
}

function ssh() {
    if [[ "$TERM" == "xterm-ghostty" ]]; then
        TERM=xterm-256color command ssh "$@"
    else
        command ssh "$@"
    fi
}

# --- SSH-based tunnels --------------------------------------------------------

# set_ssh_terminal user@host [port]
#   Route THIS terminal through an SSH SOCKS tunnel (default port 10810).
set_ssh_terminal() {
  local target="$1"
  local port="${2:-10810}"
  local url="socks5h://127.0.0.1:$port"
  local sock="$HOME/.ssh/proxy-${target//[^a-zA-Z0-9]/_}.sock"

  if [[ "$target" != *@* ]]; then
    echo "Usage: set_ssh_terminal user@host [port]"
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

  _export_proxy_vars "$url" "$url" "$url"

  echo "This terminal now goes through $target (socks5h://127.0.0.1:$port)"
}

# set_ssh_all user@host      Route the ENTIRE system through an SSH server
# set_ssh_all off            Stop it
#   set_ssh_all root@45.38.23.244
#   curl https://ifconfig.me      # should show the server's IP, from any app
#   set_ssh_all off
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

# set_ssh_port <port> user@host    SOCKS tunnel on a chosen local port
# set_ssh_port off <port>          Stop it
#   set_ssh_port 10808 root@45.38.23.244
#   curl https://ifconfig.me
#   set_ssh_port off 10808
set_ssh_port() {
  local port="$1"
  local target="$2"
  local sock="$HOME/.ssh/sshport-${port}.sock"
  local url="socks5h://127.0.0.1:$port"

  if [[ "$port" == "off" || "$port" == "stop" ]]; then
    local p="$2"
    sock="$HOME/.ssh/sshport-${p}.sock"
    _clear_proxy_vars
    ssh -S "$sock" -O exit dummy 2>/dev/null \
      && echo "Tunnel on port $p stopped, proxy vars cleared" \
      || echo "No tunnel on port $p, proxy vars cleared"
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

  _export_proxy_vars "$url" "$url" "$url"

  echo "SOCKS5 on 127.0.0.1:$port via $target (this terminal is using it)"
}

unset_ssh() {
  local pidfile="/tmp/set_ssh_all.pid"
  local sock count=0

  if sudo test -f "$pidfile"; then
    sudo kill "$(sudo cat "$pidfile")" 2>/dev/null
    sudo rm -f "$pidfile"
    echo "Stopped system-wide tunnel (set_ssh_all)"
  fi

  while IFS= read -r sock; do
    [[ -n "$sock" ]] || continue
    if ssh -S "$sock" -O exit dummy 2>/dev/null; then
      echo "Closed tunnel: $(basename "$sock")"
      count=$((count + 1))
    fi
    rm -f "$sock"
  done < <(find "$HOME/.ssh" -maxdepth 1 \( -name 'sshport-*.sock' -o -name 'proxy-*.sock' \) 2>/dev/null)

  _clear_proxy_vars
  echo "Proxy env vars cleared in this terminal ($count SOCKS tunnel(s) closed)"
}

# set_ssh_proxy_jump <user1@vps1> <user2@vps2>
#   Route everything through vps2, reaching it via vps1 (double hop, sshuttle).
set_ssh_proxy_jump() {
    local vps1="$1"
    local vps2="$2"

    if [ -z "$vps1" ] || [ -z "$vps2" ]; then
        echo "Error: Please provide both VPS user@ip"
        echo "Usage: set_ssh_proxy_jump <user1@vps1_ip> <user2@vps2_ip>"
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

# --- Terminal-only proxies (env vars) -----------------------------------------

# set_terminal_proxy_socks [host] <port>      or      <host:port>
#   set_terminal_proxy_socks 1080
#   set_terminal_proxy_socks 192.168.1.10 1080
#   set_terminal_proxy_socks 127.0.0.1:1080
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
            echo "Usage: set_terminal_proxy_socks [host] <port>"
            echo "   or: set_terminal_proxy_socks <host:port>"
            echo "Default host: $default_host"
            echo "Examples:"
            echo "  set_terminal_proxy_socks 1080"
            echo "  set_terminal_proxy_socks 192.168.1.10 1080"
            echo "  set_terminal_proxy_socks 127.0.0.1:1080"
            return 1
            ;;
    esac

    # Fall back to the default if host was left empty (e.g. ":1080")
    host="${host:-$default_host}"

    if [[ ! "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
        echo "Error: invalid port '$port'"
        return 1
    fi

    local url="socks5h://$host:$port"
    _export_proxy_vars "$url" "$url" "$url"

    echo "Terminal proxy set to $url"
}

# set_terminal_proxy_http [host] <port>   (host defaults to 127.0.0.1)
#   set_terminal_proxy_http 7890
set_terminal_proxy_http() {
    local host="127.0.0.1" port
    case "$#" in
        1) port="$1" ;;
        2) host="$1"; port="$2" ;;
        *) echo "Usage: set_terminal_proxy_http [host] <port>"; return 1 ;;
    esac
    local url="http://$host:$port"
    _export_proxy_vars "$url" "$url" ""
    unset ALL_PROXY all_proxy
    echo "Terminal proxy set to $url"
}

set_terminal_proxy_v2raya() {
    _export_proxy_vars "http://127.0.0.1:20171" "http://127.0.0.1:20171" "socks5h://127.0.0.1:20170"
}

set_terminal_proxy_v2rayn() {
    _export_proxy_vars "http://127.0.0.1:10808" "http://127.0.0.1:10808" "socks5://127.0.0.1:10808"
}

set_terminal_proxy_hiddify() {
    _export_proxy_vars "http://127.0.0.1:12334" "http://127.0.0.1:12334" "socks5://127.0.0.1:12334"
}

set_terminal_proxy_mhm() {
    _export_proxy_vars "socks5://127.0.0.1:8085" "socks5://127.0.0.1:8085" "socks5://127.0.0.1:8085"
}

unset_terminal_proxy() {
  _clear_proxy_vars
  echo "Terminal proxy variables cleared (NO_PROXY=$NO_PROXY)"
}

unset_proxy() {
  unset_ssh
  unset_terminal_proxy
  echo "Everything cleared: SSH tunnels, system-wide tunnel, and terminal proxy variables"
}

# --- SSH / apps through a local proxy -----------------------------------------

function ssh_proxy_v2rayn() {
    /usr/bin/ssh -o "ProxyCommand=nc -X 5 -x 127.0.0.1:10808 %h %p" "$1"
}

function ssh_proxy_v2raya() {
    /usr/bin/ssh -o "ProxyCommand=nc -X 5 -x 127.0.0.1:20170 %h %p" "$1"
}

function vnc-tunnel() {
    if [[ -z "$1" ]]; then
        echo "Usage: vnc-tunnel <ip>"
        echo "Example: vnc-tunnel 95.182.100.214"
        return 1
    fi
    echo "Starting VNC tunnel to $1..."
    echo "Then connect TigerVNC to localhost:1 (not the remote IP)."
    ssh -o ProxyCommand="nc -X 5 -x 127.0.0.1:1080 %h %p" \
        -L 5901:localhost:5901 \
        -N root@$1
}

brave_proxy() {
    brave --proxy-server="socks5://127.0.0.1:10808" "$@" &
}

thorium_proxy() {
    thorium-browser --proxy-server="socks5://127.0.0.1:10808" "$@" &
}

# --- Proxy diagnostics --------------------------------------------------------

check_shared_proxy() {
  local host="${1:-192.168.1.2}"
  local port="${2:-10808}"
  nc -zv -w 5 "$host" "$port"
}

_detect_port_protocol() {
  local host="$1" port="$2"
  local found=() hex line code banner svc

  hex=$( (printf '\x05\x01\x00'; sleep 1) | nc -w 2 "$host" "$port" 2>/dev/null \
         | head -c 2 | od -An -tx1 | tr -d ' \n')
  case "$hex" in
    0500) found+=("SOCKS5 (no auth)") ;;
    0502) found+=("SOCKS5 (user/pass auth)") ;;
    05ff) found+=("SOCKS5 (auth required, none accepted)") ;;
  esac

  hex=$( (printf '\x04\x01\x00\x50\x01\x01\x01\x01\x00'; sleep 1) \
         | nc -w 2 "$host" "$port" 2>/dev/null | head -c 2 | od -An -tx1 | tr -d ' \n')
  case "$hex" in
    005a|005b|005c|005d) found+=("SOCKS4") ;;
  esac

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

  if [ ${#found[@]} -eq 0 ]; then
    banner=$( (sleep 1) | nc -w 2 "$host" "$port" 2>/dev/null \
              | head -c 80 | tr -cd '[:print:]\n' | head -1)
    case "$banner" in
      SSH-*)             found+=("SSH") ;;
      220*FTP*|220*ftp*) found+=("FTP") ;;
      220*)              found+=("SMTP/FTP (banner: ${banner:0:40})") ;;
      RFB*)              found+=("VNC") ;;
      *mysql*|*MariaDB*) found+=("MySQL/MariaDB") ;;
      "")                ;;
      *)                 found+=("Unknown (banner: ${banner:0:40})") ;;
    esac
  fi

  if [ ${#found[@]} -eq 0 ]; then
    svc=$(getent services "$port/tcp" 2>/dev/null | awk '{print $1}')
    found+=("${svc:+$svc (by port number)}")
    [ -z "${found[0]}" ] && found=("Unknown / silent (maybe TLS or custom)")
  fi

  # Join multiple matches (e.g. mixed-mode proxies answer both SOCKS5 and HTTP)
  local IFS=','
  echo "${found[*]}" | sed 's/,/ + /g'
}

# scan_shared_proxy [host] [common|all|START-END|port]
#   Scan a host for open ports and identify each one's protocol.
#   scan_shared_proxy 192.168.1.2
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

# test_proxy [host] [port]   Try http/socks5h/socks5/socks4a against google.com
#   test_proxy                      # defaults: 192.168.1.2 10808
#   test_proxy 192.168.1.5 7890
test_proxy() {
  local host="${1:-192.168.1.2}"
  local port="${2:-10808}"
  local url="https://www.google.com"
  local scheme code ok=1

  echo "Testing proxy $host:$port -> $url ..."
  for scheme in http socks5h socks5 socks4a; do
    code=$(curl -s -o /dev/null -m 8 -w '%{http_code}' \
           -x "$scheme://$host:$port" "$url" 2>/dev/null)
    if [ -n "$code" ] && [ "$code" != "000" ]; then
      echo "  OK:   $scheme (HTTP $code)"
      ok=0
    else
      echo "  FAIL: $scheme"
    fi
  done

  return $ok
}

_set_no_proxy


# ==============================================================================
# NETWORK
# ==============================================================================

# --- Wi-Fi (NetworkManager) ---------------------------------------------------

wifi_me()      { nmcli con show; }                    # all saved connections
wifi_list()    { nmcli device wifi list; }            # networks in range
wifi_active()  { nmcli connection show --active; }    # currently active
wifi_on()      { nmcli radio wifi on; }
wifi_off()     { nmcli radio wifi off; }

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

wifi_scan() {
    nmcli device wifi rescan && nmcli device wifi list
}

wifi_status() {
    nmcli -f IN-USE,SSID,SIGNAL,BARS,CHAN,RATE device wifi list | grep '^\*'
}

# --- DNS (Shecan) -------------------------------------------------------------

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

# --- Quick checks -------------------------------------------------------------

curl_test() {          # print the public IP
    curl https://api.ipify.org
}

bat_info() {           # battery status + percentage
    cat /sys/class/power_supply/BAT*/{status,capacity}
}

scan_ports() {
    if [[ -z "$1" ]]; then
        echo "Usage: scan_ports <IP>"
        return 1
    fi
    sudo nmap -sS -sU --top-ports 100 -T5 --open "$1"
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

# ssh_test [-u user] [-p default_port] [user_name] host1[:port] host2[:port] ...
#   Check whether SSH login works on several hosts in parallel.
#   ssh_test 217.60.39.156 31.56.146.152 104.252.111.25      # user = root
#   ssh_test ubuntu 217.60.39.156 31.56.146.152              # user = ubuntu
#   ssh_test -u ubuntu 217.60.39.156 31.56.146.152:2222      # explicit user
#   ssh_test -p 2222 217.60.39.156 31.56.146.152             # custom default port
ssh_test() {
  local default_port=22 user=root user_set=0
  while [ $# -gt 0 ]; do
    case "$1" in
      -p) default_port="$2"; shift 2 ;;
      -u) user="$2"; user_set=1; shift 2 ;;
      *)  break ;;
    esac
  done

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

# scan_server_ports [host] [common|all|START-END|port]
#   Fast open-port scan with service name and owning process (for local hosts).
#   scan_server_ports                              # common ports on this server
#   scan_server_ports 104.252.111.25 all           # all 65535 ports
#   scan_server_ports 127.0.0.1 10000-11000        # custom range
#   scan_server_ports 104.252.111.25 10808         # single port
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

# --- flush: snapshot and hard-reset the network --------------------------------
#   flush save      snapshot the current working network state
#   flush restore   kill VPNs/proxies, reset routes + NetworkManager + DNS
#   flush status    show current network state
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


# ==============================================================================
# QUICK DEV SERVERS  (serve the current directory; default port 3000)
# ==============================================================================

pyserver() {                                   # Python (built in)
    python3 -m http.server "${1:-3000}"
}

jsserver() {                                   # Node; npx fetches the package on first run
    npx --yes http-server -p "${1:-3000}"
}

rustserver() {                                 # needs: cargo install miniserve
    miniserve -p "${1:-3000}" .
}

phpserver() {                                  # PHP built-in dev server
    php -S "0.0.0.0:${1:-3000}"
}


# ==============================================================================
# SYSTEM MONITOR: syscheck
#     Live dashboard: CPU, memory, swap/zram, disk, network, top processes.
#     Usage: syscheck [interval_seconds=2] [rows=8]
#     Keys:  q quit · g group/ungroup · c sort cpu/mem · +/- rows
# ==============================================================================

_syscheck_frame() {
  local dir=$1 rows=$2 cols=$3 mode=$4 group=$5 iv=$6 hz=$7 nrows=$8
  {
    cat "$dir/state"
    echo "T0 $(date +%s.%N)"
    awk '/^cpu/ {print "C", $0}' /proc/stat
    awk '{print "LA", $1, $2, $3}' /proc/loadavg
    awk '{print "UP", $1}' /proc/uptime
    awk 'NR>2 {gsub(/:/," "); print "N", $0}' /proc/net/dev
    free -b | sed 's/^/F /'
    zramctl --bytes --noheadings --raw -o NAME,ALGORITHM,DISKSIZE,DATA,COMPR,TOTAL 2>/dev/null | sed 's/^/Z /'
    swapon --show=NAME,TYPE,SIZE,USED,PRIO --bytes --noheadings --raw 2>/dev/null | sed 's/^/S /'
    df -B1 --output=size,used,target -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs 2>/dev/null | awk 'NR>1 {print "D", $0}'
    find -L /sys/class/thermal -maxdepth 2 -name temp -type f -exec cat {} + 2>/dev/null | sed 's/^/TT /'
    find /sys/class/power_supply -maxdepth 1 -name 'BAT*' -exec sh -c 'echo "BB $(cat "$1/capacity") $(cat "$1/status")"' _ {} \; 2>/dev/null
    grep -H '^some' /proc/pressure/cpu /proc/pressure/memory /proc/pressure/io 2>/dev/null |
      awk '{n=split($1,a,"/"); sub(/:.*/,"",a[n]); split($2,v,"="); print "PR", a[n], v[2]}'
    command -v systemctl >/dev/null && systemctl --failed --no-legend --plain 2>/dev/null | awk 'END {print "FU", NR}'
    ps -eo pid=,rss=,etime=,args= 2>/dev/null | sed 's/^ */P /'
    cat /proc/[0-9]*/stat 2>/dev/null | sed 's/^/K /'
  } | awk -v host="$(hostname)" -v now="$(date +%H:%M:%S)" -v rows="$rows" -v cols="$cols" \
          -v mode="$mode" -v group="$group" -v iv="$iv" -v hz="$hz" -v nrows="$nrows" -v sf="$dir/state.new" '
  function human(b) { return b >= 2^30 ? sprintf("%.1fG", b/2^30) : b >= 2^20 ? sprintf("%.0fM", b/2^20) : sprintf("%.0fK", b/1024) }
  function rate(b)  { return b >= 2^20 ? sprintf("%.1f MB/s", b/2^20) : sprintf("%.0f KB/s", b/1024) }
  function dur(s,   d, h, m) { d = int(s/86400); h = int(s%86400/3600); m = int(s%3600/60); return (d ? d "d " : "") (h || d ? h "h " : "") m "m" }
  function col(f) { return f < .6 ? G : f < .85 ? Y : Rd }
  function bar(f, w,   i, n, s) {
    if (f > 1) f = 1; if (f < 0) f = 0
    n = int(f*w + 0.5); s = col(f)
    for (i = 1; i <= w; i++) { if (i == n+1) s = s D; s = s (i <= n ? "█" : "░") }
    return s Z0
  }
  function mbar(f, w,   i, n, s) {
    n = int(f*w + 0.5); s = (f > .8 ? M : f > .5 ? Bl : C)
    for (i = 1; i <= w; i++) { if (i == n+1) s = s D; s = s (i <= n ? "█" : "░") }
    return s Z0
  }
  function push(str, v,   a, k, i, o) {
    k = split(str " " v, a, " "); o = ""
    for (i = (k > W ? k-W+1 : 1); i <= k; i++) o = o (o == "" ? "" : " ") a[i]
    return o
  }
  function smax(str,   a, k, i, m) { k = split(str, a, " "); m = 0; for (i = 1; i <= k; i++) if (a[i]+0 > m) m = a[i]+0; return m }
  function spark(str, mx,   a, k, i, s, v) {
    k = split(str, a, " "); s = ""; if (mx <= 0) mx = 1
    for (i = 1; i <= k; i++) { v = a[i]/mx; if (v > 1) v = 1; s = s sp[int(v*7.999)+1] }
    return s
  }
  function emit(s) { L[++nl] = s }
  function sect(s) { emit(""); emit("  " B C s Z0 " " D "────────────────────────────────────────" Z0) }
  function pline(label, f, text) { emit(sprintf("  %s%-6s%s %s %s%3.0f%%%s  %s", B, label, Z0, bar(f, 24), B, f*100, Z0, text)) }
  function base(p,   a, k) { k = split(p, a, "/"); return a[k] }

  BEGIN { Z0="\033[0m"; D="\033[2m"; B="\033[1m"; G="\033[32m"; Y="\033[33m"; Rd="\033[31m"; C="\033[36m"; M="\033[35m"; Bl="\033[34m"
          split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █", sp, " "); W = 30 }

  $1=="T0" { t0=$2 }
  $1=="PT" { pt=$2; havep=1 }
  $1=="PN" { prx=$2; ptx=$3 }
  $1=="PK" { pk[$2]=$3 }
  $1=="HC" { hc=substr($0,4) }  $1=="HM" { hm=substr($0,4) }
  $1=="HR" { hr=substr($0,4) }  $1=="HT" { ht=substr($0,4) }
  $1=="PC" { t=0; for (i=3;i<=10;i++) t+=$i; ptot[$2]=t; pidle[$2]=$6+$7 }
  $1=="C"  { t=0; for (i=3;i<=10;i++) t+=$i; ctot[$2]=t; cidle[$2]=$6+$7
             if ($2!="cpu") { nc++; cname[nc]=$2 }
             print "P" $0 > sf }
  $1=="N" && $2 !~ /^(lo$|veth|docker|br-)/ { rx+=$3; tx+=$11 }
  $1=="LA" { l1=$2; l5=$3; l15=$4 }
  $1=="UP" { upt=$2 }
  $1=="TT" { if ($2/1000 > tmax) tmax=$2/1000 }
  $1=="BB" { bcap=$2; bst=$3 }
  $1=="PR" { psi[$2]=$3; haspsi=1 }
  $1=="FU" { fu=$2; hasfu=1 }
  $1=="F" && $2=="Mem:"  { mt=$3; mu=$4; mc=$7; ma=$8 }
  $1=="F" && $2=="Swap:" { st=$3; su=$4 }
  $1=="Z" { zn++; zname[zn]=$2; zalg[zn]=$3; zsize[zn]=$4; zdata[zn]=$5; zcomp[zn]=$6; ztot[zn]=$7 }
  $1=="S" { sn++; sname[sn]=$2; stype[sn]=$3; ssize[sn]=$4; sused[sn]=$5; sprio[sn]=$6 }
  $1=="D" && $2>0 { k=$2 "," $3; if (!(k in dseen)) { dseen[k]=1; dn++; dsize[dn]=$2; dused[dn]=$3; tg=$4; for (i=5;i<=NF;i++) tg=tg " " $i; dtgt[dn]=tg } }
  $1=="K" { ln=substr($0,3); i=index(ln," ("); id=substr(ln,1,i-1)
            if (match(ln, /\) [^)]*$/)) { split(substr(ln,RSTART+2), kf, " "); tk[id]=kf[12]+kf[13] }
            print "PK " id " " tk[id] > sf }
  $1=="P" { pn++; ppid[pn]=$2; prss[pn]=$3; pet[pn]=$4
            exe=$5; name = (exe ~ /^\//) ? base(exe) : exe
            if (name ~ /^(python[0-9.]*|node|java|ruby|perl|bash|sh|zsh)$/ && $6 != "" && $6 !~ /^-/) name = name " " base($6)
            ct=""
            if ($0 ~ /-contentproc/) ct=$NF
            else if (match($0, /--type=[a-zA-Z-]+/)) ct=substr($0, RSTART+7, RLENGTH-7)
            pname[pn]=name; ptype[pn]=ct }

  END {
    dt = (havep && t0 > pt) ? t0 - pt : 0

    # ---- header ----
    emit("")
    emit(sprintf("  %s%s%s%s  %s·  %s  ·  up %s%s", B, C, host, Z0, D, now, dur(upt), Z0))
    s = sprintf("  %sload%s %s%s %s %s%s", D, Z0, (l1/nc < .7 ? G : l1/nc < 1 ? Y : Rd), l1, l5, l15, Z0)
    if (tmax > 0) s = s sprintf("  %s·%s  %s%d°C%s", D, Z0, (tmax < 65 ? G : tmax < 80 ? Y : Rd), tmax, Z0)
    if (bcap != "") s = s sprintf("  %s·%s  bat %s%% %s%s%s", D, Z0, bcap, D, tolower(bst), Z0)
    if (hasfu) s = s sprintf("  %s·%s  %s%d failed unit%s%s", D, Z0, (fu > 0 ? Rd : D), fu, (fu == 1 ? "" : "s"), Z0)
    emit(s)
    if (haspsi) emit(sprintf("  %spressure%s  cpu %s%s%%%s  mem %s%s%%%s  io %s%s%%%s  %s(stall avg10)%s",
        D, Z0, (psi["cpu"] < 5 ? G : psi["cpu"] < 20 ? Y : Rd), psi["cpu"], Z0,
        (psi["memory"] < 5 ? G : psi["memory"] < 20 ? Y : Rd), psi["memory"], Z0,
        (psi["io"] < 5 ? G : psi["io"] < 20 ? Y : Rd), psi["io"], Z0, D, Z0))

    # ---- cpu ----
    f = 0
    if (havep && ctot["cpu"] > ptot["cpu"]) f = 1 - (cidle["cpu"]-pidle["cpu"])/(ctot["cpu"]-ptot["cpu"])
    if (f < 0) f = 0
    if (havep) hc = push(hc, f*100)
    print "HC " hc > sf
    sect("CPU")
    pline("CPU", f, sprintf("%s%d threads%s   %s%s%s", D, nc, Z0, C, spark(hc, 100), Z0))
    s = ""
    for (i = 1; i <= nc; i++) { k = cname[i]; f = 0
      if (havep && ctot[k] > ptot[k]) f = 1 - (cidle[k]-pidle[k])/(ctot[k]-ptot[k])
      if (f < 0) f = 0; if (f > 1) f = 1
      s = s col(f) sp[int(f*7.999)+1] Z0 }
    emit(sprintf("  %s%-6s%s %s", B, "cores", Z0, s))

    # ---- memory ----
    sect("MEMORY")
    f = mt ? mu/mt : 0
    hm = push(hm, f*100); print "HM " hm > sf
    pline("RAM", f, sprintf("%7s / %-7s %s· avail %s · cache %s%s  %s%s%s", human(mu), human(mt), D, human(ma), human(mc), Z0, C, spark(hm, 100), Z0))
    if (st > 0) pline("Swap", su/st, sprintf("%7s / %-7s", human(su), human(st)))
    else emit(sprintf("  %s%-6s%s %soff%s", B, "Swap", Z0, D, Z0))
    for (i = 1; i <= zn; i++) {
      r = zcomp[i] ? zdata[i]/zcomp[i] : 0
      pline(base(zname[i]), zsize[i] ? zdata[i]/zsize[i] : 0, sprintf("%7s / %-7s %s%s · %.1f:1 · uses %s real RAM%s", human(zdata[i]), human(zsize[i]), D, zalg[i], r, human(ztot[i]), Z0))
    }
    for (i = 1; i <= sn; i++) if (sname[i] !~ /zram/)
      pline(base(sname[i]), ssize[i] ? sused[i]/ssize[i] : 0, sprintf("%7s / %-7s %s%s · prio %s%s", human(sused[i]), human(ssize[i]), D, stype[i], sprio[i], Z0))

    # ---- disk ----
    if (dn) {
      sect("DISK")
      for (i = 1; i <= dn && i <= 5; i++) { tg = dtgt[i]; if (length(tg) > 6) tg = substr(tg, length(tg)-5)
        pline(tg, dused[i]/dsize[i], sprintf("%7s / %-7s %s%s%s", human(dused[i]), human(dsize[i]), D, dtgt[i], Z0)) }
    }

    # ---- network ----
    rr = 0; tr = 0
    if (havep && dt > 0) { rr = (rx-prx)/dt; tr = (tx-ptx)/dt; if (rr < 0) rr = 0; if (tr < 0) tr = 0
      hr = push(hr, rr); ht = push(ht, tr) }
    print "PN " rx " " tx > sf; print "HR " hr > sf; print "HT " ht > sf; print "PT " t0 > sf
    mr = smax(hr); if (mr < 10240) mr = 10240
    mtx = smax(ht); if (mtx < 10240) mtx = 10240
    sect("NETWORK")
    emit(sprintf("  %s↓ %-11s%s %s%s%s", C, rate(rr), Z0, C, spark(hr, mr), Z0))
    emit(sprintf("  %s↑ %-11s%s %s%s%s   %ssince boot: ↓ %s  ↑ %s%s", M, rate(tr), Z0, M, spark(ht, mtx), Z0, D, human(rx), human(tx), Z0))

    # ---- processes ----
    ne = 0
    for (i = 1; i <= pn; i++) {
      id = ppid[i]; c = 0
      if (havep && dt > 0 && (id in pk) && (id in tk)) c = (tk[id]-pk[id])/hz/dt*100
      if (c < 0) c = 0
      if (group) { key = pname[i]; if (!(key in gi)) { gi[key] = ++ne; en[ne] = key }; g = gi[key] }
      else { g = ++ne; en[g] = pname[i] (ptype[i] != "" ? " · " ptype[i] : ""); eid[g] = id; eet[g] = pet[i] }
      er[g] += prss[i]; ec[g] += c; ek[g]++
    }
    avail = rows - 1 - nl - 4; if (nrows > avail) nrows = avail; if (nrows < 3) nrows = 3
    top = nrows < ne ? nrows : ne; mx = 0
    for (r = 1; r <= top; r++) {
      b = 0; bv = -1
      for (g = 1; g <= ne; g++) if (!used[g]) { v = (mode == "cpu") ? ec[g] : er[g]; if (v > bv) { bv = v; b = g } }
      used[b] = 1; ord[r] = b; if (er[b] > mx) mx = er[b]
    }
    sect(sprintf("TOP %d · by %s%s", top, (mode == "cpu" ? "cpu" : "memory"), (group ? " · grouped" : "")))
    emit(sprintf("  %s%-7s %6s %6s  %-12s %7s %10s  %s%s", D, (group ? "COUNT" : "PID"), "CPU", "MEM", "", "RSS", (group ? "" : "UP"), "PROCESS", Z0))
    w = cols - 58; if (w < 10) w = 10
    for (r = 1; r <= top; r++) { g = ord[r]
      cc = ec[g] >= 50 ? Rd : ec[g] >= 15 ? Y : G
      emit(sprintf("  %s%-7s%s %s%5.1f%%%s %5.1f%%  %s %7s %s%10s%s  %s%s%s",
        D, (group ? "x" ek[g] : eid[g]), Z0, cc, ec[g], Z0, (mt ? er[g]*1024/mt*100 : 0),
        mbar(mx ? er[g]/mx : 0, 12), human(er[g]*1024), D, (group ? "" : eet[g]), Z0, B, substr(en[g], 1, w), Z0))
    }
    emit("")
    emit(sprintf("  %sq quit · g group/ungroup · c sort cpu/mem · +/- rows · every %ss%s", D, iv, Z0))

    lim = rows - 1; if (lim > nl) lim = nl
    for (i = 1; i <= lim; i++) printf "%s\033[K\n", L[i]
    printf "\033[J"
  }'
  mv -f "$dir/state.new" "$dir/state" 2>/dev/null
}

syscheck() {
  local interval="${1:-2}" nrows="${2:-8}" mode=mem group=1 key rows cols
  local hz; hz=$(getconf CLK_TCK 2>/dev/null || echo 100)
  local dir; dir=$(mktemp -d) || return
  : > "$dir/state"
  _syscheck_frame "$dir" 40 100 "$mode" "$group" "$interval" "$hz" "$nrows" >/dev/null
  tput smcup; tput civis; stty -echo 2>/dev/null
  trap 'tput cnorm; tput rmcup; stty echo 2>/dev/null; rm -rf "$dir"; trap - INT; return' INT
  sleep 0.4
  while true; do
    rows=$(tput lines); cols=$(tput cols)
    tput cup 0 0
    _syscheck_frame "$dir" "$rows" "$cols" "$mode" "$group" "$interval" "$hz" "$nrows"
    key=""
    if [[ -n $ZSH_VERSION ]]; then read -rs -k 1 -t "$interval" key 2>/dev/null
    else read -rsn1 -t "$interval" key; fi
    case $key in
      q|Q) break ;;
      g)   (( group = 1 - group )) ;;
      c)   [[ $mode == mem ]] && mode=cpu || mode=mem ;;
      +|=) (( nrows++ )) ;;
      -|_) (( nrows > 3 )) && (( nrows-- )) ;;
    esac
  done
  tput cnorm; tput rmcup; stty echo 2>/dev/null; rm -rf "$dir"; trap - INT
}


# ==============================================================================
# FORMAT
# ==============================================================================
# pretty: auto-detect and pretty-print whatever comes in on stdin.
# Usage:  ls -l | pretty     curl -s URL | pretty     pretty < file
# Handles: JSON / NDJSON, XML, HTML, CSV, TSV, YAML, and plain text.
# Optional helpers (used if installed): jq, xmllint, bat, python3.

pretty() {
  local tmp first
  tmp=$(mktemp) || return 1
  trap 'rm -f "$tmp"' RETURN
  cat > "$tmp"
  [ -s "$tmp" ] || return 0

  local color=""
  [ -t 1 ] && color=1
  have() { command -v "$1" >/dev/null 2>&1; }

  # First non-whitespace character
  first=$(tr -d ' \t\r\n' < "$tmp" | head -c1)

  # ---- JSON / NDJSON ----
  if [ "$first" = "{" ] || [ "$first" = "[" ]; then
    if have jq && jq -e . < "$tmp" >/dev/null 2>&1; then
      if [ -n "$color" ]; then jq -C . < "$tmp"; else jq . < "$tmp"; fi
      return
    elif have python3 && python3 -m json.tool < "$tmp" 2>/dev/null; then
      return
    fi
  fi

  # ---- HTML / XML ----
  if [ "$first" = "<" ]; then
    if grep -qiE '<!doctype html|<html' "$tmp"; then
      if have xmllint; then
        xmllint --html --format "$tmp" 2>/dev/null && return
      fi
    else
      if have xmllint; then
        xmllint --format "$tmp" 2>/dev/null && return
      fi
    fi
    if have python3; then
      python3 -c 'import sys,xml.dom.minidom as m;print(m.parseString(sys.stdin.read()).toprettyxml(indent="  "))' < "$tmp" 2>/dev/null && return
    fi
  fi

  # ---- CSV / TSV (consistent delimiter count across first lines) ----
  local delim
  for delim in $'\t' ',' '|' ';'; do
    if awk -v d="$delim" '
        NR<=5 { n=gsub(d,d); if (NR==1) c=n; else if (n!=c) bad=1 }
        END { exit !(c>0 && NR>=2 && !bad) }' "$tmp"; then
      if have column; then
        column -s "$delim" -t < "$tmp"
        return
      fi
    fi
  done

  # ---- YAML-ish (key: value lines) ----
  if grep -qE '^[[:space:]]*[A-Za-z_][A-Za-z0-9_.-]*:[[:space:]]' "$tmp" && have bat; then
    bat --plain --language yaml --color=always < "$tmp" 2>/dev/null && return
  fi

  # ---- Fallback: plain text ----
  if have bat && [ -n "$color" ]; then
    bat --plain --paging=never < "$tmp"
  else
    cat "$tmp"
  fi
}


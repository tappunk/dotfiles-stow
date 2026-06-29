typeset -U path fpath

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

_boot_once() {
    local boottime marker applied_key last_applied
    boottime="$(sysctl -n kern.boottime 2>/dev/null)" || return
    marker="$1"; shift
    applied_key="$1"; shift
    last_applied=""
    [[ -f "$marker" ]] && last_applied="$(<"$marker")"
    [[ "$last_applied" == "$applied_key" ]] && return
    if "$@" >/dev/null 2>&1; then
        print -r -- "$applied_key" >| "$marker"
        echo "[boot-init] $*"
    fi
}

boottime="$(sysctl -n kern.boottime 2>/dev/null)"

command -v container >/dev/null 2>&1 && _boot_once \
    /tmp/.container_system_start_boottime \
    "${boottime}:container" \
    container system start

mem_gb="$(( $(sysctl -n hw.memsize 2>/dev/null) >> 30 ))"
case "$mem_gb" in
    24) _boot_once /tmp/.iogpu_wired_limit_boottime "${boottime}:24:20889" \
           sudo /usr/sbin/sysctl -w "iogpu.wired_limit_mb=20889" ;;
    48) _boot_once /tmp/.iogpu_wired_limit_boottime "${boottime}:48:41779" \
           sudo /usr/sbin/sysctl -w "iogpu.wired_limit_mb=41779" ;;
esac

export PATH

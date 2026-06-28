typeset -U path fpath

if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

boottime="$(sysctl -n kern.boottime 2>/dev/null)"

container_marker="/tmp/.container_system_start_boottime"

if [[ -n "$boottime" ]] && command -v container >/dev/null 2>&1; then
    container_last_started=""
    [[ -f "$container_marker" ]] && container_last_started="$(<"$container_marker")"

    if [[ "$container_last_started" != "$boottime" ]]; then
        if container system start >/dev/null 2>&1; then
            print -r -- "$boottime" >| "$container_marker"
            echo "[boot-init] container system started"
        fi
    fi
fi

export PATH

marker="/tmp/.iogpu_wired_limit_boottime"
mem_gb="$(( $(sysctl -n hw.memsize 2>/dev/null) / 1024 / 1024 / 1024 ))"
wired_limit_mb=""

case "$mem_gb" in
    24) wired_limit_mb="20889" ;;
    48) wired_limit_mb="41779" ;;
esac

if [[ -n "$boottime" && -n "$wired_limit_mb" ]]; then
    applied_key="${boottime}:${wired_limit_mb}"
    last_applied=""
    [[ -f "$marker" ]] && last_applied="$(<"$marker")"

    if [[ "$last_applied" != "$applied_key" ]]; then
        if sudo /usr/sbin/sysctl -w "iogpu.wired_limit_mb=${wired_limit_mb}" >/dev/null; then
            print -r -- "$applied_key" >| "$marker"
            echo "[boot-init] iogpu.wired_limit_mb=${wired_limit_mb} applied"
        fi
    fi
fi

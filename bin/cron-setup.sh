#!/bin/bash

usage () {
    cat <<USAGE_END
$0 will add bash scripts to cron that'll monitor
    auditd logs that'll be read by dashboard web server.
Usage:
    $0 add 
    $0 list
    $0 remove
USAGE_END
}

APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/../"
SCRIPTS_DIR="${APP_DIR}bash-scripts/"
OUTPUT_DIR="${APP_DIR}log/"
ALL_SCRIPTS=(
  "login-success"
  "login-unsuccess"
  "priv-esc"
  "susp-activity"
  "user-mod"
)

if [ -z "$1" ]; then
    usage >&2
    exit 1
fi

if ! [ $(id -u) = 0 ]; then
   echo "$0 - Must be root. Scripts must be run from root user's crontab."
   exit 1
fi

case "$1" in
    add)
        tmpfile=$(mktemp)
        crontab -l >"$tmpfile"

        for t in ${ALL_SCRIPTS[@]}; do
          SCRIPT="${SCRIPTS_DIR}${t}.sh"
          OUTPUT="${OUTPUT_DIR}${t}.json"
          CRON_LINE="*/5 * * * * ${SCRIPT} > ${OUTPUT} 2>/dev/null"

          printf '%s\n' "$CRON_LINE" >>"$tmpfile"
        done

        crontab "$tmpfile" && rm -f "$tmpfile"
        ;;
    list)
        crontab -l | cat -n
        ;;
    remove)
        tmpfile=$(mktemp)
        sedMatch=""

        for t in ${ALL_SCRIPTS[@]}; do
          sedMatch+="${t}|"
        done

        sedMatch=${sedMatch:0:-1}
        crontab -l | sed -E -e "/${sedMatch}/d" >"$tmpfile"
        crontab "$tmpfile" && rm -f "$tmpfile"
        ;;
    *)
        usage >&2
        exit 1
esac

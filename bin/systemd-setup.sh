#!/bin/bash

usage () {
    cat <<USAGE_END
$0 will add express server to systemd
Usage:
    $0 add 
    $0 remove
USAGE_END
}

if [ -z "$1" ]; then
    usage >&2
    exit 1
fi

if ! [ $(id -u) = 0 ]; then
   echo "$0 - Must be root. Scripts must be run from root user's crontab."
   exit 1
fi


SVC_NAME="audit-log-dashboard.service"
SVC_FILE="/etc/systemd/system/$SVC_NAME"

case "$1" in
    add)
        touch $SVC_FILE
        chmod 644 $SVC_FILE

        APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. >/dev/null 2>&1 && pwd )"

        echo "
        [Unit]
        Description=Audit Log Dashboard

        [Service]
        WorkingDirectory=${APP_DIR}
        ExecStart=/usr/bin/npm run start --prefix ${APP_DIR}/
        Restart=always

        [Install]
        WantedBy=multi-user.target
        " > $SVC_FILE

        systemctl daemon-reload
        systemctl enable audit-log-dashboard.service
        systemctl start audit-log-dashboard.service
        ;;
    remove)
        systemctl stop $SVC_NAME
        systemctl disable $SVC_NAME
        rm /etc/systemd/system/$SVC_NAME
        systemctl daemon-reload
        systemctl reset-failed
        ;;
    *)
        usage >&2
        exit 1
esac

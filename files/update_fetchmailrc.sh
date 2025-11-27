#!/bin/sh
#
# update fetchmail config shell script
#
# exmaple config file:
# =======================
# poll imap.example.com
# proto IMAP
# user user@example.com
# password example
# ssl
# sslcertck
# sslcertfile /etc/ssl/certs/ca-certificates.crt
# keep
# # unit: byte, email size limitation
# # limit 100000
# mda /usr/bin/fetchmail_deliver.sh
# =======================
# 
#
# execute this script cmd:
#
# tmp=$(mktemp /tmp/fetchmailrc.conf.XXXXXX)
# chmod 600 "$tmp"
# echo -e "POLL=imap.example.com\nUSER=test@example.com\nPASSWORD=secret" > "$tmp"
# ./update_fetchmailrc.sh "$tmp"
# rm -f "$tmp"
#

CONFIG_FILE="$1"
FETCHMAILRC="/etc/config/fetchmailrc"

if [ ! -f "$CONFIG_FILE" ]; then
    exit 2
fi

# read config file, format: KEY=VALUE, each line
. "$CONFIG_FILE"

# validate required fields
for key in POLL USER PASSWORD; do
    if [ -z "$(eval echo \${${key}+x})" ]; then
        exit 1
    fi
done

TMPFILE="$(mktemp)" || {
    exit 2
}

sed -e "s/^poll .*/poll $POLL/" \
    -e "s/^user .*/user $USER/" \
    -e "s/^password .*/password $PASSWORD/" \
    "$FETCHMAILRC" > "$TMPFILE"

if [ $? -ne 0 ]; then
    rm -f "$TMPFILE"
    exit 2
fi

if mv "$TMPFILE" "$FETCHMAILRC" && chmod 600 "$FETCHMAILRC"; then
    rm -f "$CONFIG_FILE"
    exit 0
else
    rm -f "$TMPFILE"
    exit 2
fi
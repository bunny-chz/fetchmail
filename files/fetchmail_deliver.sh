#!/bin/sh
#
# maildir deliver shell script
# 负责将 fetchmail 收到的邮件单个 deliver 到 maildir 中
#

MAILDIR="/tmp/maildir"
if [ ! -d "$MAILDIR" ]; then
    mkdir -p "$MAILDIR/tmp"
    mkdir -p "$MAILDIR/new"
    mkdir -p "$MAILDIR/extract"
    chmod 700 "$MAILDIR"
    chmod 700 "$MAILDIR/new"
    chmod 700 "$MAILDIR/tmp"
    chmod 700 "$MAILDIR/extract"
else
    for dir in tmp new extract; do
        if [ ! -d "$MAILDIR/$dir" ]; then
            mkdir -p "$MAILDIR/$dir"
            chmod 700 "$MAILDIR/$dir"
        fi
    done
fi
fname="${MAILDIR}/tmp/email.$(date +%s).$$"
cat > "$fname"
mv "$fname" "${MAILDIR}/new/"

#!/bin/sh

set -eu

build_date="Unavailable"
apk_path="/srv/apk/app-debug.apk"

if [ -f "$apk_path" ]; then
    build_date=$(date -r "$apk_path" '+%Y-%m-%d %H:%M:%S %Z')
fi

sed "s|__BUILD_DATE__|$build_date|g" /opt/index.html \
    > /usr/share/nginx/html/index.html

exec /docker-entrypoint.sh nginx -g 'daemon off;'

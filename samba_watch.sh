#!/bin/bash
WATCH_DIR="/home/tyrus"
FLAG_SRC="/var/lib/samba-flags/bandera6.txt"
FLAG_DST="$WATCH_DIR/bandera6.txt"

inotifywait -m "$WATCH_DIR" -e create |
while read dir action file; do
    cp "$FLAG_SRC" "$FLAG_DST"
    chown tyrus:tyrus "$FLAG_DST"
    chmod 644 "$FLAG_DST"
    echo "[+] Bandera copiada tras detectar archivo: $file"
    break   # opcional, para que no se repita
done

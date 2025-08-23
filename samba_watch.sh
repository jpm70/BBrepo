#!/bin/bash
# Watcher simple para simular explotación Samba
# Compatible Ubuntu 14.04 (sin inotifywait)

WATCH_DIR="/home/tyrus"
FLAG_SRC="/var/lib/samba-flags/bandera6.txt"
FLAG_DST="$WATCH_DIR/bandera6.txt"

# Comprobación inicial
if [ ! -f "$FLAG_SRC" ]; then
    echo "Error: no se encuentra la bandera en $FLAG_SRC"
    exit 1
fi

echo "[+] Watcher iniciado: vigilando $WATCH_DIR ..."

while true; do
    for file in "$WATCH_DIR"/*; do
        # Si hay cualquier archivo y la bandera no existe, la copiamos
        if [ -f "$file" ] && [ ! -f "$FLAG_DST" ]; then
            cp "$FLAG_SRC" "$FLAG_DST"
            chown tyrus:tyrus "$FLAG_DST"
            chmod 644 "$FLAG_DST"
            echo "[+] Bandera copiada tras detectar archivo: $file"
        fi
    done
    sleep 2
done

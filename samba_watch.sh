#!/bin/bash
WATCH_DIR="/home/tyrus"
FLAG_SRC="/var/lib/samba-flags/bandera6.txt"
FLAG_DST="$WATCH_DIR/bandera6.txt"

if [ ! -f "$FLAG_SRC" ]; then
    echo "[ERROR] No se encuentra la bandera en $FLAG_SRC"
    exit 1
fi

echo "[+] Watcher iniciado: vigilando $WATCH_DIR ..."

while true; do
    for file in "$WATCH_DIR"/*; do
        if [ -f "$file" ]; then
            echo "[DEBUG] Detectado archivo: $file"

            if [ ! -f "$FLAG_DST" ]; then
                echo "[+] Copiando bandera..."
                cp "$FLAG_SRC" "$FLAG_DST"
                chown tyrus:tyrus "$FLAG_DST"
                chmod 644 "$FLAG_DST"
                echo "[+] Bandera copiada en $FLAG_DST"
            fi
        fi
    done
    sleep 2
done

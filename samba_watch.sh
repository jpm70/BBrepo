#!/bin/bash
# Watcher robusto para simular explotación Samba
# Compatible con Ubuntu 14.04 (sin inotifywait)

WATCH_DIR="/home/tyrus"
FLAG_SRC="/var/lib/samba-flags/bandera6.txt"
FLAG_DST="$WATCH_DIR/bandera6.txt"

# Comprobación inicial
if [ ! -f "$FLAG_SRC" ]; then
    echo "[ERROR] No se encuentra la bandera en $FLAG_SRC"
    exit 1
fi

echo "[+] Watcher iniciado: vigilando $WATCH_DIR ..."

while true; do
    # Verifica si hay contenido en el directorio
    if [ "$(ls -A "$WATCH_DIR")" ] && [ ! -f "$FLAG_DST" ]; then
        echo "[DEBUG] Se ha detectado contenido en $WATCH_DIR"

        # Copia la bandera
        cp "$FLAG_SRC" "$FLAG_DST"
        chown tyrus:tyrus "$FLAG_DST"
        chmod 644 "$FLAG_DST"
        echo "[+] Bandera copiada en $FLAG_DST"
    fi

    sleep 2
done

#!/bin/bash
set -euo pipefail

# ── Comprobación de root ────────────────────────────────────────────────────────
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "❌ Por favor, ejecuta como root (sudo)."
  exit 1
fi

USUARIO="lydia"
HOMEUSR="/home/$USUARIO"
CARPETA="$HOMEUSR/maquina_del_tiempo"
SCRIPT="$CARPETA/cambiar_bndr12.sh"

# Umbral en segundos (86400 = 1 día)
UMBRAL=86400

# ── Preparación ────────────────────────────────────────────────────────────────
rm -rf "$CARPETA"
mkdir -p "$CARPETA"
chown -R "$USUARIO:$USUARIO" "$CARPETA"

# Archivos base
sudo -u "$USUARIO" bash -lc "echo 'La bandera 12 no está aquí, aún no ha sido creada.' > '$CARPETA/bndr12.txt'"
sudo -u "$USUARIO" bash -lc "echo \"Bandera12: 'Soy_el_hombre_que_mató_a_Gus_Fring'\" > '$CARPETA/bandera12_real.txt'"

# Señuelo
sudo -u "$USUARIO" touch -t 203001010000 "$CARPETA/bndr12_futuro.txt"

# ── Script de lógica temporal ─────────────────────────────────────────────────
sudo -u "$USUARIO" tee "$SCRIPT" >/dev/null <<'SH'
#!/bin/bash
set -euo pipefail

FILE="$HOME/maquina_del_tiempo/bndr12.txt"
REAL="$HOME/maquina_del_tiempo/bandera12_real.txt"
FAKE="La bandera 12 no está aquí, aún no ha sido creada."

# Umbral (por defecto 86400 seg = 1 día)
UMBRAL="${UMBRAL:-86400}"

mtime=$(stat -c %Y "$FILE")
now=$(date +%s)

if [[ "$mtime" -lt $((now - UMBRAL)) ]]; then
  cp "$REAL" "$FILE"
else
  echo "$FAKE" > "$FILE"
fi
SH

chmod +x "$SCRIPT"
chown "$USUARIO:$USUARIO" "$SCRIPT"

# ── Alias de cat ───────────────────────────────────────────────────────────────
ALIASES="alias cat='bash \"$SCRIPT\" && /bin/cat'"
BASHRC="$HOMEUSR/.bashrc"

grep -Fq "$SCRIPT" "$BASHRC" 2>/dev/null || \
  sudo -u "$USUARIO" bash -lc "echo '$ALIASES' >> '$BASHRC'"

echo "✅ Reto 'Máquina del Tiempo' desplegado en $CARPETA"
echo "👉 Inicia sesión como $USUARIO, entra en $CARPETA y prueba 'cat bndr12.txt'"

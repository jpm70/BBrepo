#!/bin/bash
# Instalador reto CTF "Bandera12" - versión sin crear usuario

USER_HOME="/home/lydia"
CTF_FILE="bndr12.txt"
FLAG_FILE="bander12.txt"
SECRET_SCRIPT=".generar_bandera.sh"

# 1. Crear archivo de pista estilo mexicano / Breaking Bad
sudo mkdir -p "$USER_HOME"
sudo bash -c "cat > '$USER_HOME/$CTF_FILE' <<'EOF'
#!/bin/bash
bash \"\$(dirname \"\$0\")/$SECRET_SCRIPT\"
EOF"

# 2. Crear script oculto que genera la bandera
sudo bash -c "cat > '$USER_HOME/$SECRET_SCRIPT' <<'EOF'
#!/bin/bash
echo \"Bandera12: 'Soy_el_hombre_que_mató_a_Gus_Fring'\" > \"\$(dirname \"\$0\")/$FLAG_FILE\"
chmod 644 \"\$(dirname \"\$0\")/$FLAG_FILE\"
echo '¡Orale, compa! Aquí está la bandera... pero recuerda, en Albuquerque nada es gratis.'
EOF"

# 3. Permisos
sudo chmod 755 "$USER_HOME/$SECRET_SCRIPT"
sudo chmod +x "$USER_HOME/$CTF_FILE"
sudo chown lydia:lydia "$USER_HOME/$CTF_FILE" "$USER_HOME/$SECRET_SCRIPT"

# 4. Añadir pista al principio de bndr12.txt
sudo bash -c "echo \"// Eh, socio... dicen que si a este papelito le das poder de ejecución, va a cantar la verdad más rápido que Heisenberg cocinando azul.\" | cat - '$USER_HOME/$CTF_FILE' > '$USER_HOME/${CTF_FILE}.tmp' && mv '$USER_HOME/${CTF_FILE}.tmp' '$USER_HOME/$CTF_FILE'"

echo "Reto instalado correctamente en $USER_HOME"

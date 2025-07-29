#!/bin/bash

# Verificar permisos de superusuario
if [ "$EUID" -ne 0 ]; then
  echo "❌ Por favor, ejecuta como root (sudo)."
  exit 1
fi

# Variables
USUARIO="lydia"
CARPETA="/home/$USUARIO/maquina_del_tiempo"
SCRIPT="$CARPETA/cambiar_bndr12.sh"

# Crear carpeta y asignar permisos
mkdir -p "$CARPETA"
chown -R $USUARIO:$USUARIO "$CARPETA"

# Crear archivos base como el usuario lydia
sudo -u $USUARIO bash <<EOF
echo "La bandera 12 no está aquí, aún no ha sido creada." > "$CARPETA/bndr12.txt"
echo "Bandera12: ‘Soy_el_hombre_que_mató_a_Gus_Fring’" > "$CARPETA/bandera12_real.txt"
EOF

# Crear script de control temporal
sudo -u $USUARIO tee "$SCRIPT" > /dev/null <<'EOL'
#!/bin/bash

ctime=$(stat -c %Z ~/maquina_del_tiempo/bndr12.txt)
hora_actual=$(date +%s)

if [[ $ctime -le $hora_actual ]]; then
    cp ~/maquina_del_tiempo/bandera12_real.txt ~/maquina_del_tiempo/bndr12.txt
else
    echo "La bandera 12 no está aquí, aún no ha sido creada." > ~/maquina_del_tiempo/bndr12.txt
fi
EOL

chmod +x "$SCRIPT"

# Crear señuelo con fecha futura
sudo -u $USUARIO touch -t 203001010000 "$CARPETA/bndr12_futuro.txt"

# Configurar alias cat para que se autoejecute el script
ALIASES="alias cat='bash ~/maquina_del_tiempo/cambiar_bndr12.sh && /bin/cat'"
sudo -u $USUARIO bash -c "echo '$ALIASES' >> /home/$USUARIO/.bashrc"

echo "✅ Máquina del Tiempo instalada correctamente para el usuario '$USUARIO'."
echo "👉 Usa 'cat bndr12.txt' para activar el reto desde ~/maquina_del_tiempo"

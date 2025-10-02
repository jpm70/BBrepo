#!/bin/bash

# Este script instala Samba 4.3.8 (versión vulnerable) en Ubuntu 16.04.x y lo configura.
# ADVERTENCIA: Solo úsalo en un entorno de laboratorio o virtual para pruebas de seguridad.

# --- Variables ---
SAMBA_VERSION="2:4.3.8+dfsg-0ubuntu1"
SHARE_NAME="vulnerable_share"
SHARE_PATH="/samba/share"
SMB_CONFIG_FILE="/etc/samba/smb.conf"
USERNAME="user_samba"

# --- 1. Instalación de Samba 4.3.8 y dependencias ---
echo "Instalando la versión vulnerable de Samba ($SAMBA_VERSION)..."

# Actualizamos lista de paquetes y forzamos la instalación de la versión 4.3.8.
sudo apt-get update
sudo apt-get install -y --allow-downgrades \
    samba=${SAMBA_VERSION} \
    samba-common=${SAMBA_VERSION} \
    samba-common-bin=${SAMBA_VERSION} \
    libsmbclient=${SAMBA_VERSION} \
    libwbclient0=${SAMBA_VERSION} \
    samba-libs=${SAMBA_VERSION}

# --- 2. Verificación de la versión y bloqueo (Pinning) ---
echo "Version instalada:"
# CORRECCIÓN: Usamos la ruta completa /usr/sbin/smbd para asegurar que se encuentre el binario.
sudo /usr/sbin/smbd -V

echo "Bloqueando la versión de Samba para evitar actualizaciones..."
# Bloquear los paquetes principales para evitar que 'apt upgrade' los parchee.
sudo dpkg --set-selections <<< "samba hold"
sudo dpkg --set-selections <<< "samba-common hold"
sudo dpkg --set-selections <<< "samba-common-bin hold"
sudo dpkg --set-selections <<< "libsmbclient hold"
sudo dpkg --set-selections <<< "libwbclient0 hold"
sudo dpkg --set-selections <<< "samba-libs hold"

# --- 3. Configuración básica del recurso compartido ---
echo "Configurando el recurso compartido '$SHARE_NAME' en $SHARE_PATH..."

# Crear el directorio compartido
sudo mkdir -p "$SHARE_PATH"
# Establecer permisos (importante para el PoC)
sudo chmod 777 "$SHARE_PATH"

# --- 4. Crear el archivo smb.conf y configurar el recurso compartido ---
echo "Creando el archivo de configuracion ($SMB_CONFIG_FILE)..."

# Solo hacemos backup si el archivo original existe, para evitar el error 'stat'.
if [ -f "$SMB_CONFIG_FILE" ]; then
    sudo cp "$SMB_CONFIG_FILE" "${SMB_CONFIG_FILE}.bak"
fi

# Escribir una configuración básica y vulnerable
sudo bash -c "cat > $SMB_CONFIG_FILE" << EOF
[global]
    workgroup = WORKGROUP
    server string = Samba Server %v
    netbios name = UBUNTUSMB
    security = user
    map to guest = bad user
    dns proxy = no
    log file = /var/log/samba/log.%m
    max log size = 1000
    panic action = /usr/share/samba/panic-action %d
    idmap config * : backend = tdb

[$SHARE_NAME]
    comment = Ubuntu Vulnerable Share
    path = $SHARE_PATH
    browsable = yes
    writable = yes
    guest ok = no
    read only = no
    create mask = 0700
    directory mask = 0700
EOF

# --- 5. Creación de usuario y reinicio del servicio ---
echo "Creando usuario de Linux '$USERNAME' (si no existe)..."
# Crea el usuario de Linux sin pedir contraseña, si no existe.
sudo id -u "$USERNAME" &>/dev/null || sudo useradd -m -s /bin/bash "$USERNAME"

echo "Debes establecer la contraseña para el usuario de Samba '$USERNAME'."
# CORRECCIÓN: Usamos la ruta completa /usr/sbin/smbpasswd para evitar el error "orden no encontrada".
sudo /usr/sbin/smbpasswd -a "$USERNAME"
# Introduce la contraseña dos veces cuando se te solicite.

echo "Reiniciando el servicio Samba para aplicar la configuración..."
# CORRECCIÓN: Usamos el script de init.d más probable y genérico 'samba' para compatibilidad con 16.04.
if [ -f /etc/init.d/samba ]; then
    sudo /etc/init.d/samba restart
else
    echo "Advertencia: No se pudo encontrar el script /etc/init.d/samba. Intentando iniciar los demonios directamente..."
    # Intenta iniciar directamente por si el paquete no registra un script de init.d.
    sudo /usr/sbin/smbd -D
    sudo /usr/sbin/nmbd -D
fi


echo "Instalación completa! El servidor Samba vulnerable esta activo."
echo "Detalles:"
# CORRECCIÓN: Usamos la ruta completa /usr/sbin/smbd.
echo "- Version de Samba: $(sudo /usr/sbin/smbd -V)"
echo "- Recurso compartido: //$HOSTNAME/$SHARE_NAME (o //IP_DEL_HOST/$SHARE_NAME)"
echo "- Usuario Samba: $USERNAME"
echo "- Archivo de configuracion: $SMB_CONFIG_FILE"

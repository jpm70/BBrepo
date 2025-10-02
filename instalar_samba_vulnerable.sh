#!/bin/bash

# Este script instala Samba 4.3.8 (vulnerable al exploit CVE-2017-7494) 
# en Ubuntu 16.04.x mediante compilación desde el código fuente para asegurar la version.
# La instalacion se realiza en /usr/local/samba.
# ADVERTENCIA: Solo usar en un entorno de laboratorio aislado.

# --- Variables ---
SAMBA_VERSION="4.3.8"
SAMBA_FILE="samba-$SAMBA_VERSION.tar.gz"
SAMBA_URL="https://download.samba.org/pub/samba/$SAMBA_FILE"
SAMBA_INSTALL_DIR="/usr/local/samba"
SHARE_NAME="vulnerable_share"
SHARE_PATH="/samba/share"
SMB_CONFIG_FILE="$SAMBA_INSTALL_DIR/etc/smb.conf"
USERNAME="user_samba"

# --- 1. Limpieza de instalaciones previas de Samba (si existen) ---
echo "--- 1. Limpieza de paquetes y preparacion de sistema ---"

# Detenemos e inhabilitamos servicios si estuvieran activos
sudo /etc/init.d/samba stop 2>/dev/null
sudo apt-get remove --purge -y samba samba-common samba-common-bin 2>/dev/null

# Eliminamos el directorio de instalacion anterior si existe
sudo rm -rf "$SAMBA_INSTALL_DIR"

# --- 2. Instalación de dependencias para la compilación ---
echo "Instalando dependencias de compilacion..."

sudo apt-get update
sudo apt-get install -y wget build-essential libacl1-dev libattr1-dev libblkid-dev libgnutls28-dev \
libreadline-dev python-dev python-dnspython zlib1g-dev libpopt-dev libldap2-dev libpam0g-dev \
libcups2-dev libtevent-dev libbsd-dev

# --- 3. Descarga y extracción del código fuente ---
echo "Descargando Samba version $SAMBA_VERSION..."
mkdir -p /tmp/samba_build && cd /tmp/samba_build
wget "$SAMBA_URL"
tar -xzvf "$SAMBA_FILE"
cd "samba-$SAMBA_VERSION"

# --- 4. Compilación e Instalación ---
echo "Configurando y compilando Samba (esto puede tardar varios minutos)..."

# La instalacion se fuerza a la ruta especificada
./configure --prefix="$SAMBA_INSTALL_DIR" --enable-tcmalloc
make -j$(nproc)

echo "Instalando Samba en $SAMBA_INSTALL_DIR..."
sudo make install

# Limpieza de archivos de compilacion
cd /tmp
rm -rf /tmp/samba_build

# --- 5. Configuración básica del recurso compartido ---
echo "--- 5. Configurando el recurso compartido '$SHARE_NAME' en $SHARE_PATH ---"

# Crear el directorio compartido
sudo mkdir -p "$SHARE_PATH"
# Establecer permisos (importante para el PoC)
sudo chmod 777 "$SHARE_PATH"

# --- 6. Creación del archivo smb.conf ---
echo "Creando el archivo de configuracion ($SMB_CONFIG_FILE)..."

# Crear el directorio de configuracion si no existe
sudo mkdir -p "$SAMBA_INSTALL_DIR/etc"

# Escribir una configuración basica y vulnerable
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
    # Linea vulnerable al exploit:
    ntlm auth = yes

[$SHARE_NAME]
    comment = Ubuntu Vulnerable Share
    path = $SHARE_PATH
    browsable = yes
    writable = yes
    guest ok = no
    read only = no
    create mask = 0700
    directory mask = 0700
    # Configuracion tipica que habilita la vulnerabilidad en versiones antiguas:
    wide links = yes
    unix extensions = no
EOF

# --- 7. Creación de usuario y reinicio del servicio ---
echo "--- 7. Creacion de usuario y ejecucion de servicios ---"

echo "Creando usuario de Linux '$USERNAME' (si no existe)..."
# Crea el usuario de Linux sin pedir contraseña, si no existe.
sudo id -u "$USERNAME" &>/dev/null || sudo useradd -m -s /bin/bash "$USERNAME"

echo "Debes establecer la contrasena para el usuario de Samba '$USERNAME'."
# Usamos la ruta especifica de instalacion.
sudo "$SAMBA_INSTALL_DIR/bin/smbpasswd" -a "$USERNAME"
# Introduce la contraseña dos veces cuando se te solicite.

echo "Iniciando los demonios de Samba (smbd y nmbd) en segundo plano..."
# Iniciamos los demonios directamente desde su ruta de instalacion forzada.
sudo "$SAMBA_INSTALL_DIR/sbin/smbd" -D
sudo "$SAMBA_INSTALL_DIR/sbin/nmbd" -D

echo "Instalacion completa! El servidor Samba vulnerable esta activo."
echo "Detalles:"
echo "- Version de Samba: $($SAMBA_INSTALL_DIR/sbin/smbd -V | head -n 1)"
echo "- Ruta de instalacion: $SAMBA_INSTALL_DIR"
echo "- Recurso compartido: //$HOSTNAME/$SHARE_NAME (o //IP_DEL_HOST/$SHARE_NAME)"
echo "- Usuario Samba: $USERNAME"
echo "- Archivo de configuracion: $SMB_CONFIG_FILE"

# Opcional: Anadir la ruta de binarios al PATH para uso futuro (solo para el usuario actual)
echo "export PATH=\$PATH:$SAMBA_INSTALL_DIR/bin:$SAMBA_INSTALL_DIR/sbin" >> ~/.bashrc
source ~/.bashrc

#!/bin/bash

# Este script instala Samba 4.3.8 (vulnerable al exploit CVE-2017-7494) 
# en Ubuntu 16.04.x mediante compilacion desde el codigo fuente para asegurar la version.
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
BUILD_DIR="/tmp/samba_build"

# --- 1. Limpieza y preparacion de sistema ---
echo "--- 1. Limpieza de paquetes y preparacion de sistema ---"

# Detenemos e inhabilitamos servicios si estuvieran activos
sudo /etc/init.d/samba stop 2>/dev/null
sudo apt-get remove --purge -y samba samba-common samba-common-bin 2>/dev/null

# Eliminamos directorios de instalacion y compilacion (con sudo para asegurar)
sudo rm -rf "$SAMBA_INSTALL_DIR" "$BUILD_DIR"

# --- 2. Instalación de dependencias para la compilación ---
echo "Instalando dependencias de compilacion..."

# apt-get update es seguro y solo actualiza la lista de paquetes
sudo apt-get update
sudo apt-get install -y wget build-essential libacl1-dev libattr1-dev libblkid-dev libgnutls28-dev \
libreadline-dev python-dev python-dnspython zlib1g-dev libpopt-dev libldap2-dev libpam0g-dev \
libcups2-dev libtevent-dev libbsd-dev

# --- 3. Descarga y extracción del código fuente (SOLUCION FINAL) ---
echo "--- 3. Descarga y extraccion del codigo fuente ---"
echo "Creando directorio de compilacion en $BUILD_DIR..."

# Creamos el directorio sin sudo y trabajamos dentro como usuario normal
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Descargando Samba version $SAMBA_VERSION..."
# Descargamos el archivo como usuario normal
wget -q "$SAMBA_URL"

# Descomprimimos el archivo como usuario normal (donde no hay problemas de permiso)
echo "Descomprimiendo archivos..."
tar -xzvf "$SAMBA_FILE"

# Cambiamos al subdirectorio del codigo fuente
echo "Cambiando a directorio de codigo fuente..."
cd "samba-$SAMBA_VERSION" || { echo "Error: La carpeta de codigo fuente no se encontro. Abortando."; exit 1; }

# --- 4. Compilación e Instalación ---
echo "--- 4. Configuracion y Compilacion (puede tardar varios minutos) ---"

# Configuracion y Compilacion se ejecutan con sudo para escribir en rutas del sistema.
echo "Configurando la compilacion..."
sudo ./configure --prefix="$SAMBA_INSTALL_DIR" --enable-tcmalloc

echo "Compilando..."
sudo make -j$(nproc)

echo "Instalando Samba en $SAMBA_INSTALL_DIR..."
sudo make install

# Limpieza de archivos de compilacion (opcional)
cd /tmp
sudo rm -rf "$BUILD_DIR"

# --- 5. Configuración básica del recurso compartido ---
echo "--- 5. Configurando el recurso compartido '$SHARE_NAME' en $SHARE_PATH ---"

# Crear el directorio compartido y establecer permisos
sudo mkdir -p "$SHARE_PATH"
sudo chmod 777 "$SHARE_PATH"

# --- 6. Creación del archivo smb.conf ---
echo "--- 6. Creando el archivo de configuracion ($SMB_CONFIG_FILE) ---"

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

# --- 7. Creación de usuario y ejecución de servicios ---
echo "--- 7. Creacion de usuario y ejecucion de servicios ---"

echo "Creando usuario de Linux '$USERNAME' (si no existe)..."
# Crea el usuario de Linux sin pedir contraseña, si no existe.
sudo id -u "$USERNAME" &>/dev/null || sudo useradd -m -s /bin/bash "$USERNAME"

echo "Debes establecer la contrasena para el usuario de Samba '$USERNAME'."
# Usamos la ruta especifica de instalacion para smbpasswd.
sudo "$SAMBA_INSTALL_DIR/bin/smbpasswd" -a "$USERNAME"
# Introduce la contraseña dos veces cuando se te solicite.

echo "Iniciando los demonios de Samba (smbd y nmbd) en segundo plano..."
# Iniciamos los demonios directamente desde su ruta de instalacion forzada.
sudo "$SAMBA_INSTALL_DIR/sbin/smbd" -D
sudo "$SAMBA_INSTALL_DIR/sbin/nmbd" -D

echo "--- ¡FINALIZADO! ---"
echo "Instalacion completa! El servidor Samba vulnerable esta activo."
echo "Detalles:"
echo "- Version de Samba: $("$SAMBA_INSTALL_DIR/sbin/smbd" -V | head -n 1)"
echo "- Ruta de instalacion: $SAMBA_INSTALL_DIR"
echo "- Recurso compartido: //$HOSTNAME/$SHARE_NAME (o //IP_DEL_HOST/$SHARE_NAME)"
echo "- Usuario Samba: $USERNAME"
echo "- Archivo de configuracion: $SMB_CONFIG_FILE"

# Opcional: Anadir la ruta de binarios al PATH para uso futuro (solo para el usuario actual)
echo "export PATH=\$PATH:$SAMBA_INSTALL_DIR/bin:$SAMBA_INSTALL_DIR/sbin" >> ~/.bashrc
source ~/.bashrc

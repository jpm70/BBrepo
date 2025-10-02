#!/bin/bash

# Este script instala Samba 4.3.13 (vulnerable al exploit CVE-2017-7494) 
# mediante compilacion desde el codigo fuente. La instalacion se realiza en /usr/local/samba.
# ADVERTENCIA: Solo usar en un entorno de laboratorio aislado.

# --- VARIABLES CRUCIALES ---
SAMBA_VERSION="4.3.13" # Versión disponible más cercana a 4.3.8 que es vulnerable.
SAMBA_FILE="samba-$SAMBA_VERSION.tar.gz"
SAMBA_INSTALL_DIR="/usr/local/samba"
SHARE_NAME="vulnerable_share"
SHARE_PATH="/samba/share"
SMB_CONFIG_FILE="$SAMBA_INSTALL_DIR/etc/smb.conf"
USERNAME="user_samba"
BUILD_DIR="/tmp/samba_build"

# --- 1. Verificacion, Limpieza y preparacion de sistema ---
echo "--- 1. Verificacion, Limpieza y preparacion de sistema ---"

# Verificacion del archivo local
if [ ! -f "$SAMBA_FILE" ]; then
    echo "ERROR: Archivo '$SAMBA_FILE' no encontrado en el directorio actual."
    echo "Por favor, asegurate de que el archivo $SAMBA_FILE este en el mismo directorio que este script."
    exit 1
fi

# Limpieza de instalaciones previas
sudo /etc/init.d/samba stop 2>/dev/null
sudo apt-get remove --purge -y samba samba-common samba-common-bin 2>/dev/null
sudo rm -rf "$SAMBA_INSTALL_DIR" "$BUILD_DIR"

# --- 2. Instalación de dependencias para la compilación (CORREGIDA) ---
echo "--- 2. Instalando dependencias de compilacion ---"

# apt-get update es seguro y solo actualiza la lista de paquetes
sudo apt-get update
# Añadimos libpython-dev, crucial para la configuracion de Waf en sistemas antiguos
sudo apt-get install -y build-essential libacl1-dev libattr1-dev libblkid-dev libgnutls28-dev \
libreadline-dev python-dev libpython-dev python-dnspython zlib1g-dev libpopt-dev libldap2-dev libpam0g-dev \
libcups2-dev libtevent-dev libbsd-dev wget

# --- 3. Extracción del código fuente (Local) ---
echo "--- 3. Extraccion del codigo fuente local ---"
echo "Creando directorio de compilacion en $BUILD_DIR..."

# Movemos el archivo a la carpeta de compilacion para trabajar
mkdir -p "$BUILD_DIR"
cp "$SAMBA_FILE" "$BUILD_DIR/"
cd "$BUILD_DIR"

# Descomprimimos el archivo como usuario normal
echo "Descomprimiendo archivos..."
tar -xzvf "$SAMBA_FILE"

# Cambiamos al subdirectorio del codigo fuente
echo "Cambiando a directorio de codigo fuente..."
cd "samba-$SAMBA_VERSION" || { echo "Error: La carpeta de codigo fuente no se pudo encontrar despues de descomprimir. Abortando."; exit 1; }

# --- 4. Compilación e Instalación ---
echo "--- 4. Configuracion y Compilacion (puede tardar varios minutos) ---"

echo "Inicializando la configuracion con Waf..."
# Usamos ./configure, que deberia funcionar correctamente ahora con libpython-dev instalado.
sudo ./configure --prefix="$SAMBA_INSTALL_DIR" --enable-tcmalloc --enable-debug || { 
    echo "ERROR: Fallo al ejecutar ./configure. Revisa si faltan dependencias."
    exit 1
}

echo "Compilando..."
# make (Waf) ahora debería reconocer el proyecto configurado.
sudo make -j$(nproc) || {
    echo "ERROR: Fallo al compilar. Revisa si hay errores en el log."
    exit 1
}

echo "Instalando Samba en $SAMBA_INSTALL_DIR..."
sudo make install

# Limpieza de archivos de compilacion (opcional)
cd /tmp
sudo rm -rf "$BUILD_DIR"

# --- 5. Configuracion del recurso compartido y smb.conf ---
echo "--- 5. Configurando el recurso compartido '$SHARE_NAME' en $SHARE_PATH ---"

sudo mkdir -p "$SHARE_PATH"
sudo chmod 777 "$SHARE_PATH"

echo "--- 6. Creando el archivo de configuracion ($SMB_CONFIG_FILE) ---"

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
    wide links = yes
    unix extensions = no
EOF

# --- 7. Creación de usuario y ejecución de servicios ---
echo "--- 7. Creacion de usuario y ejecucion de servicios ---"

echo "Creando usuario de Linux '$USERNAME' (si no existe)..."
sudo id -u "$USERNAME" &>/dev/null || sudo useradd -m -s /bin/bash "$USERNAME"

echo "Debes establecer la contrasena para el usuario de Samba '$USERNAME'."
# Usamos la ruta especifica de instalacion para smbpasswd.
sudo "$SAMBA_INSTALL_DIR/bin/smbpasswd" -a "$USERNAME"

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

echo "export PATH=\$PATH:$SAMBA_INSTALL_DIR/bin:$SAMBA_INSTALL_DIR/sbin" >> ~/.bashrc
source ~/.bashrc

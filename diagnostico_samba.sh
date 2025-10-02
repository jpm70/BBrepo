#!/bin/bash

# --- VARIABLES CRUCIALES ---
SAMBA_VERSION="4.3.13"
SAMBA_FILE="samba-$SAMBA_VERSION.tar.gz"
BUILD_DIR="/tmp/samba_build"

echo "--- 1. Preparacion del entorno ---"

# Limpieza y preparación (asumiendo que el archivo .tar.gz ya está en el directorio)
sudo rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp "$SAMBA_FILE" "$BUILD_DIR/"
cd "$BUILD_DIR"

echo "Descomprimiendo archivos..."
tar -xzvf "$SAMBA_FILE"

echo "Cambiando a directorio de codigo fuente..."
cd "samba-$SAMBA_VERSION" || { echo "Error: La carpeta de codigo fuente no se pudo encontrar. Abortando."; exit 1; }

# --- 2. Fase de Diagnóstico ---

echo "Iniciando la configuracion. Buscando dependencias faltantes..."

# Este es el comando critico. Quitamos el 'sudo' y la redireccion para ver el error
# directamente en la consola.
./configure --prefix="/usr/local/samba" --enable-tcmalloc --enable-debug

echo "--- FIN DEL DIAGNOSTICO ---"

# La ejecución se detendrá aquí para que podamos ver el error detallado de ./configure.
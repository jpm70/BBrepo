
#!/bin/bash

# Ruta de despliegue
RUTA_RETO="/opt/retos/bof15"
ARCHIVO_C="bof_flag15.c"
BINARIO="bof_flag15"

echo "[*] Instalando dependencias necesarias (gcc, multilib)..."
apt-get update
apt-get install -y gcc gcc-multilib

echo "[*] Creando directorio del reto: $RUTA_RETO"
mkdir -p "$RUTA_RETO"
cd "$RUTA_RETO"

echo "[*] Escribiendo código fuente vulnerable..."
cat > "$ARCHIVO_C" << 'EOF'
#include <stdio.h>
#include <string.h>

void bandera() {
    printf("Bandera 15: 'Yo_soy_el_que_llama'\n");
}

void vulnerable() {
    char buffer[64];
    printf("Introduce tu nombre: ");
    gets(buffer);  // buffer overflow
    printf("Hola, %s\n", buffer);
}

int main() {
    vulnerable();
    return 0;
}
EOF

echo "[*] Compilando binario vulnerable..."
gcc -m32 -fno-stack-protector -z execstack -no-pie -o "$BINARIO" "$ARCHIVO_C"

# (Opcional) Quitar permisos de escritura y dejar solo ejecución
chmod 755 "$BINARIO"
chown root:root "$BINARIO"

echo "[+] Binario compilado en $RUTA_RETO/$BINARIO"
echo "[+] Reto Buffer Overflow desplegado con éxito"

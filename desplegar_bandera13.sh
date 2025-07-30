#!/bin/bash

echo "🚀 Iniciando despliegue de Bandera 13..."

# 🧱 Comprobar e instalar Flask si no está presente
echo "🔍 Verificando Flask..."
if ! python3 -c "import flask" &>/dev/null; then
    echo "⚙️ Instalando Flask con pip3..."
    if ! command -v pip3 &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y python3-pip
    fi
    pip3 install flask
fi

# 📂 Crear servidor Flask en /opt
echo "📦 Generando /opt/canary_server.py..."
sudo tee /opt/canary_server.py > /dev/null << 'EOF'
from flask import Flask, request
from datetime import datetime

app = Flask(__name__)

@app.route('/trigger', methods=['GET', 'POST'])
def trigger():
    ip_origen = request.remote_addr
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    mensaje = f"[{timestamp}] Token activado desde {ip_origen} - Bandera 13: 'Yo_soy_el_que_llama'\n"

    with open('/var/log/bandera13.log', 'a') as log_file:
        log_file.write(mensaje)

    print("🔔 ¡Alerta activada!")
    return 'Token recibido', 200

app.run(host='0.0.0.0', port=8000)
EOF

chmod +x /opt/canary_server.py

# 📄 Generar archivo trampa bandera13.html para mike
echo "📄 Creando /home/mike/bandera13.html..."
sudo tee /home/mike/bandera13.html > /dev/null << 'EOW'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Bandera de seguridad</title>
</head>
<body>
  <h1>Informe de Diagnóstico</h1>
  <p>Este archivo contiene detalles técnicos sobre el análisis de seguridad en el sistema de Mike.</p>
  <img src="http://localhost:8000/trigger" style="display:none" alt=""/>
  <p>Fecha de generación: 2025-07-30<br>
     Usuario responsable: mike<br>
     Estado: Pendiente de revisión por el equipo de auditoría.</p>
</body>
</html>
EOW

# 🔐 Ajustar permisos
echo "🔐 Configurando permisos..."
sudo chown mike:mike /home/mike/bandera13.html
sudo chmod 644 /home/mike/bandera13.html

# 📁 Crear log vacío si no existe
echo "🗂️ Preparando /var/log/bandera13.log..."
sudo touch /var/log/bandera13.log
sudo chmod 644 /var/log/bandera13.log

echo "✅ ¡Despliegue completado!"

echo -e "\n🧠 Recuerda añadir esto en /etc/rc.local antes del 'exit 0' para activarlo al arranque:\n"
echo "    python3 /opt/canary_server.py &"
echo -e "\n💣 Una vez que el servidor está corriendo, al abrir /home/mike/bandera13.html en el navegador, se registrará la bandera en el log."

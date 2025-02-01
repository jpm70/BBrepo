# Crear la carpeta si no existe
if (!(Test-Path -Path 'C:\Temp')) {
    New-Item -ItemType Directory -Path 'C:\Temp'
}

# URLs de los archivos .bat
$wifiBatUrl = 'https://raw.githubusercontent.com/jpm70/BBrepo/main/wifi.bat'
$copyBatUrl = 'https://raw.githubusercontent.com/jpm70/BBrepo/main/copy.bat'

# Rutas locales de destino
$wifiBatPath = 'C:\Temp\wifi.bat'
$copyBatPath = 'C:\Temp\copy.bat'

# Descargar ambos archivos desde GitHub
Invoke-WebRequest -Uri $wifiBatUrl -OutFile $wifiBatPath
Invoke-WebRequest -Uri $copyBatUrl -OutFile $copyBatPath

# Ejecutar wifi.bat si existe
if (Test-Path $wifiBatPath) {
    Start-Process $wifiBatPath -Wait
    Write-Host "wifi.bat ejecutado correctamente."
} else {
    Write-Host "El archivo wifi.bat no se descargó correctamente."
}

# Ejecutar copy.bat si existe
if (Test-Path $copyBatPath) {
    Start-Process $copyBatPath -Wait
    Write-Host "copy.bat ejecutado correctamente."
} else {
    Write-Host "El archivo copy.bat no se descargó correctamente."
}
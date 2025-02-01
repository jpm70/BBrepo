@echo off
:: Solicitar privilegios de administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Este script requiere privilegios de administrador.
    echo Intentando reiniciarlo como administrador...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Definir archivo de depuración
set "debug_output=%~dp0depuracion_netsh.txt"

:: Registrar salida de netsh
echo Generando salida de depuración en "%debug_output%"...
netsh wlan show profiles > "%debug_output%"
echo >> "%debug_output%"
for /f "tokens=2 delims=:" %%A in ('netsh wlan show profiles ^| findstr "Todos los perfiles"') do (
    set "wifi_name=%%A"
    setlocal enabledelayedexpansion
    set "wifi_name=!wifi_name:~1!"  :: Eliminar espacios iniciales

    :: Extraer detalles del perfil y registrar en el archivo
    echo === Perfil: !wifi_name! === >> "%debug_output%"
    netsh wlan show profile name="!wifi_name!" key=clear >> "%debug_output%"
    echo. >> "%debug_output%"
    endlocal
)

:: Confirmar finalización
echo Depuración completada. Consulta el archivo "%debug_output%".
pause

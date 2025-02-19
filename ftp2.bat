@echo off
setlocal enabledelayedexpansion

:: Configuración de credenciales y rutas
set "ftp_server=ftpupload.net"
set "ftp_user=ezyro_38327134"
set "ftp_password=9071140"
set "local_file=C:\Users\Jose\Desktop\prueba.docx"
set "remote_path=/htdocs/prueba.docx"
set "ftp_script=ftp_script.txt"
set "ftp_log=ftp_log.txt"

:: Verificar si el archivo local existe antes de continuar
if not exist "%local_file%" (
    echo ERROR: El archivo "%local_file%" no existe.
    pause
    exit /b
)

:: Crear archivo de comandos FTP
(
    echo open %ftp_server%
    echo user %ftp_user%
    echo %ftp_password%
    echo binary
    echo put "%local_file%" "%remote_path%"
    echo bye
) > "%ftp_script%"

:: Ejecutar el comando FTP y capturar la salida
ftp -v -n -s:"%ftp_script%" > "%ftp_log%" 2>&1

:: Revisar si la transferencia fue exitosa
findstr /C:"226 Transfer complete" "%ftp_log%" >nul
if %errorlevel% equ 0 (
    echo Transferencia completada con éxito.
) else (
    echo ERROR: La transferencia no se realizó correctamente.
    type "%ftp_log%"
    pause
)

:: Limpiar archivos temporales
del "%ftp_script%"
del "%ftp_log%"

pause
exit

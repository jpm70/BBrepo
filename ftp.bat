@echo off
setlocal

:: Configuración de credenciales y ruta de archivo
set "ftp_server=ftpupload.net"
set "ftp_user=ezyro_38327134"
set "ftp_password=9071140"
set "local_file=C:\Users\Jose\Desktop\prueba.docx"
set "remote_path=/htdocs/prueba.docx"

:: Crear archivo de comandos FTP
(
    echo open %ftp_server%
    timeout /t 2 >nul
    echo user %ftp_user%
    echo %ftp_password%
    echo binary
    echo put "%local_file%" "%remote_path%"
    echo bye
) > ftp_script.txt

:: Ejecutar el comando FTP
ftp -n -s:ftp_script.txt

:: Eliminar archivo temporal de script FTP
del ftp_script.txt
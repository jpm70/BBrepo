@echo off
set usb_drive=
for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
  vol %%i: 2>nul | find "PATITO" >nul && set usb_drive=%%i:
)
if defined usb_drive (
  move "C:\Temp\depuracion_netsh.txt" %usb_drive%
  move "C:\Temp\wifi.bat" %usb_drive%
) else (
  echo Unidad USB con etiqueta PATITO no encontrada.
)
pause

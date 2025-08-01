<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$usuario = $_POST['usuario'];
$clave = $_POST['clave'];

// Lista de patrones que simulan inyecciones comunes
$patrones_inyeccion = [
    "' OR '1'='1",
    "' or '1'='1",
    "' OR 1=1 --",
    "' or 1=1 --",
    "' OR 1=1 #",
    "' OR TRUE --",
    "'='",
    "' OR 'a'='a",
    "' or ''='",
    "' OR ''='"
];

// Recorremos los patrones buscando coincidencias
foreach ($patrones_inyeccion as $patron) {
    if (stripos($clave, $patron) !== false) {
        echo "
        <!DOCTYPE html>
        <html lang='es'>
        <head>
          <meta charset='UTF-8'>
          <title>Acceso concedido</title>
          <style>
            body {
              background-color: #fef8e7;
              font-family: 'Arial Black', Impact, sans-serif;
              display: flex;
              align-items: center;
              justify-content: center;
              height: 100vh;
            }
            .mensaje {
              background-color: #d4edda;
              border: 2px solid #155724;
              padding: 40px;
              border-radius: 15px;
              text-align: center;
              color: #155724;
              font-size: 24px;
              box-shadow: 0 0 10px rgba(0,0,0,0.2);
            }
          </style>
        </head>
        <body>
          <div class='mensaje'>
            ✅ Acceso concedido<br><br>
            <strong>¡Bienvenido, Mike_Ehrmantraut!</strong><br>
            <strong>Flag:</strong> Mike_Ehrmantraut
          </div>
        </body>
        </html>
        ";
        exit;
    }
}

// Si no se detectó ningún patrón
echo "<script>alert('Acceso denegado.'); window.history.back();</script>";
?>


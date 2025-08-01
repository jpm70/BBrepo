<?php
$soluciones = array(
  "1" => "'d41d8cd98f00b204e9800998ecf8427e'",
  "2" => "'pizza_en_el_tejado'",
  "3" => "'I_am_the_one_who_knocks'",
  "4" => "'e4d909c290d0fb1ca068ffaddf22cbd0'",
  "5" => "'Yo_soy_el_peligro'",
  "6" => "'Usted_es_un_maldito_artista'",
  "7" => "'Mejor_llama_a_Saul'",
  "8" => "'El_miedo_es_el_verdadero_enemigo'",
  "9" => "'Estoy_en_el_negocio_del_imperio'",
  "10" => "'Usted_no_es_una_persona_discreta'",
  "11" => "'blue_sky_save_family'",
  "12" => "'Soy_el_hombre_que_mató_a_Gus_Fring'",
  "13" => "'Un_hombre_debe_tener_limites'",
  "14" => "'Alejate_de_mi_territorio'",
  "15" => "'Yo_soy_el_que_llama'"
);

$numero = $_POST['numero'];
$respuesta = trim($_POST['respuesta']);

if (array_key_exists($numero, $soluciones)) {
    if ($respuesta === $soluciones[$numero]) {
        $banderas = [];
        if (isset($_COOKIE['banderas'])) {
            $banderas = explode(',', $_COOKIE['banderas']);
        }

        if (!in_array($numero, $banderas)) {
            $banderas[] = $numero;
            setcookie('banderas', implode(',', $banderas), time() + 3600 * 24 * 30);
        }

        $total = count($banderas);

        echo "
        <!DOCTYPE html>
        <html lang='es'>
        <head>
          <meta charset='UTF-8'>
          <title>¡Bandera capturada!</title>
          <style>
            body {
              background-color: #fef8e7;
              font-family: Arial, sans-serif;
              display: flex;
              align-items: center;
              justify-content: center;
              height: 100vh;
            }
            .mensaje {
              background-color: #cce5ff;
              border: 2px solid #004085;
              padding: 40px;
              border-radius: 15px;
              text-align: center;
              color: #004085;
              font-size: 24px;
              box-shadow: 0 0 10px rgba(0,0,0,0.2);
            }
          </style>
        </head>
        <body>
          <div class='mensaje'>
            🚩 ¡Correcto! Has capturado la Bandera $numero<br><br>
            <strong>Flag aceptado:</strong> $respuesta<br>
            <strong>Total de banderas capturadas:</strong> $total / 15
          </div>
        </body>
        </html>
        ";
    } else {
        echo "<script>alert('❌ Valor incorrecto para la Bandera $numero'); window.history.back();</script>";
    }
} else {
    echo "<script>alert('⚠️ Número de bandera no válido'); window.history.back();</script>";
}
?>

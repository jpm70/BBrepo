<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Verificación de Banderas - Los Pollos Hermanos</title>
  <style>
    body {
      background-color: #fef8e7;
      font-family: 'Arial Black', Impact, sans-serif;
      padding: 50px;
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    h1 {
      font-size: 60px;
      color: #e30613;
      background-color: #fdd835;
      padding: 15px 30px;
      border-radius: 15px;
      text-shadow: 2px 2px #0056a4;
      margin-bottom: 10px;
    }
    .contador {
      font-size: 22px;
      color: #0056a4;
      background-color: #fff3cd;
      padding: 15px 25px;
      border-radius: 10px;
      margin-top: 10px;
      font-weight: bold;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
    }
    .formulario {
      background-color: #fff;
      padding: 30px;
      border-radius: 15px;
      box-shadow: 0 0 15px rgba(0,0,0,0.2);
      max-width: 500px;
      width: 100%;
      margin-top: 40px;
    }
    label {
      display: block;
      font-weight: bold;
      margin-top: 20px;
    }
    select,
    input[type="text"],
    input[type="submit"] {
      width: 100%;
      padding: 10px;
      margin-top: 10px;
      border-radius: 5px;
      border: 1px solid #ccc;
      font-size: 18px;
    }
    input[type="submit"] {
      background-color: #fdd835;
      color: #e30613;
      font-weight: bold;
      cursor: pointer;
      border: none;
    }
  </style>
</head>
<body>

  <h1>Verificación de Banderas</h1>

  <div class="contador">
    <?php
    if (isset($_COOKIE['banderas'])) {
      $banderasArray = explode(',', $_COOKIE['banderas']);
      $cantidad = count($banderasArray);
      echo "🚩 Has capturado $cantidad de 15 banderas: <br>" . implode(', ', $banderasArray);
    } else {
      echo "🚩 No has capturado ninguna bandera aún. ¡Sigue intentándolo!";
    }
    ?>
  </div>

  <div class="formulario">
    <form action="verificarbandera.php" method="POST">
      <label for="numero">Número de Bandera</label>
      <select id="numero" name="numero" required>
        <option value="">Selecciona una bandera</option>
        <?php
        for ($i = 1; $i <= 15; $i++) {
          echo "<option value='$i'>Bandera $i</option>";
        }
        ?>
      </select>

      <label for="respuesta">Valor de la bandera (entre ' y ')</label>
      <input type="text" id="respuesta" name="respuesta" placeholder="Ejemplo: 'I_am_the_one_who_knocks'" required>

      <input type="submit" value="Comprobar">
    </form>
  </div>

</body>
</html>

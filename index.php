<?php
    require 'db_connection.php';
    global $pdo;
?>

<!DOCTYPE html>
<html lang="" xmlns="http://www.w3.org/1999/html">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" type="text/css" href="styles.css">
    <title>a21liltr</title>
</head>
<body>
<h1>WELCOME ALL ALIENS!</h1>
<h3>MAKE A REGISTRATION NOW!</h3>

<div class="register_and_list">
    <div class="registration">
        <form id="register_form" method="post" onsubmit="">
            <label>Name: </label><br>
            <input type="text" name="alien_namn"><br><br>

            <label>Hemplanet: </label><br>
            <input type="text" name="hemplanet"><br><br>
            <input type="submit" value="SUBMIT">
        </form>
    </div>

    <div>
        <h3>HERE IS A LIST OF SOME THAT HAVE ALREADY REGISTERED!</h3>
    </div>
    <table class="alien_list" cellpadding="4px;">
    <?php
    echo "<pre>";
    foreach ($pdo->query('SELECT namn, hemplanet FROM Registrerad_Alien;') AS $row) {
        echo "<tr>";
        foreach ($row AS $col=>$val) {
            $title = strtoupper($col);
            echo "<td>";
            echo $title. "<br>" .$val. "<br>";
            echo "</td>";
        }
        echo "</tr>";
    }
    echo "</pre>";

    // method for generating a string of 25 characters.
    function generateRandomString() {
        $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789';
        $charactersLength = strlen($characters);
        $randomString = '';
        for ($i = 0; $i < 25; $i++) {
            $randomString .= $characters[mt_rand(0, $charactersLength - 1)];
        }
        return $randomString;
    }

    function checkSubmitOk() {
        $alien_id = generateRandomString();
        $alien_namn = $_POST['alien_namn'];
        $hemplanet = $_POST['hemplanet'];

        if(isset($alien_name)) {
            if(isset($hemplanet)) {
                $registerstring = 'INSERT INTO Registrerad_Alien (alien_id, namn, hemplanet) VALUES (:ALIENID, :ALIENNAMN, :HEMPLANET)';
                $stmt = $pdo->prepare($registerstring);
                $stmt->bindParam(':ALIENID', $alien_id);
                $stmt->bindParam(':ALIENNAMN', $alien_namn);
                $stmt->bindParam(':HEMPLANET', $hemplanet);
                $stmt->execute();
            }
            $registerstring = 'INSERT INTO Oregistrerad_Alien (alien_id, namn) VALUES (:ALIENID, :ALIENNAMN, :HEMPLANET)';
            $stmt = $pdo->prepare($registerstring);
            $stmt->bindParam(':ALIENID', $alien_id);
            $stmt->bindParam(':ALIENNAMN', $alien_namn);
            $stmt->execute();
        }
        else {
            echo "Please enter your NAME!";
        }
    }

    ?>
    </table>
</div>
</body>
</html>

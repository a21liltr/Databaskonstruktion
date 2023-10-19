<?php require_once "db_connection.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $alien_id = generateRandomString(25);
    $namn = $_POST['namn'];
    $hemplanet = $_POST['hemplanet'];
    $query = "";

    if(!empty($_POST['hemplanet'])) {
        $query = "INSERT INTO Registrerad_Alien (alien_id, namn, hemplanet) VALUES ('$alien_id', '$namn', '$hemplanet')";
    }
    else {
        $query = "INSERT INTO Oregistrerad_Alien (alien_id, namn) VALUES ('$alien_id', '$namn')";
    }

    $stmt = $pdo->prepare($query);
    $stmt->execute();

    echo "Alien added successfully!";
}

    function generateRandomString($length) {
        $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $string = '';
        for ($i = 0; $i < $length; $i++) {
            $string .= $characters[rand(0, strlen($characters) - 1)];
        }
        return $string;
    }

?>
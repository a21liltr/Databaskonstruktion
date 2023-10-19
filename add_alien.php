<?php require_once "db_connection.php";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $alien_id = $_POST['alien_id'];
    $namn = $_POST['namn'];
    $hemplanet = $_POST['hemplanet'];

    $query = "INSERT INTO Registrerad_Alien (alien_id, namn, hemplanet) VALUES ('$alien_id', '$namn', '$hemplanet')";

    $stmt = $pdo->prepare($query);
    $stmt->execute();

    echo "Alien added successfully!";
}
?>
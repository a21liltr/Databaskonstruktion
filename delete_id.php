<?php require "db_connection.php";

    $alien_id = $_POST['alien_id'];
    $stmt = $pdo->prepare('CALL radera_alien(:alien_id)');
    $stmt->execute([':alien_id' => $alien_id]);

    echo "Alien with ID: " . $alien_id . " has been deleted";
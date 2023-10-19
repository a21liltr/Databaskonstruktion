<?php require "db_connection.php";

$id = $_GET['id'] ?? null;

if ($id) {
    try {
        $query = $pdo->prepare('DELETE FROM Registrerad_Alien WHERE alien_id = :id');
        $query->execute([':id' => $id]);

        echo "Alien with ID: " . $id . " has been deleted";
    } catch (PDOException $e) {
        echo "Error: " . $e->getMessage();
    }
}


?>
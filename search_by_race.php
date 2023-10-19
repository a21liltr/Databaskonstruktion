<?php require_once "db_connection.php";

$selectedOption = intval($_POST["farlighet"]); // Convert the value to integer, to ensure it's an integer.

$query = "SELECT * FROM Alien WHERE farlighet = :farlighet";

$stmt = $pdo->prepare($query);
$stmt->execute([
    ':farlighet' => $selectedOption
]);

if ($stmt->rowCount() > 0) {
    echo "<table>";
    echo "ALIEN ID : DANGER LEVEL : RACE <br><br>";

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "<tr>";
        echo "<td>" . $row['alien_id'] . "</td>";
        echo "<td>" . $row['farlighet'] . "</td>";
        echo "<td>" . $row['ras_namn'] . "</td>";
        echo "</tr>";
    }

    echo "</table>";
}
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

<!-- Hantera länkar -->
<a href="page.php?param1=value1&param2=value2">Länk</a>

<?php
// Hantera GET-förfrågan från länken
$param1 = $_GET['param1'];
$param2 = $_GET['param2'];
echo "Param1: $param1, Param2: $param2";

// Hantera formulär
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Hantera POST-förfrågan från formuläret
    $input1 = $_POST['input1'];
    $input2 = $_POST['input2'];
    echo "Input1: $input1, Input2: $input2";
}
?>

<!-- Formulär i HTML -->
<form action="page.php" method="post">
    <input type="text" name="input1">
    <input type="text" name="input2">
    <input type="submit" value="Submit">
</form>
I detta exempel visar länken hur parametrar skickas via URL:en, medan formuläret visar hur data skickas via en POST-förfrågan. Det är viktigt att notera skillnaderna i dataöverföringen och hanteringen av indata mellan länkar och formulär i en PHP-applikation.





<?php
// Anslut till databasen med PDO
$dsn = 'mysql:host=localhost;dbname=your_database';
$username = 'your_username';
$password = 'your_password';

try {
    $dbh = new PDO($dsn, $username, $password);
    $dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Förbered och exekvera en SQL-fråga med bindning av variabler
    $stmt = $dbh->prepare("INSERT INTO hus (adress, plats, kategori) VALUES (:adress, :plats, :kategori)");
    $stmt->bindParam(':adress', $adress);
    $stmt->bindParam(':plats', $plats);
    $stmt->bindParam(':kategori', $kategori);

    // Värden från webbsidan
    $adress = $_POST['adress'];
    $plats = $_POST['plats'];
    $kategori = $_POST['kategori'];

    // Exekvera frågan
    $stmt->execute();
    echo "Hus lagrat i databasen.";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
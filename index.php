<?php
    require 'db_connection.php';
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>a21liltr</title>
</head>
<body>
<h1>Välkommen till en PHP sida</h1>
<?php
$query = "SELECT * FROM Farlighet";
foreach ($pdo->query($query) as $row) {
    echo "<pre>";
    print_r($row);
    echo "<pre>";
}
?>
</body>
</html>

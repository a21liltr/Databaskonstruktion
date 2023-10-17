<?php
require 'db_connection.php';
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" type="text/css" href="styles.css">
    <title>a21liltr</title>
</head>
<body>
<h1>WELCOME ALL ALIENS!</h1>
<br />
<h3>MAKE A REGISTRATION NOW!</h3>
<form id="register_form">

    <button type="submit">SUBMIT</button>
</form>

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

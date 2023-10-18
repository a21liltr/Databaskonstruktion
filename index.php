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

<?php
    $agent = 'EJINLOGGAD'
?>

<h1>REGISTRATION CENTER</h1>
<?php
    if ($agent == 'EJINLOGGAD') {
        echo "<h3>YOU ARE NOT LOGGED IN</h3>";
    }
    else {
        echo "Welcome Agent.";
    }
?>

<button onclick="redirect">Click me</button>

<script>
    function redirect() {
        window.location.href="registration_center.php";
    }
</script>
</body>
</html>

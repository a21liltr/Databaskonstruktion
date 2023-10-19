<?php
require_once 'db_connection.php';
session_start();

function loginUser($pdo, $username, $password)
{

    $query = "SELECT * FROM användare WHERE användarnamn = :username AND lösenord = :password";
    $stmt = $pdo->prepare($query);
    $stmt->execute([
        ':username' => $username,
        ':password' => $password
    ]);

   return $stmt->rowCount() != 0;
}
try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST' )
    {
        $username = $_POST["username"];
        $password = $_POST["password"];

        if($username && $password && loginUser($pdo,$username, $password))
        {
            $_SESSION['USER'] = $username;
            header('Location: Index.php');

        }
        else
        {
            echo "fail";
        }
    }
}
catch(PDOException $exception)
{
    echo "db connection";
}


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

<form method="post">
    <label>USERNAME: </label><br>
    <input name="username" type="text"><br><br>

    <label>PASSWORD: </label><br>
    <input name="password" type="password"><br><br>

    <input type="submit" value="LOGIN">
</form>
</body>
</html>

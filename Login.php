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
            header('Location: landingsite.php');

        }
        else
        {
            echo "Wrong USERNAME or PASSWORD";
        }
    }
}
catch(PDOException $exception)
{
    echo "Something went wrong!";
}


?>

<form action="radera_takmaterial.php" method="post">
    <input type="hidden" name="takmaterial_id" value="1">
    <input type="submit" value="Radera Takmaterial">
</form>

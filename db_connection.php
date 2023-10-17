<?php

$host = "localhost";
$username = "administratör";
$password = "bar";
$dbname = "a21liltr";

try {
    $pdo = new PDO("mysql:host=$host; dbname=$database", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Connected successfully";
} catch (PDOException $e) {
    echo 'Connection failed: ' . $e->getMessage();
}
?>
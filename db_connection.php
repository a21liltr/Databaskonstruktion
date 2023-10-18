<?php
$host = "localhost";
$username = "a21liltr_administratör";
$password = "bar";
$dbname = "a21liltr";

try {
    $pdo = new PDO("mysql:host=$host; dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    echoMessageForSeconds("Connected successfully.", 4);
} catch (PDOException $e) {
    echo 'Connection failed: ' . $e->getMessage();
}


function echoMessageForSeconds($message, $seconds)
{
    echo "<div id='message' style='display:block;'>$message</div>";
    echo "<script>
        setTimeout(function() {
            document.getElementById('message').style.display = 'none';
        }, $seconds * 1000);
    </script>";
}

?>
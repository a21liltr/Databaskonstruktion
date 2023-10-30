<?php require "db_connection.php";

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['agent']) && isset($_POST['command'])) 
{
    $agent = $_POST['agent'];
    $kommando = $_POST['command'];


    $stmt = $pdo->prepare("CALL nollställ_begränsning(:agent, :command)");
    $stmt->bindParam(':agent', $agent, PDO::PARAM_STR);
    $stmt->bindParam(':command', $kommando, PDO::PARAM_STR);

    if ($stmt->execute())
     {
        echo "Limit reset successful!";
    } else
     {
        echo "Something went wrong: " . $stmt->error;
    }
}
?>
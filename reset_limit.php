<?php require "db_connection.php";

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['agent']) && isset($_POST['command'])) 
{
    $agent = $_POST['agent'];
    $kommando = $_POST['kommando'];


    $stmt = $pdo->prepare("CALL nollställ_begränsning(:agent, :commando)");
    $stmt->bindParam(':agent', $agent, PDO::PARAM_STR);
    $stmt->bindParam(':commando', $kommando, PDO::PARAM_STR);

    if ($stmt->execute())
     {
        echo "Procedure executed successfully!";
    } else
     {
        echo "Error executing procedure: " . $stmt->error;
    }
}
?>
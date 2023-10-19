<?php require 'db_connection.php';
session_start();
?>

<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <style>
        .btn { background-color: #f44336; color: white; border: none; padding: 10px 20px; cursor: pointer; }
    </style>
</head>
<body>
    <h3>Logged in as: <?php echo $_SESSION['USER']; ?></h3>
    <form method="post" action="logout.php">
        <input class="btn" type="submit" value="Logout">
    </form>

<?php
echo "<h3>List of Registered Aliens</h3>";

try {
    $query = $pdo->prepare("SELECT namn FROM Registrerad_Alien");
    $query->execute();

    $aliens = $query->fetchAll(PDO::FETCH_ASSOC);

    if ($aliens) {
        echo "<select name='dropdown'>";
        foreach ($aliens as $alien) {
            echo "<option>{$alien['namn']}</option>";
        }
        echo "</select><br>";
    } else {
        echo "No persons found!";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}

$query = $pdo->prepare('SELECT  alien_id, namn FROM Registrerad_Alien');
$query->execute();
$aliens = $query->fetchAll(PDO::FETCH_ASSOC);

foreach ($aliens as $alien) {
    $id = $alien['alien_id'];
    $namn = $alien['namn'];

    echo "<a href='delete_alien.php?id={$id}'>Delete Alien {$namn} with ID: {$id}</a><br>";
}

echo "<h4>Registered Aliens: </h4>";
echo "<table>";
    $query = "SELECT * FROM Registrerad_Alien";
    $aliens = $pdo->query($query);
    if($aliens != null)
     {
         foreach ($aliens as $row) 
         {
                echo "<tr>";
                echo "<td>" . $row['alien_id'] . "</td>";
                echo "<td> " . $row['namn'] . "</td>";
                echo "<td>" .  $row['pnr'] . "</td>";
                echo "<td>" .  $row['hemplanet'] . "</td>";
                echo "</tr>";
            }
        
    }
    echo "</tbody>";
    echo "</table>";

    echo "<h4>Unregistered Aliens: </h4>";
    echo "<table>";
    $query = "SELECT * FROM Oregistrerad_Alien";
    $aliens = $pdo->query($query);
    if($aliens != null)
     {
         foreach ($aliens as $row) 
         {
                echo "<tr>";
                echo "<td>" . $row['alien_id'] . "</td>";
                echo "<td> " . $row['namn'] . "</td>";
                echo "<td>" .  $row['införelsedatum'] . "</td>";

                echo "</tr>";
            }
        
    }
    echo "</tbody>";
    echo "</table>";
?>

    <h3>Reset Limit For Agent on Procedure</h3>
    <form method="post" action="reset_limit.php" >
        <table>
            <tr>
                <td><label for="agent">For Agent:</label></td>
                <td><input type="text" id="agent" name="agent" required></td>
            </tr>

            <tr>
                <td><label for="kommando">Procedure name:</label></td>
                <td><input type="text" id="kommando" name="command" required><br></td>
            </tr>
        </table>
        <input type="submit" value="Execute Procedure">
    </form>

    <h3>Find Alien by RACE</h3>
    <form method="post" action="search_by_race.php">
        <label>DANGER LEVEL:</label>
        <select name="farlighet">
            <option value="1">Harmless</option>
            <option value="2">Half Harmless</option>
            <option value="3">Barely Harmless</option>
            <option value="4">Neutral</option>
            <option value="5">Slightly dangerous</option>
            <option value="6">Dangerous</option>
            <option value="7">Extremely Dangerous</option>
            <option value="8">Run For Your Life</option>s
        </select>
        <input type="submit" value="Find">
    </form>


    <h3>Add an ALIEN</h3>
        <table>
            <form method="post" action="add_alien.php">
                <tr><td>ID:</td><td><input type="number" name="alien_id"></td></tr>
                <tr><td>Namn:</td><td><input type="media_namn" name="namn"></td></tr>
                <tr><td>Hemplanet:</td><td><input type="text" name="hemplanet"></td></tr>
                <tr><td><input type="submit" value="ADD ALIEN"></td></tr>
            </form>
        </table>

</body>
</html>
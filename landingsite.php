<?php require 'db_connection.php';
    session_start();
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>a21liltr: Landing site</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
<h3>Logged in as: <?php echo $_SESSION['USER']; ?></h3>
<form method="post" action="logout.php">
    <input class="logout" type="submit" value="Logout">
</form>

<?php
    echo "<table>";
    $query = "SELECT * FROM Procedure_Begränsning";
    $stmt = $pdo->query($query);
    if($stmt != null)
    {
        foreach ($stmt as $row)
        {
            echo "<tr>";
            echo "<td>" . $row['användare'] . "</td>";
            echo "<td> " . $row['procedure_namn'] . "</td>";
            echo "<td>" .  $row['användningar'] . "</td>";
            echo "<td>" .  $row['begränsning'] . "</td>";
            echo "</tr>";
        }

    }

    ?>

<h3>Reset Limit For Agent on Procedure</h3>
<form method="post" action="reset_limit.php" >
    <table>
        <tr>
            <td><label for="agent">Agent:</label></td>
            <td><input type="text" id="agent" name="agent" required></td>
        </tr>

        <tr>
            <td><label for="kommando">Procedure name:</label></td>
            <td><input type="text" id="kommando" name="command" required><br></td>
        </tr>
    </table>
    <input class="execute" type="submit" value="RESET LIMIT">
</form><br><br>

<?php
    // Shows list of races in a dropdownlist,
    // Races are DISTINCT.
    try {
        $query = $pdo->prepare("SELECT DISTINCT ras_namn FROM Offentliga_Raser_view");
        $query->execute();

        $stmt = $query->fetchAll(PDO::FETCH_ASSOC);

        if ($stmt) {
            echo "<select name='dropdown'>";
            echo "<option hidden disabled selected>Races in the database</option>";
            foreach ($stmt as $row) {
                echo "<option>{$row['ras_namn']}</option>";
            }
            echo "</select><br>";
        } else {
            echo "<option hidden disabled selected>No races in the database</option>";
        }

    } catch (PDOException $e) {
        echo "Error: " . $e->getMessage();
    }
?>

<h3>Register an ALIEN</h3>
<table>
    <form method="post" action="add_alien.php">
        <tr><td>Name:</td><td><input type="text" name="namn"></td></tr>
        <tr><td>Home Planet:</td><td><input type="text" name="hemplanet" placeholder="Add a Home Planet to fully register"></td></tr>
        <tr><td><input class="execute" type="submit" value="ADD ALIEN"></td></tr>
    </form>
</table>

<?php

    echo "<h3>List of Aliens</h3>";
    echo "<h4>Registered Aliens (fully registered aliens): </h4>";
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
    $query = $pdo->prepare('SELECT  alien_id, namn FROM Registrerad_Alien');
    $query->execute();
    $aliens = $query->fetchAll(PDO::FETCH_ASSOC);

    foreach ($aliens as $alien) {
        $id = $alien['alien_id'];
        $namn = $alien['namn'];

        //HYPERLINK to immediately delete a registered alien from the DATABASE.
        echo "<a href='delete_alien.php?id={$id}'>Delete Alien {$namn} with ID: {$id}</a><br>";
    }

    echo "<h4>Unregistered Aliens (partially registered aliens) : </h4>";
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

<h3>DELETE an alien from the database</h3>
<form method="post" action="delete_id.php" >
    <input type="text" id="alien_id" name="alien_id" placeholder="Type in an Alien ID here...">
    <input class="execute" type="submit" value="DELETE ALIEN">
</form>

<h3>Find Alien by DANGER LEVEL</h3>
<form method="post" action="search_by_danger.php">
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
    <input class="execute" type="submit" value="FIND">
</form>
</body>
</html>
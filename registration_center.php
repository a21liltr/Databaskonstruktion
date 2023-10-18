<?php
    require 'db_connection.php';
    global $pdo;
?>

<div class="register_and_list">
    <div class="registration">
        <form id="register_form" method="post">
            <label>Name: </label><br>
            <input type="text" name="alien_namn"><br><br>

            <label>Hemplanet: </label><br>
            <input type="text" name="hemplanet"><br><br>
            
            <input type="submit" name="submit" value="SUBMIT">
        </form>
    </div>
    <div class="warning_area">
        <h3>
            <?php
                $warning_text;
            ?>
        </h3>
    </div>
</div>
<div class="registered_aliens">
    <h3>REGISTERED ALIENS</h3>
    <table class="alien_list" cellpadding="4px;">
        <?php

            if(isset($_POST['submit'])) {
                checkSubmitOk();
            }

            echo "<pre>";
            foreach ($pdo->query('SELECT namn, hemplanet FROM Registrerad_Alien;') AS $row) {
                echo "<tr>";
                foreach ($row AS $col=>$val) {
                    $title = strtoupper($col);
                    echo "<td>";
                    echo $title. "<br>" .$val. "<br>";
                    echo "</td>";
                }
                echo "</tr>";
            }
            echo "</pre>";

            // method for generating a string of 25 characters.
            function generateRandomString() {
                $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789';
                $charactersLength = strlen($characters);
                $randomString = '';
                for ($i = 0; $i < 25; $i++) {
                    $randomString .= $characters[mt_rand(0, $charactersLength - 1)];
                }
                return $randomString;
            }

            function checkSubmitOk() {
                $warning_text = '';
                $alien_id = generateRandomString();

                if(isset($_POST['alien_namn'])) {
                    $registerstring = 'INSERT INTO Oregistrerad_Alien (alien_id, namn) VALUES (:ALIENID, :ALIENNAMN)';
                    $stmt = $pdo->prepare($registerstring);
                    $stmt->bindParam(':ALIENID', $alien_id);
                    $stmt->bindParam(':ALIENNAMN', $_POST['alien_namn']);
                    if(isset($_POST['hemplanet'])) {
                        $registerstring = 'INSERT INTO Registrerad_Alien (alien_id, namn, hemplanet) VALUES (:ALIENID, :ALIENNAMN, :HEMPLANET)';
                        $stmt = $pdo->prepare($registerstring);
                        $stmt->bindParam(':ALIENID', $alien_id);
                        $stmt->bindParam(':ALIENNAMN', $_POST['alien_namn']);
                        $stmt->bindParam(':HEMPLANET', $_POST['hemplanet']);
                    }
                    $stmt->execute();
                }
                else {
                    $warning_text = "Please enter your NAME!";
                }
                $warning_text = "Something went wrong.";
            }

        ?>
    </table>
</div>
<div class="unregistered_aliens">
    <h3>ILLEGAL TRESPASSERS!</h3>
    <?php
        echo "<pre>";
        foreach ($pdo->query('SELECT namn FROM Oregistrerad_Alien;') AS $row) {
            echo "<tr>";
            foreach ($row AS $col=>$val) {
                $title = strtoupper($col);
                echo "<td>";
                echo $val."<br>";
                echo "</td>";
            }
            echo "</tr>";
        }
        echo "</pre>";
    ?>
</div><?php

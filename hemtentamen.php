<?php
    $adress = $_POST['adress'];
    $plats = $_POST['plats'];

    if (isset($_POST['kategori'])) {
        $kategori = $_POST['kategori'];
    }
    else {
        $kategori = null;
    }

    // Kör olika inserts beroende på användarens inmatning
    if ($kategori != null) {
        $query = "INSERT INTO hus (adress, plats, kategori) VALUES ('$adress', '$plats', '$kategori')";
        // code
    }
    else {
        $query = "INSERT INTO hus (adress, plats) VALUES ('$adress', '$plats')";
        // code
    }
?>

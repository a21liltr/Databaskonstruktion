<?php
    require_once 'db_connection.php';

    session_start();
    session_destroy();

    header("Location: login.php");
    exit();

?>
<?php require_once 'db.php';
$id = intval($_GET['id']);
mysqli_query($conn, "DELETE FROM news WHERE id=$id");
header('location:news.php');

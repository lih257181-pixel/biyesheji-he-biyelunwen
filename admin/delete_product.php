<?php require_once 'db.php';
$id = intval($_GET['id']);
mysqli_query($conn, "DELETE FROM products WHERE id=$id");
header('location:products.php');

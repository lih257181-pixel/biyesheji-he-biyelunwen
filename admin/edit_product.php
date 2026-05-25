<?php
$id = intval($_GET['id'] ?? 0);
if ($id) header("location:add_product.php?id=$id");
else header('location:products.php');

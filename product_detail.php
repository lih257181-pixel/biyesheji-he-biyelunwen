<?php require_once 'db.php';
$id = intval($_GET['id']);
$row = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM products WHERE id=$id"));
if (!$row) { header('location:products.php'); exit; }
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title><?=htmlspecialchars($row['name'])?> - 云创科技</title>
<link href="css/style.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<div class="header">
  <div class="logo">
    <h1><span>云</span>创科技</h1>
    <?php include "top.php"; ?>
  </div>
</div>
<div class="nav"><?php include "nav.php"; ?></div>
<div class="container">
  <div class="detail-box">
    <h2><?=htmlspecialchars($row['name'])?></h2>
    <div class="meta">价格：¥<?=$row['price']?> | 分类：<?=htmlspecialchars($row['category'])?></div>
    <div class="content">
      <p><?=nl2br(htmlspecialchars($row['description']))?></p>
    </div>
    <p style="margin-top:20px;"><a href="order.php?pid=<?=$row['id']?>" class="btn">立即订购</a></p>
  </div>
</div>
<div class="footer">
  <p>© 2026 云创科技有限公司 版权所有</p>
</div>
</body>
</html>

<?php require_once 'db.php';
$nid = intval($_GET['nid']);
$row = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM news WHERE id=$nid"));
if (!$row) { header('location:news.php'); exit; }
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title><?=htmlspecialchars($row['title'])?> - 云创科技</title>
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
    <h2><?=htmlspecialchars($row['title'])?></h2>
    <div class="meta">发布日期：<?=$row['create_time']?></div>
    <div class="content"><?=nl2br(htmlspecialchars($row['content']))?></div>
  </div>
</div>
<div class="footer">
  <p>© 2026 云创科技有限公司 版权所有</p>
</div>
</body>
</html>

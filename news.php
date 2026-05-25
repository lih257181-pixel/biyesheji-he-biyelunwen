<?php require_once 'db.php'; ?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>新闻动态 - 云创科技</title>
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
  <h2 class="page-title">新闻动态</h2>
  <ul class="news-list">
    <?php
    $res = mysqli_query($conn, "SELECT * FROM news ORDER BY id DESC");
    while ($row = mysqli_fetch_assoc($res)):
    ?>
    <li>
      <a href="news_detail.php?nid=<?=$row['id']?>"><?=htmlspecialchars($row['title'])?></a>
      <span class="date"><?=$row['create_time']?></span>
    </li>
    <?php endwhile; ?>
  </ul>
</div>
<div class="footer">
  <p>© 2026 云创科技有限公司 版权所有</p>
</div>
</body>
</html>

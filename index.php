<?php require_once 'db.php'; ?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>云创科技 - 数字化转型服务商</title>
<link href="css/style.css" rel="stylesheet" type="text/css"/>
</head>
<body>

<div class="header">
  <div class="logo">
    <h1><span>云</span>创科技</h1>
    <?php include "top.php"; ?>
  </div>
</div>

<div class="nav">
  <?php include "nav.php"; ?>
</div>

<div class="banner">
  <img src="images/banner.jpg" alt="云创科技" onerror="this.style.display='none';document.querySelector('.banner').style.background='linear-gradient(135deg,#1a4a73,#2c6b9e)';document.querySelector('.banner').innerHTML+='<div class=overlay><h2>云创科技</h2><p>以数据驱动未来，用智能赋能企业</p></div>'"/>
</div>

<div class="container">
  <h2 class="section-title">产品与服务</h2>
  <div class="products-grid">
    <?php
    $res = mysqli_query($conn, "SELECT * FROM products ORDER BY id DESC LIMIT 4");
    while ($row = mysqli_fetch_assoc($res)):
    ?>
    <div class="product-card">
      <a href="product_detail.php?id=<?=$row['id']?>">
        <img src="<?=htmlspecialchars($row['image'])?>" alt="<?=htmlspecialchars($row['name'])?>" onerror="this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22260%22 height=%22200%22><rect fill=%22%23eee%22 width=%22260%22 height=%22200%22/><text x=%22130%22 y=%22105%22 text-anchor=%22middle%22 fill=%22%23999%22 font-size=%2214%22>暂无图片</text></svg>'">
        <div class="info">
          <h3><?=htmlspecialchars($row['name'])?></h3>
          <div class="price">¥<?=$row['price']?></div>
          <div class="desc"><?=htmlspecialchars(mb_substr($row['description'],0,60))?></div>
        </div>
      </a>
    </div>
    <?php endwhile; ?>
  </div>
</div>

<div class="container">
  <h2 class="section-title">新闻动态</h2>
  <ul class="news-list">
    <?php
    $res = mysqli_query($conn, "SELECT * FROM news ORDER BY id DESC LIMIT 5");
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
  <p>© 2026 云创科技有限公司 版权所有 | 地址：浙江省杭州市滨江区科技路88号 | 电话：0571-88886666</p>
</div>

</body>
</html>

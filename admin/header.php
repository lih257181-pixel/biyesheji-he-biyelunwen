<?php require_once 'db.php'; ?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>后台管理 - 云创科技</title>
<link href="css/style.css" rel="stylesheet"/>
<style>
body{margin:0;font-family:"Microsoft YaHei",sans-serif;}
.admin-header{background:#1a4a73;color:#fff;padding:0 30px;display:flex;justify-content:space-between;align-items:center;height:60px;}
.admin-header h2{font-size:20px;}
.admin-header a{color:#cde0f5;margin-left:20px;font-size:14px;text-decoration:none;}
.admin-layout{display:flex;min-height:calc(100vh - 60px);}
.admin-sidebar{width:200px;background:#2c3e50;padding:15px 0;flex-shrink:0;}
.admin-sidebar a{display:block;padding:12px 20px;color:#b0cce5;text-decoration:none;font-size:14px;transition:0.2s;}
.admin-sidebar a:hover{background:#34495e;color:#fff;}
.admin-main{flex:1;padding:30px;background:#f4f7fa;overflow-x:auto;}
.admin-main h3{margin-bottom:20px;color:#1a4a73;}
</style>
</head>
<body>
<div class="admin-header">
  <h2>云创科技后台管理</h2>
  <div>
    <span>管理员：<?=htmlspecialchars($_SESSION['admin'])?></span>
    <a href="exit.php">退出登录</a>
  </div>
</div>
<div class="admin-layout">
<div class="admin-sidebar">
  <a href="dashboard.php">管理首页</a>
  <a href="products.php">产品管理</a>
  <a href="add_product.php">添加产品</a>
  <a href="news.php">新闻管理</a>
  <a href="add_news.php">添加新闻</a>
  <a href="messages.php">留言管理</a>
  <a href="orders.php">订单管理</a>
  <a href="users.php">用户管理</a>
</div>
<div class="admin-main">

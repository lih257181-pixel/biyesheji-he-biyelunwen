<?php require_once 'db.php'; ?>
<?php include 'header.php'; ?>
<h3>管理首页</h3>
<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:20px;">
<?php
$counts = [
  '产品总数' => mysqli_fetch_assoc(mysqli_query($conn,"SELECT COUNT(*) c FROM products"))['c'],
  '新闻总数' => mysqli_fetch_assoc(mysqli_query($conn,"SELECT COUNT(*) c FROM news"))['c'],
  '留言总数' => mysqli_fetch_assoc(mysqli_query($conn,"SELECT COUNT(*) c FROM messages"))['c'],
  '订单总数' => mysqli_fetch_assoc(mysqli_query($conn,"SELECT COUNT(*) c FROM orders"))['c'],
  '注册用户' => mysqli_fetch_assoc(mysqli_query($conn,"SELECT COUNT(*) c FROM users"))['c'],
];
foreach ($counts as $label => $count):
?>
<div style="background:#fff;padding:25px;border-radius:8px;box-shadow:0 1px 6px rgba(0,0,0,0.06);text-align:center;">
  <div style="font-size:32px;color:#2c6b9e;font-weight:bold;"><?=$count?></div>
  <div style="color:#888;margin-top:8px;"><?=$label?></div>
</div>
<?php endforeach; ?>
</div>
<?php include 'footer.php'; ?>

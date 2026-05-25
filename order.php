<?php require_once 'db.php';
if ($_POST) {
    $pid = intval($_POST['pid']);
    $qty = intval($_POST['quantity']) ?: 1;
    $name = trim($_POST['contact_name']);
    $phone = trim($_POST['contact_phone']);
    $addr = trim($_POST['address']);
    $note = trim($_POST['note']);
    $uid = isset($_SESSION['user_id']) ? intval($_SESSION['user_id']) : 0;
    if ($pid && $name && $phone) {
        mysqli_query($conn, "INSERT INTO orders (user_id,product_id,quantity,contact_name,contact_phone,address,note)
            VALUES ($uid,$pid,$qty,'$name','$phone','$addr','$note')");
        echo "<script>alert('订购成功！我们会尽快联系您确认订单。');location.href='order.php';</script>";
        exit;
    }
}
$pid = intval($_GET['pid'] ?? ($_POST['pid'] ?? 0));
$product = null;
if ($pid) {
    $product = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM products WHERE id=$pid"));
}
$user_orders = [];
if (isset($_SESSION['user_id'])) {
    $uid = intval($_SESSION['user_id']);
    $res = mysqli_query($conn, "SELECT o.*,p.name as pname FROM orders o LEFT JOIN products p ON o.product_id=p.id WHERE o.user_id=$uid ORDER BY o.id DESC");
    while ($r = mysqli_fetch_assoc($res)) $user_orders[] = $r;
}
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>在线订购 - 云创科技</title>
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
  <h2 class="page-title">在线订购</h2>
  <div style="max-width:600px;">
    <form method="post">
      <div class="form-group">
        <label>选择产品 *</label>
        <select name="pid" required>
          <option value="">请选择</option>
          <?php
          $res = mysqli_query($conn, "SELECT * FROM products ORDER BY name");
          while ($r = mysqli_fetch_assoc($res)):
          ?>
          <option value="<?=$r['id']?>" <?=$pid==$r['id']?'selected':''?>><?=htmlspecialchars($r['name'])?> - ¥<?=$r['price']?></option>
          <?php endwhile; ?>
        </select>
      </div>
      <div class="form-group">
        <label>数量 *</label>
        <input type="number" name="quantity" value="1" min="1" required>
      </div>
      <div class="form-group">
        <label>联系人 *</label>
        <input type="text" name="contact_name" required>
      </div>
      <div class="form-group">
        <label>联系电话 *</label>
        <input type="text" name="contact_phone" required>
      </div>
      <div class="form-group">
        <label>收货地址</label>
        <input type="text" name="address">
      </div>
      <div class="form-group">
        <label>备注</label>
        <textarea name="note"></textarea>
      </div>
      <button type="submit" class="btn">提交订单</button>
    </form>
  </div>

  <?php if ($user_orders): ?>
  <h2 class="section-title" style="margin-top:40px;">我的订单</h2>
  <table>
    <tr><th>产品</th><th>数量</th><th>联系人</th><th>状态</th><th>时间</th></tr>
    <?php foreach ($user_orders as $o): ?>
    <tr>
      <td><?=htmlspecialchars($o['pname'])?></td>
      <td><?=$o['quantity']?></td>
      <td><?=htmlspecialchars($o['contact_name'])?></td>
      <td><?=$o['status']?></td>
      <td><?=$o['create_time']?></td>
    </tr>
    <?php endforeach; ?>
  </table>
  <?php endif; ?>
</div>
<div class="footer">
  <p>© 2026 云创科技有限公司 版权所有</p>
</div>
</body>
</html>

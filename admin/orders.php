<?php require_once 'db.php';
if ($_POST && isset($_POST['status'])) {
    $id = intval($_POST['id']);
    $status = trim($_POST['status']);
    mysqli_query($conn, "UPDATE orders SET status='$status' WHERE id=$id");
    echo "<script>alert('更新成功！');location.href='orders.php';</script>"; exit;
}
$res = mysqli_query($conn, "SELECT o.*,p.name as pname,u.username FROM orders o LEFT JOIN products p ON o.product_id=p.id LEFT JOIN users u ON o.user_id=u.id ORDER BY o.id DESC");
include 'header.php'; ?>
<h3>订单管理</h3>
<table><tr><th>ID</th><th>产品</th><th>数量</th><th>联系人</th><th>电话</th><th>地址</th><th>状态</th><th>操作</th></tr>
<?php while ($row = mysqli_fetch_assoc($res)): ?>
<tr>
  <td><?=$row['id']?></td>
  <td><?=htmlspecialchars($row['pname'])?></td>
  <td><?=$row['quantity']?></td>
  <td><?=htmlspecialchars($row['contact_name'])?></td>
  <td><?=htmlspecialchars($row['contact_phone'])?></td>
  <td><?=htmlspecialchars($row['address'])?></td>
  <td><?=$row['status']?></td>
  <td><form method="post" style="display:inline;">
    <input type="hidden" name="id" value="<?=$row['id']?>">
    <select name="status" onchange="this.form.submit()">
      <option <?=$row['status']=='待处理'?'selected':''?>>待处理</option>
      <option <?=$row['status']=='已确认'?'selected':''?>>已确认</option>
      <option <?=$row['status']=='已发货'?'selected':''?>>已发货</option>
      <option <?=$row['status']=='已完成'?'selected':''?>>已完成</option>
    </select>
  </form></td>
</tr>
<?php endwhile; ?>
</table>
<?php include 'footer.php'; ?>

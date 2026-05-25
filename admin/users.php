<?php require_once 'db.php';
$res = mysqli_query($conn, "SELECT * FROM users ORDER BY id DESC");
include 'header.php'; ?>
<h3>用户管理</h3>
<table><tr><th>ID</th><th>用户名</th><th>电话</th><th>邮箱</th><th>注册时间</th></tr>
<?php while ($row = mysqli_fetch_assoc($res)): ?>
<tr>
  <td><?=$row['id']?></td>
  <td><?=htmlspecialchars($row['username'])?></td>
  <td><?=htmlspecialchars($row['phone']?:'-')?></td>
  <td><?=htmlspecialchars($row['email']?:'-')?></td>
  <td><?=$row['create_time']?></td>
</tr>
<?php endwhile; ?>
</table>
<?php include 'footer.php'; ?>

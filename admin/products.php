<?php require_once 'db.php';
$res = mysqli_query($conn, "SELECT * FROM products ORDER BY id DESC");
include 'header.php'; ?>
<h3>产品管理</h3>
<a href="add_product.php" class="btn" style="margin:10px 0;">添加产品</a>
<table><tr><th>ID</th><th>名称</th><th>分类</th><th>价格</th><th>操作</th></tr>
<?php while ($row = mysqli_fetch_assoc($res)): ?>
<tr>
  <td><?=$row['id']?></td>
  <td><?=htmlspecialchars($row['name'])?></td>
  <td><?=htmlspecialchars($row['category'])?></td>
  <td>¥<?=$row['price']?></td>
  <td>
    <a href="add_product.php?id=<?=$row['id']?>">编辑</a>
    <a href="delete_product.php?id=<?=$row['id']?>" onclick="return confirm('确定删除？')">删除</a>
  </td>
</tr>
<?php endwhile; ?>
</table>
<?php include 'footer.php'; ?>

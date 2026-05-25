<?php require_once 'db.php';
$res = mysqli_query($conn, "SELECT * FROM news ORDER BY id DESC");
include 'header.php'; ?>
<h3>新闻管理</h3>
<a href="add_news.php" class="btn" style="margin:10px 0;">添加新闻</a>
<table><tr><th>ID</th><th>标题</th><th>时间</th><th>操作</th></tr>
<?php while ($row = mysqli_fetch_assoc($res)): ?>
<tr>
  <td><?=$row['id']?></td>
  <td><?=htmlspecialchars($row['title'])?></td>
  <td><?=$row['create_time']?></td>
  <td>
    <a href="add_news.php?id=<?=$row['id']?>">编辑</a>
    <a href="delete_news.php?id=<?=$row['id']?>" onclick="return confirm('确定删除？')">删除</a>
  </td>
</tr>
<?php endwhile; ?>
</table>
<?php include 'footer.php'; ?>

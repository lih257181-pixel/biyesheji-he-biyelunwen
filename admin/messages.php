<?php require_once 'db.php';
if ($_POST && isset($_POST['reply'])) {
    $id = intval($_POST['id']);
    $reply = trim($_POST['reply']);
    mysqli_query($conn, "UPDATE messages SET reply='$reply' WHERE id=$id");
    echo "<script>alert('回复成功！');location.href='messages.php';</script>"; exit;
}
$res = mysqli_query($conn, "SELECT * FROM messages ORDER BY id DESC");
include 'header.php'; ?>
<h3>留言管理</h3>
<table><tr><th>ID</th><th>姓名</th><th>电话</th><th>留言</th><th>回复</th><th>时间</th><th>操作</th></tr>
<?php while ($row = mysqli_fetch_assoc($res)): ?>
<tr>
  <td><?=$row['id']?></td>
  <td><?=htmlspecialchars($row['name'])?></td>
  <td><?=htmlspecialchars($row['phone'])?></td>
  <td><?=htmlspecialchars(mb_substr($row['content'],0,50))?></td>
  <td><?=htmlspecialchars(mb_substr($row['reply']??'',0,30))?:'未回复'?></td>
  <td><?=$row['create_time']?></td>
  <td><a href="javascript:showReply(<?=$row['id']?>, '<?=htmlspecialchars(addslashes($row['content']))?>')">回复</a></td>
</tr>
<?php endwhile; ?>
</table>
<script>
function showReply(id, content) {
    var reply = prompt('客户留言：' + content + '\n\n请输入回复：');
    if (reply !== null) {
        var f = document.createElement('form'); f.method = 'post';
        f.innerHTML = '<input name="id" value="' + id + '"><input name="reply" value="' + reply + '">';
        document.body.appendChild(f); f.submit();
    }
}
</script>
<?php include 'footer.php'; ?>

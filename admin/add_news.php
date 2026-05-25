<?php require_once 'db.php';
$edit_id = intval($_POST['id'] ?? 0);
if ($_POST) {
    $title = trim($_POST['title']);
    $content = trim($_POST['content']);
    $image = trim($_POST['image']);
    if ($title) {
        if ($edit_id) {
            mysqli_query($conn, "UPDATE news SET title='$title',content='$content',image='$image' WHERE id=$edit_id");
        } else {
            mysqli_query($conn, "INSERT INTO news (title,content,image) VALUES ('$title','$content','$image')");
        }
        echo "<script>alert('保存成功！');location.href='news.php';</script>"; exit;
    }
}
$action = '添加'; $row = ['title'=>'','content'=>'','image'=>''];
$id = intval($_GET['id'] ?? 0);
if ($id) {
    $row = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM news WHERE id=$id"));
    $action = '编辑';
}
include 'header.php'; ?>
<h3><?=$action?>新闻</h3>
<form method="post" style="max-width:600px;">
  <input type="hidden" name="id" value="<?=$id?>">
  <div class="form-group"><label>新闻标题</label><input name="title" value="<?=htmlspecialchars($row['title'])?>" required></div>
  <div class="form-group"><label>图片地址</label><input name="image" value="<?=htmlspecialchars($row['image'])?>" placeholder="选填"></div>
  <div class="form-group"><label>新闻内容</label><textarea name="content" style="min-height:250px;"><?=htmlspecialchars($row['content'])?></textarea></div>
  <button type="submit" class="btn">保存</button>
  <a href="news.php" class="btn" style="background:#999;">返回</a>
</form>
<?php include 'footer.php'; ?>

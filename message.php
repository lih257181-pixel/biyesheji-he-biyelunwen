<?php require_once 'db.php';
if ($_POST) {
    $name = trim($_POST['name']);
    $phone = trim($_POST['phone']);
    $content = trim($_POST['content']);
    if ($name && $content) {
        $phone = mysqli_real_escape_string($conn, $phone);
        mysqli_query($conn, "INSERT INTO messages (name,phone,content) VALUES ('$name','$phone','$content')");
        echo "<script>alert('留言提交成功，我们会尽快回复您！');location.href='message.php';</script>";
    } else {
        echo "<script>alert('请填写姓名和留言内容！');</script>";
    }
}
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>客户留言 - 云创科技</title>
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
  <h2 class="page-title">客户留言</h2>
  <div style="max-width:600px;">
    <form method="post">
      <div class="form-group">
        <label>姓名 *</label>
        <input type="text" name="name" required>
      </div>
      <div class="form-group">
        <label>联系电话</label>
        <input type="text" name="phone">
      </div>
      <div class="form-group">
        <label>留言内容 *</label>
        <textarea name="content" required></textarea>
      </div>
      <button type="submit" class="btn">提交留言</button>
    </form>
  </div>
</div>
<div class="footer">
  <p>© 2026 云创科技有限公司 版权所有</p>
</div>
</body>
</html>

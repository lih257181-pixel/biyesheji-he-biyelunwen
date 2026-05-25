<?php require_once 'db.php';
if ($_POST) {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);
    $phone = trim($_POST['phone']);
    $email = trim($_POST['email']);
    if ($username && $password) {
        $check = mysqli_query($conn, "SELECT id FROM users WHERE username='$username'");
        if (mysqli_fetch_assoc($check)) {
            echo "<script>alert('用户名已存在！');</script>";
        } else {
            mysqli_query($conn, "INSERT INTO users (username,password,phone,email) VALUES ('$username','$password','$phone','$email')");
            echo "<script>alert('注册成功，请登录！');location.href='login.php';</script>";
            exit;
        }
    }
}
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>用户注册 - 云创科技</title>
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
<div class="login-form">
  <h2>用户注册</h2>
  <form method="post">
    <div class="form-group">
      <label>用户名 *</label>
      <input type="text" name="username" required>
    </div>
    <div class="form-group">
      <label>密码 *</label>
      <input type="password" name="password" required>
    </div>
    <div class="form-group">
      <label>手机号</label>
      <input type="text" name="phone">
    </div>
    <div class="form-group">
      <label>邮箱</label>
      <input type="email" name="email">
    </div>
    <button type="submit" class="btn" style="width:100%;">注册</button>
    <p style="margin-top:12px;text-align:center;">已有账号？<a href="login.php">立即登录</a></p>
  </form>
</div>
<div class="footer">
  <p>© 2026 云创科技有限公司 版权所有</p>
</div>
</body>
</html>

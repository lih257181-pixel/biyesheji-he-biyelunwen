<?php require_once 'db.php';
if ($_POST) {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);
    if ($username && $password) {
        $res = mysqli_query($conn, "SELECT * FROM users WHERE username='$username'");
        $user = mysqli_fetch_assoc($res);
        if ($user && $user['password'] == $password) {
            $_SESSION['user'] = $user['username'];
            $_SESSION['user_id'] = $user['id'];
            echo "<script>alert('登录成功！');location.href='index.php';</script>";
            exit;
        }
        echo "<script>alert('用户名或密码错误！');</script>";
    }
}
if (isset($_GET['act']) && $_GET['act'] == 'logout') {
    session_destroy();
    header('location:index.php');
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>用户登录 - 云创科技</title>
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
  <h2>用户登录</h2>
  <form method="post">
    <div class="form-group">
      <label>用户名</label>
      <input type="text" name="username" required>
    </div>
    <div class="form-group">
      <label>密码</label>
      <input type="password" name="password" required>
    </div>
    <button type="submit" class="btn" style="width:100%;">登录</button>
    <p style="margin-top:12px;text-align:center;">还没有账号？<a href="reg.php">立即注册</a></p>
  </form>
</div>
<div class="footer">
  <p>© 2026 云创科技有限公司 版权所有</p>
</div>
</body>
</html>

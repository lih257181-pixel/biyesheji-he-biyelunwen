<?php
session_start();
if (isset($_SESSION['admin'])) { header('location:dashboard.php'); exit; }
require_once 'db.php';
$conn = mysqli_connect("127.0.0.1","root","123456","cloudthink");
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>管理员登录 - 云创科技</title>
<link href="css/style.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<form action="loginin.php" method="post" class="login">
  <h1>管理员登录</h1>
  <div class="input_all">
    <span>账号：</span>
    <input type="text" class="int" name="admin" placeholder="输入管理员账号" required/>
  </div>
  <div class="input_all">
    <span>密码：</span>
    <input type="password" class="int" name="password" placeholder="输入管理员密码" required/>
  </div>
  <input type="submit" value="登录" class="ins"/>
</form>
<style>
body{background:#f0f2f5;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0;}
.login{background:#fff;padding:40px;border-radius:8px;box-shadow:0 2px 15px rgba(0,0,0,0.1);width:380px;}
.login h1{text-align:center;color:#1a4a73;margin-bottom:30px;font-size:24px;}
.input_all{margin-bottom:18px;}
.input_all span{display:block;margin-bottom:5px;color:#555;font-size:14px;}
.int{width:100%;padding:10px 14px;border:1px solid #ddd;border-radius:4px;font-size:14px;box-sizing:border-box;}
.int:focus{border-color:#2c6b9e;outline:none;}
.ins{width:100%;padding:12px;background:#2c6b9e;color:#fff;border:none;border-radius:4px;font-size:16px;cursor:pointer;}
.ins:hover{background:#1a4a73;}
</style>
</body>
</html>

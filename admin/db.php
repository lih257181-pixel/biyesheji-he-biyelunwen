<?php
$db_host = getenv('MYSQL_HOST') ?: '127.0.0.1';
$db_user = getenv('MYSQL_USER') ?: 'root';
$db_pass = getenv('MYSQL_PASS') ?: '123456';
$db_name = getenv('MYSQL_DB') ?: 'cloudthink';
$conn = mysqli_connect($db_host, $db_user, $db_pass, $db_name);
if (!$conn) die("数据库连接失败！");
mysqli_query($conn, "set names utf8");
session_start();
if (!isset($_SESSION['admin'])) {
    echo "<script>alert('请先登录！');window.location.href='index.php';</script>";
    exit;
}

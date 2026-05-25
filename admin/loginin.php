<?php session_start();
require_once ('../db.php');
$admin=$_POST['admin'];
$password=$_POST['password'];
$sql="select * from admin where username='$admin'";
$res=mysqli_query($conn,$sql);
$ros=mysqli_fetch_assoc($res);
if(isset($ros)){
    if($ros['password']==$password){
        echo"<script>alert('登录成功');window.location.href='dashboard.php';</script>";
        $_SESSION['admin']=$admin;
    }else{
        echo"<script>alert('登录失败');window.location.href='index.php';</script>";
    }
}else{
    echo"<script>alert('登录失败');window.location.href='index.php';</script>";
}

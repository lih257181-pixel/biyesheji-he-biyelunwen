<div class="top-links">
  <?php if (isset($_SESSION['user'])): ?>
    <a href="login.php?act=logout">退出(<?=htmlspecialchars($_SESSION['user'])?>)</a>
  <?php else: ?>
    <a href="login.php">登录</a>
    <a href="reg.php">注册</a>
  <?php endif; ?>
</div>

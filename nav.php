<ul>
  <li><a href="index.php" class="<?=basename($_SERVER['PHP_SELF'])=='index.php'?'active':''?>">首页</a></li>
  <li><a href="about.php" class="<?=basename($_SERVER['PHP_SELF'])=='about.php'?'active':''?>">企业简介</a></li>
  <li><a href="products.php" class="<?=basename($_SERVER['PHP_SELF'])=='products.php'||$_GET['id']?'active':''?>">产品中心</a></li>
  <li><a href="news.php" class="<?=basename($_SERVER['PHP_SELF'])=='news.php'||$_GET['nid']?'active':''?>">新闻动态</a></li>
  <li><a href="message.php">客户留言</a></li>
  <li><a href="order.php">在线订购</a></li>
  <li><a href="contact.php">联系我们</a></li>
</ul>

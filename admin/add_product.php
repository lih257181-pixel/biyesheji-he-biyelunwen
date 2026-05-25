<?php require_once 'db.php';
$edit_id = intval($_POST['id'] ?? 0);
if ($_POST) {
    $name = trim($_POST['name']);
    $cat = trim($_POST['category']);
    $price = floatval($_POST['price']);
    $image = trim($_POST['image']);
    $desc = trim($_POST['description']);
    if ($name) {
        if ($edit_id) {
            mysqli_query($conn, "UPDATE products SET name='$name',category='$cat',price=$price,image='$image',description='$desc' WHERE id=$edit_id");
            echo "<script>alert('更新成功！');location.href='products.php';</script>";
        } else {
            mysqli_query($conn, "INSERT INTO products (name,category,price,image,description) VALUES ('$name','$cat',$price,'$image','$desc')");
            echo "<script>alert('添加成功！');location.href='products.php';</script>";
        }
        exit;
    }
}
$action = '添加';
$row = ['name'=>'','category'=>'','price'=>'','image'=>'','description'=>''];
$id = intval($_GET['id'] ?? 0);
if ($id) {
    $row = mysqli_fetch_assoc(mysqli_query($conn, "SELECT * FROM products WHERE id=$id"));
    $action = '编辑';
}
include 'header.php'; ?>
<h3><?=$action?>产品</h3>
<form method="post" style="max-width:600px;">
  <input type="hidden" name="id" value="<?=$id?>">
  <div class="form-group"><label>产品名称</label><input name="name" value="<?=htmlspecialchars($row['name'])?>" required></div>
  <div class="form-group"><label>分类</label><input name="category" value="<?=htmlspecialchars($row['category'])?>"></div>
  <div class="form-group"><label>价格</label><input name="price" value="<?=$row['price']?>" required></div>
  <div class="form-group"><label>图片地址</label><input name="image" value="<?=htmlspecialchars($row['image'])?>" placeholder="输入图片URL"></div>
  <div class="form-group"><label>产品描述</label><textarea name="description"><?=htmlspecialchars($row['description'])?></textarea></div>
  <button type="submit" class="btn">保存</button>
  <a href="products.php" class="btn" style="background:#999;">返回</a>
</form>
<?php include 'footer.php'; ?>

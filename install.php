<?php
/**
 * 云创科技企业网站 - 在线安装向导
 * 访问 http://localhost:8080/install.php 即可开始安装
 */
$step = $_GET['step'] ?? 1;
$error = '';

if ($_POST) {
    $db_host = trim($_POST['db_host'] ?? '127.0.0.1');
    $db_user = trim($_POST['db_user'] ?? 'root');
    $db_pass = trim($_POST['db_pass'] ?? '');
    $db_name = trim($_POST['db_name'] ?? 'cloudthink');

    if ($step == 2) {
        // 测试数据库连接
        $conn = @mysqli_connect($db_host, $db_user, $db_pass);
        if (!$conn) {
            $error = '数据库连接失败：' . mysqli_connect_error();
        } else {
            // 创建数据库
            mysqli_query($conn, "CREATE DATABASE IF NOT EXISTS `$db_name` DEFAULT CHARSET utf8");
            mysqli_select_db($conn, $db_name);

            // 导入表结构
            $sql = file_get_contents(__DIR__ . '/cloudthink.sql');
            // 提取 CREATE DATABASE 和 USE 语句之后的部分
            $sql = preg_replace('/CREATE DATABASE.*?;/is', '', $sql);
            $sql = preg_replace('/USE.*?;/is', '', $sql);
            $statements = explode(';', $sql);
            $success = true;
            foreach ($statements as $stmt) {
                $stmt = trim($stmt);
                if (!empty($stmt)) {
                    if (!mysqli_query($conn, $stmt)) {
                        $error = 'SQL执行错误：' . mysqli_error($conn) . '<br>SQL: ' . htmlspecialchars($stmt);
                        $success = false;
                        break;
                    }
                }
            }

            if ($success) {
                // 导入示例数据
                $sample = file_get_contents(__DIR__ . '/sample_data.sql');
                $statements = explode(';', $sample);
                foreach ($statements as $stmt) {
                    $stmt = trim($stmt);
                    if (!empty($stmt)) {
                        mysqli_query($conn, $stmt);
                    }
                }

                // 写入配置文件
                $config = "<?php\n"
                    . "\$db_host = '$db_host';\n"
                    . "\$db_user = '$db_user';\n"
                    . "\$db_pass = '$db_pass';\n"
                    . "\$db_name = '$db_name';\n"
                    . "\$conn = mysqli_connect(\$db_host, \$db_user, \$db_pass, \$db_name);\n"
                    . "if (!\$conn) die('数据库连接失败！');\n"
                    . "mysqli_query(\$conn, 'set names utf8');\n"
                    . "session_start();\n";

                $config_admin = "<?php\n"
                    . "\$db_host = '$db_host';\n"
                    . "\$db_user = '$db_user';\n"
                    . "\$db_pass = '$db_pass';\n"
                    . "\$db_name = '$db_name';\n"
                    . "\$conn = mysqli_connect(\$db_host, \$db_user, \$db_pass, \$db_name);\n"
                    . "if (!\$conn) die('数据库连接失败！');\n"
                    . "mysqli_query(\$conn, 'set names utf8');\n"
                    . "session_start();\n"
                    . "if (!isset(\$_SESSION['admin'])) {\n"
                    . "    echo \"<script>alert('请先登录！');window.location.href='index.php';</script>\";\n"
                    . "    exit;\n"
                    . "}\n";

                file_put_contents(__DIR__ . '/config.php', $config);
                file_put_contents(__DIR__ . '/admin/config.php', $config_admin);

                // 修改 db.php 引用 config.php
                $db_content = "<?php\nrequire_once __DIR__ . '/config.php';\n";
                file_put_contents(__DIR__ . '/db.php', $db_content);
                $db_admin_content = "<?php\nrequire_once __DIR__ . '/config.php';\n";
                file_put_contents(__DIR__ . '/admin/db.php', $db_admin_content);

                $step = 3;
            }
            mysqli_close($conn);
        }
    }
}

// 检测第一步
if ($step == 1) {
    $has_php = function_exists('phpversion');
    $has_mysqli = extension_loaded('mysqli');
    $php_ver = phpversion();
    ?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>云创科技 - 安装向导</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:"Microsoft YaHei",sans-serif;background:#f0f2f5;display:flex;justify-content:center;padding:60px 20px}
.wizard{background:#fff;border-radius:12px;box-shadow:0 2px 20px rgba(0,0,0,0.08);max-width:600px;width:100%;overflow:hidden}
.header{background:linear-gradient(135deg,#1a4a73,#2c6b9e);color:#fff;padding:30px;text-align:center}
.header h1{font-size:22px;margin-bottom:6px}
.header p{font-size:13px;opacity:.8}
.body{padding:30px}
.step{display:flex;margin-bottom:25px}
.step-num{width:32px;height:32px;border-radius:50%;background:#2c6b9e;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:14px;margin-right:12px;flex-shrink:0}
.step-num.done{background:#27ae60}
.step-num.active{background:#2c6b9e;box-shadow:0 0 0 4px rgba(44,107,158,0.2)}
.step-content h3{font-size:16px;margin-bottom:4px}
.step-content p{font-size:13px;color:#888}
.status{display:flex;align-items:center;padding:12px 16px;border-radius:8px;margin-bottom:12px;font-size:14px}
.status.ok{background:#eafaf1;color:#27ae60;border:1px solid #d5f5e3}
.status.fail{background:#fdedec;color:#e74c3c;border:1px solid #fadbd8}
.status .icon{font-size:18px;margin-right:10px}
.btn{display:inline-block;padding:12px 30px;background:#2c6b9e;color:#fff;border:none;border-radius:6px;font-size:15px;cursor:pointer;text-decoration:none}
.btn:hover{background:#1a4a73}
.btn:disabled{background:#b0cce5;cursor:not-allowed}
.center{text-align:center;margin-top:20px}
.form-group{margin-bottom:16px}
.form-group label{display:block;margin-bottom:5px;font-size:14px;color:#555;font-weight:bold}
.form-group input{width:100%;padding:10px 14px;border:1px solid #ddd;border-radius:6px;font-size:14px}
.form-group input:focus{border-color:#2c6b9e;outline:none;box-shadow:0 0 0 3px rgba(44,107,158,0.1)}
.error{background:#fdedec;color:#e74c3c;padding:12px 16px;border-radius:6px;margin-bottom:16px;font-size:14px}
.success{background:#eafaf1;color:#27ae60;padding:30px;border-radius:8px;text-align:center}
.success h2{font-size:20px;margin-bottom:12px}
.success p{margin-bottom:8px;font-size:14px}
.success .links{margin-top:20px}
.success .links a{display:inline-block;margin:0 8px;padding:10px 24px;background:#2c6b9e;color:#fff;border-radius:6px;text-decoration:none;font-size:14px}
.success .links a:hover{background:#1a4a73}
</style>
</head>
<body>
<div class="wizard">
<div class="header">
<h1>云创科技企业网站 - 安装向导</h1>
<p>只需两步即可完成部署</p>
</div>
<div class="body">
<div style="margin-bottom:25px;">
<div class="step">
<div class="step-num active">1</div>
<div class="step-content"><h3>环境检测</h3><p>检测 PHP 和 MySQL 扩展</p></div>
</div>
<div class="status <?=$has_php?'ok':'fail'?>">
<span class="icon"><?=$has_php?'&#10003;':'&#10007;'?></span>
PHP <?=$has_php?'v'.htmlspecialchars($php_ver).' 已就绪':'未检测到 PHP'?>
</div>
<div class="status <?=$has_mysqli?'ok':'fail'?>">
<span class="icon"><?=$has_mysqli?'&#10003;':'&#10007;'?></span>
MySQLi 扩展 <?=$has_mysqli?'已加载':'未加载，请安装 php-mysqli 扩展'?>
</div>
<?php if ($has_php && $has_mysqli): ?>
<div class="center"><a href="?step=2" class="btn">下一步 - 配置数据库</a></div>
<?php else: ?>
<div class="center"><a href="?" class="btn" style="background:#999;">重新检测</a></div>
<?php endif; ?>
</div>
</div>
</div>
</body>
</html>
<?php
    exit;
}

if ($step == 2) {
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>云创科技 - 配置数据库</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:"Microsoft YaHei",sans-serif;background:#f0f2f5;display:flex;justify-content:center;padding:60px 20px}
.wizard{background:#fff;border-radius:12px;box-shadow:0 2px 20px rgba(0,0,0,0.08);max-width:600px;width:100%;overflow:hidden}
.header{background:linear-gradient(135deg,#1a4a73,#2c6b9e);color:#fff;padding:30px;text-align:center}
.header h1{font-size:22px;margin-bottom:6px}
.body{padding:30px}
.step{display:flex;margin-bottom:25px}
.step-num{width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:14px;margin-right:12px;flex-shrink:0}
.step-num.done{background:#27ae60;color:#fff}
.step-num.active{background:#2c6b9e;color:#fff;box-shadow:0 0 0 4px rgba(44,107,158,0.2)}
.step-content h3{font-size:16px;margin-bottom:4px}
.step-content p{font-size:13px;color:#888}
.form-group{margin-bottom:16px}
.form-group label{display:block;margin-bottom:5px;font-size:14px;color:#555;font-weight:bold}
.form-group input{width:100%;padding:10px 14px;border:1px solid #ddd;border-radius:6px;font-size:14px}
.form-group input:focus{border-color:#2c6b9e;outline:none;box-shadow:0 0 0 3px rgba(44,107,158,0.1)}
.btn{display:inline-block;padding:12px 30px;background:#2c6b9e;color:#fff;border:none;border-radius:6px;font-size:15px;cursor:pointer;text-decoration:none}
.btn:hover{background:#1a4a73}
.center{text-align:center;margin-top:20px}
.error{background:#fdedec;color:#e74c3c;padding:12px 16px;border-radius:6px;margin-bottom:16px;font-size:14px}
.hint{font-size:12px;color:#999;margin-top:4px}
</style>
</head>
<body>
<div class="wizard">
<div class="header">
<h1>配置数据库连接</h1>
<p>请输入你的 MySQL 数据库信息</p>
</div>
<div class="body">
<div class="step">
<div class="step-num done">1</div>
<div class="step-content"><h3>环境检测</h3><p>已完成</p></div>
</div>
<div class="step">
<div class="step-num active">2</div>
<div class="step-content"><h3>数据库配置</h3><p>填写 MySQL 连接信息</p></div>
</div>

<?php if ($error): ?>
<div class="error"><?=htmlspecialchars($error)?></div>
<?php endif; ?>

<form method="post">
<div class="form-group">
<label>数据库地址</label>
<input name="db_host" value="127.0.0.1" placeholder="默认 127.0.0.1">
</div>
<div class="form-group">
<label>数据库用户名</label>
<input name="db_user" value="root" placeholder="默认 root">
</div>
<div class="form-group">
<label>数据库密码</label>
<input type="password" name="db_pass" value="" placeholder="输入 MySQL 密码，无密码留空">
<div class="hint">XAMPP 默认密码为空，phpStudy 默认密码为 root 或 123456</div>
</div>
<div class="form-group">
<label>数据库名称</label>
<input name="db_name" value="cloudthink" placeholder="将自动创建，默认 cloudthink">
</div>
<div class="center">
<button type="submit" class="btn">开始安装</button>
</div>
</form>
</div>
</div>
</body>
</html>
<?php
    exit;
}

if ($step == 3) {
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>安装完成 - 云创科技</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:"Microsoft YaHei",sans-serif;background:#f0f2f5;display:flex;justify-content:center;padding:60px 20px}
.wizard{background:#fff;border-radius:12px;box-shadow:0 2px 20px rgba(0,0,0,0.08);max-width:600px;width:100%;overflow:hidden}
.header{background:linear-gradient(135deg,#27ae60,#2ecc71);color:#fff;padding:30px;text-align:center}
.header h1{font-size:22px;margin-bottom:6px}
.body{padding:30px;text-align:center}
.icon-big{font-size:64px;margin-bottom:16px}
h2{font-size:20px;margin-bottom:12px;color:#333}
.info{background:#f8f9fa;border-radius:8px;padding:16px;text-align:left;margin:20px 0;font-size:14px}
.info p{margin-bottom:6px}
.info strong{color:#555}
.links{margin-top:20px}
.links a{display:inline-block;margin:0 8px 10px;padding:12px 30px;border-radius:6px;font-size:15px;text-decoration:none}
.btn-primary{background:#2c6b9e;color:#fff}
.btn-primary:hover{background:#1a4a73}
.btn-secondary{background:#eee;color:#333}
.btn-secondary:hover{background:#ddd}
</style>
</head>
<body>
<div class="wizard">
<div class="header">
<h1>&#10003; 安装成功！</h1>
<p>云创科技企业网站已部署完成</p>
</div>
<div class="body">
<div class="icon-big">&#127881;</div>
<h2>欢迎使用云创科技企业网站</h2>
<div class="info">
<p><strong>前台地址：</strong><a href="<?php echo 'http://'.$_SERVER['HTTP_HOST'];?>/"><?php echo 'http://'.$_SERVER['HTTP_HOST'];?>/</a></p>
<p><strong>后台地址：</strong><a href="<?php echo 'http://'.$_SERVER['HTTP_HOST'];?>/admin/"><?php echo 'http://'.$_SERVER['HTTP_HOST'];?>/admin/</a></p>
<p><strong>管理员账号：</strong>admin</p>
<p><strong>管理员密码：</strong>admin123</p>
</div>
<p style="color:#888;font-size:13px;">请删除 install.php 文件以确保安全</p>
<div class="links">
<a href="<?php echo 'http://'.$_SERVER['HTTP_HOST'];?>/" class="btn-primary">访问前台</a>
<a href="<?php echo 'http://'.$_SERVER['HTTP_HOST'];?>/admin/" class="btn-primary">进入后台</a>
</div>
</div>
</div>
</body>
</html>
<?php
}

# 云创科技企业网站

## 一键部署

### 🐳 方案一：Docker（推荐）

```bash
# 进入项目目录
cd biyesheji-he-biyelunwen
# 双击 setup.bat (Windows) 或运行：
docker compose up -d
```

> 脚本会自动安装 Docker（如果没有的话），然后自动部署。

### 🚀 方案二：手动 Docker 部署

```bash
git clone https://github.com/lih257181-pixel/biyesheji-he-biyelunwen.git
cd biyesheji-he-biyelunwen
docker compose up -d
```

### 🪟 方案三：Windows 本地运行（已装 PHP）

```bash
# 启动 PHP 内置服务器
curl -sSL https://github.com/lih257181-pixel/biyesheji-he-biyelunwen/archive/refs/heads/master.zip -o site.zip
# 解压后进入目录，双击 start.bat 或运行：
php -S 0.0.0.0:8080
```

## 访问地址

| 页面 | 地址 |
|------|------|
| 🌐 前台首页 | http://localhost:8080/ |
| 🔧 后台管理 | http://localhost:8080/admin/ |
| 📦 在线安装向导 | http://localhost:8080/install.php |

## 默认账号

- **管理员：** `admin` / `admin123`
- **普通用户：** 注册即可

## 技术栈

- PHP 7.4 + MySQL 5.7
- Apache + Docker Compose
- HTML / CSS / JavaScript

## 项目结构

```
cloudthink/
├── index.php          # 前台首页
├── about.php          # 企业简介
├── products.php       # 产品中心
├── news.php           # 新闻动态
├── message.php        # 客户留言
├── order.php          # 在线订购
├── login.php / reg.php # 登录注册
├── admin/             # 后台管理
│   ├── index.php      # 管理员登录
│   ├── dashboard.php  # 管理首页
│   ├── products.php   # 产品管理
│   ├── news.php       # 新闻管理
│   ├── messages.php   # 留言管理
│   ├── orders.php     # 订单管理
│   └── users.php      # 用户管理
├── Dockerfile         # Docker 构建文件
├── docker-compose.yml # Docker 编排文件
├── setup.sh           # Linux/Mac 一键部署
├── setup.bat          # Windows 一键部署
└── install.php        # 在线安装向导
```

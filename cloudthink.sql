CREATE DATABASE IF NOT EXISTS cloudthink DEFAULT CHARSET utf8;
USE cloudthink;

CREATE TABLE admin (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(50) NOT NULL,
  create_time DATETIME DEFAULT NOW()
) DEFAULT CHARSET utf8;

INSERT INTO admin (username, password) VALUES ('admin', 'admin123');

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(50) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  create_time DATETIME DEFAULT NOW()
) DEFAULT CHARSET utf8;

CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  category VARCHAR(50),
  price DECIMAL(10,2),
  image VARCHAR(200),
  description TEXT,
  create_time DATETIME DEFAULT NOW()
) DEFAULT CHARSET utf8;

CREATE TABLE news (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  content TEXT,
  image VARCHAR(200),
  create_time DATETIME DEFAULT NOW()
) DEFAULT CHARSET utf8;

CREATE TABLE messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  phone VARCHAR(20),
  content TEXT NOT NULL,
  reply TEXT,
  create_time DATETIME DEFAULT NOW()
) DEFAULT CHARSET utf8;

CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  product_id INT,
  quantity INT DEFAULT 1,
  contact_name VARCHAR(50),
  contact_phone VARCHAR(20),
  address VARCHAR(500),
  note TEXT,
  status VARCHAR(20) DEFAULT '待处理',
  create_time DATETIME DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
) DEFAULT CHARSET utf8;

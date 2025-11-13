-- 創建資料庫
CREATE DATABASE IF NOT EXISTS happy_pet CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE happy_pet;

-- 使用者表
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type ENUM('owner', 'caretaker', 'admin') DEFAULT 'owner',
    full_name VARCHAR(100),
    phone VARCHAR(20),
    location VARCHAR(100),
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 寵物種類表
CREATE TABLE IF NOT EXISTS pet_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 寵物表
CREATE TABLE IF NOT EXISTS pets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    owner_id INT NOT NULL,
    pet_type_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    breed VARCHAR(50),
    age INT,
    gender ENUM('male', 'female', 'unknown'),
    description TEXT,
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id),
    FOREIGN KEY (pet_type_id) REFERENCES pet_types(id)
);

-- 案件類型表
CREATE TABLE IF NOT EXISTS case_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 案件表
CREATE TABLE IF NOT EXISTS cases (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    detailed_description TEXT,
    case_type_id INT NOT NULL,
    pet_id INT,
    location VARCHAR(200) NOT NULL,
    contact_info VARCHAR(200),
    urgency_level ENUM('low', 'medium', 'high', 'emergency') DEFAULT 'medium',
    budget DECIMAL(10,2),
    is_urgent BOOLEAN DEFAULT FALSE,
    status ENUM('open', 'in_progress', 'completed', 'cancelled') DEFAULT 'open',
    view_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL,
    assigned_to INT,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (case_type_id) REFERENCES case_types(id),
    FOREIGN KEY (pet_id) REFERENCES pets(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id)
);

-- 案件照片表
CREATE TABLE IF NOT EXISTS case_photos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    case_id INT NOT NULL,
    photo_url VARCHAR(255) NOT NULL,
    description TEXT,
    uploaded_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(id),
    FOREIGN KEY (uploaded_by) REFERENCES users(id)
);

-- 常見問題表
CREATE TABLE IF NOT EXISTS faqs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category VARCHAR(50),
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 案件評價表
CREATE TABLE IF NOT EXISTS case_reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    case_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_case_user (case_id, user_id)
);

-- 案件詳情照片表（支援多張照片）
CREATE TABLE IF NOT EXISTS case_detail_photos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    case_id INT NOT NULL,
    photo_url VARCHAR(255) NOT NULL,
    display_order INT DEFAULT 0,
    description TEXT,
    uploaded_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id)
);

-- 聊天会话表
CREATE TABLE IF NOT EXISTS chat_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    case_id INT NOT NULL,
    participant1_id INT NOT NULL, -- 饲主/案件创建者
    participant2_id INT NOT NULL, -- 照顾者/接案者
    status ENUM('active', 'closed', 'archived') DEFAULT 'active',
    last_message_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (case_id) REFERENCES cases(id),
    FOREIGN KEY (participant1_id) REFERENCES users(id),
    FOREIGN KEY (participant2_id) REFERENCES users(id),
    UNIQUE KEY unique_case_participants (case_id, participant1_id, participant2_id)
);

-- 聊天消息表
CREATE TABLE IF NOT EXISTS chat_messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT NOT NULL,
    sender_id INT NOT NULL,
    message_type ENUM('text', 'image', 'file', 'system') DEFAULT 'text',
    message_text TEXT,
    file_url VARCHAR(500),
    file_name VARCHAR(255),
    file_size INT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES chat_sessions(id),
    FOREIGN KEY (sender_id) REFERENCES users(id),
    INDEX idx_session_created (session_id, created_at),
    INDEX idx_sender_read (sender_id, is_read)
);

-- 会话参与者最后阅读时间
CREATE TABLE IF NOT EXISTS chat_participants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    last_read_at TIMESTAMP NULL,
    is_muted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES chat_sessions(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY unique_session_user (session_id, user_id)
);

-- 在线状态表
CREATE TABLE IF NOT EXISTS user_online_status (
    user_id INT PRIMARY KEY,
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    socket_id VARCHAR(100),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
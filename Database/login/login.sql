CREATE TABLE mst_users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE NOT NULL,
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    is_deleted TINYINT(1) DEFAULT 0,
    deleted_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_logins (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NULL,
    last_login TIMESTAMP NULL,
    last_logout TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES mst_users(user_id) ON DELETE CASCADE
);

CREATE TABLE ref_sso_providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_name VARCHAR(50) NOT NULL,
    auth_url VARCHAR(255) NOT NULL
);

CREATE TABLE user_sso_logins (
    auth_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    provider_id INT NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    token TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users_logins(user_id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES ref_sso_providers(provider_id) ON DELETE CASCADE
);

# Database Design Documentation: Login System with SSO&#x20;
![alt text](https://github.com/MarioAPasama/my_notes/blob/main/Database/login/logindatabase.png?raw=true)
## **📌 Overview**

This document describes the database design for a user authentication system that supports:

- Traditional login with username & password.
- Single Sign-On (SSO) authentication.
- Soft delete mechanism to track and restore user accounts.

## **📁 Database Tables & Relationships**

### **1️⃣ ********************`mst_users`******************** (Master Users - Personal Data)**

Stores personal user information separately from authentication data.

#### **Columns:**

| Column Name   | Data Type              | Description                           |
| ------------- | ---------------------- | ------------------------------------- |
| `mst_user_id` | INT (PK, AI)           | Unique user ID                        |
| `full_name`   | VARCHAR(100)           | User's full name                      |
| `phone`       | VARCHAR(15)            | Contact phone number                  |
| `email`       | VARCHAR(100) [UNIQUE]  | User's email address                  |
| `status`      | ENUM('active', 'inactive', 'suspended') [DEFAULT 'active']  | Status User                  |
| `is_deleted`  | TINYINT(1) [DEFAULT 0] | Soft delete flag (1 = deleted)        |
| `deleted_at`  | TIMESTAMP (nullable)   | Timestamp when the record was deleted |
| `updated_at`  | TIMESTAMP              | Last update timestamp                 |
| `created_at`  | TIMESTAMP              | Record creation timestamp             |

### **2️⃣ ********************`users_logins`******************** (User Login Data)**

Stores authentication credentials separately from personal data.

#### **Columns:**

| Column Name   | Data Type                              | Description               |
| ------------- | -------------------------------------- | ------------------------- |
| `mst_user_id` | INT (PK, FK → `mst_users.mst_user_id`) | User ID reference         |
| `username`    | VARCHAR(50) [UNIQUE]                   | Login username            |
| `password`    | VARCHAR(255) (nullable)                | Encrypted user password   |
| `last_login`  | TIMESTAMP (nullable)                   | Last login timestamp      |
| `last_logout` | TIMESTAMP (nullable)                   | Last logout timestamp     |
| `updated_at`  | TIMESTAMP                              | Last update timestamp     |
| `created_at`  | TIMESTAMP                              | Record creation timestamp |

### **3️⃣ ********************`ref_sso_providers`******************** (SSO Providers)**

Stores reference data for supported SSO authentication providers.

#### **Columns:**

| Column Name     | Data Type    | Description                 |
| --------------- | ------------ | --------------------------- |
| `provider_id`   | INT (PK, AI) | Unique provider ID          |
| `provider_name` | VARCHAR(50)  | Name of the SSO provider    |
| `auth_url`      | VARCHAR(255) | Authentication endpoint URL |

### **4️⃣ ********************`user_sso_logins`******************** (SSO User Mapping)**

Maps users to their respective SSO providers.

#### **Columns:**

| Column Name        | Data Type                                  | Description                               |
| ------------------ | ------------------------------------------ | ----------------------------------------- |
| `auth_id`          | INT (PK, AI)                               | Unique authentication mapping ID          |
| `mst_user_id`      | INT (FK → `users_logins.mst_user_id`)      | User ID reference                         |
| `provider_id`      | INT (FK → `ref_sso_providers.provider_id`) | SSO provider reference                    |
| `provider_user_id` | VARCHAR(255)                               | User ID from the SSO provider             |
| `token`            | TEXT                                       | Authentication token                      |
| `updated_at`       | TIMESTAMP                                  | Last update timestamp (for token updates) |
| `created_at`       | TIMESTAMP                                  | Record creation timestamp                 |

## **🔗 Relationships**

- **One-to-One:** `mst_users` ↔ `users_logins` (Each user has one login record)
- **One-to-Many:** `users_logins` ↔ `user_sso_logins` (One user can have multiple SSO logins)
- **One-to-Many:** `ref_sso_providers` ↔ `user_sso_logins` (One provider can be used by multiple users)

## **📌 Soft Delete Mechanism**

### **How Soft Delete Works:**

1. **Mark user as deleted:**
   ```sql
   UPDATE mst_users
   SET is_deleted = 1, deleted_at = NOW()
   WHERE mst_user_id = 123;
   ```
2. **Filter only active users:**
   ```sql
   SELECT * FROM mst_users WHERE is_deleted = 0;
   ```
3. **Restore deleted user:**
   ```sql
   UPDATE mst_users
   SET is_deleted = 0, deleted_at = NULL
   WHERE mst_user_id = 123;
   ```
4. **Permanently delete users marked as deleted:**
   ```sql
   DELETE FROM mst_users WHERE is_deleted = 1;
   ```

## **📌 SSO Authentication Flow**

1. User initiates login with an SSO provider.
2. System redirects user to the SSO provider’s authentication page.
3. User authenticates and provider sends back an authorization token.
4. System verifies the token and maps the user using `provider_user_id`.
5. If the user exists, they are logged in; otherwise, a new user record is created.
6. Token is stored in `user_sso_logins` for future authentication.

## **📌 Advantages of This Design**

✅ **Separation of Concerns** → Personal data (`mst_users`) is separated from login data (`users_logins`).
✅ **Flexible Authentication** → Supports both traditional login & SSO authentication.
✅ **Soft Delete** → Allows restoring deleted accounts and prevents accidental deletions.
✅ **Optimized Queries** → Using `is_deleted` for fast lookups and `deleted_at` for auditing.
✅ **Scalability** → Supports multiple SSO providers per user.

## **📌 Future Enhancements**

🔹 Add `login_attempts` tracking to prevent brute-force attacks.\
🔹 Store refresh tokens separately for SSO providers.\
🔹 Implement multi-factor authentication (MFA) for better security.

---

📌 **Author:** *Mario*\
📆 **Last Updated:** 2025*-02-06*\
🚀 **Version:** *1.0*


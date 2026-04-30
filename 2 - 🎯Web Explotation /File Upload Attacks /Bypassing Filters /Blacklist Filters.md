


# File Upload Attacks - Blacklist Filters

## 🚫 Blacklist Filters
In this scenario, validation exists on the backend, but it is poorly implemented. Blocking only specific extensions is not real security, as it is a reactive approach that is almost always incomplete.

---

## 🧠 How It Works
Typical implementation:

$blacklist = array('php', 'php7', 'phps');

The server blocks only specific extensions. If an extension is not in that list, the file is accepted.

---

## 🚀 Bypass Techniques

### 1. 🔤 Case Variation
If the validation is case-sensitive (common in poorly coded PHP), you can change the casing to bypass the check.
- **Bypass examples:**
  - `shell.pHp`
  - `shell.PhP`
  - `shell.PHP`
⚠️ *Note: This is especially effective on Windows-based servers which are case-insensitive.*

### 2. 🧪 Extension Fuzzing
The professional approach is to use wordlists and automated tools like **Burp Intruder** or **ffuf**.
- **Payloads:** Use SecLists or PayloadsAllTheThings.
- **Burp Setup:** Set the payload position on the extension: `filename="shell.§EXT§"`.

### 3. 💥 Alternative Extensions
PHP and other languages can often execute using multiple, less common extensions:
- **PHP:** `.phtml`, `.php5`, `.php8`, `.phar`, `.inc`
- **ASP.NET:** `.aspx`, `.ashx`, `.config`
- **Successful Example:** Uploading `shell.phtml` often bypasses filters while still providing RCE.

---

## 🎯 Execution
Once the bypass is successful:
URL: `http://SERVER/profile_images/shell.phtml?cmd=id`
➡️ **Remote Code Execution (RCE)**

---

## 🔥 Why It Works
The server:
1. Relies ONLY on extension checks.
2. Does not validate file content or "Magic Bytes".
3. Does not use a strict Whitelist.

---

## ⚠️ Common Mistakes in Defense
- Missing dangerous extensions in the list.
- Case-sensitive filtering logic.
- No MIME validation.
- No protection against polyglot files.

---

## 🛡️ Secure Implementation
A secure system should never use a Blacklist. Instead:
- **Use a Whitelist:** Only allow `.jpg`, `.png`, `.pdf`.
- **Validate Everything:** Check Extension, MIME type, and Magic Bytes.
- **Rename Files:** Use random strings for filenames.
- **Disable Execution:** Use `.htaccess` or server config to disable script execution in upload directories.

---

## 💣 Key Summary
1. Blacklist = Easy to bypass.
2. Fuzz extensions to find the "hole" in the list.
3. Upload shell with the allowed variant.
4. Achieve RCE.

---

## 🧠 Pentester Mindset
- If something is blocked ➡️ Look for variations.
- If one extension fails ➡️ Try another.
- Always assume the blacklist is incomplete.


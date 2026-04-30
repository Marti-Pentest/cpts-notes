
# File Upload Attacks - Whitelist Filters

## ✅ Whitelist Filters
In this approach, the system only allows specific file types. While theoretically more secure than a blacklist, a misconfiguration or poor implementation leads to critical vulnerabilities.

---

## 🧠 Vulnerable Example (The Regex Trap)
Many developers use weak Regular Expressions (Regex) to validate filenames:
´´´php
if (!preg_match('/^.*\.(jpg|jpeg|png|gif)/', $fileName)) {
    echo "Only images are allowed";
}
´´´
⚠️ **Core Issue:** This checks if the string *contains* `.jpg`, but it does NOT ensure the file *ends* with `.jpg`. It is a partial match instead of strict validation.

---

## 🚀 Bypass Techniques

### 1. 💥 Double Extension
`shell.jpg.php`
- ✔️ **Validation:** Contains `.jpg` ➡️ passes the weak whitelist.
- ✔️ **Execution:** Ends with `.php` ➡️ the server executes it as a script.
- **Result:** `http://SERVER/uploads/shell.jpg.php?cmd=id` ➡️ **RCE**.

### 2. 🔁 Reverse Double Extension (Apache/Nginx Misconfig)
Sometimes servers are configured to execute any file that *contains* the extension:
`shell.php.jpg`
- ✔️ **Validation:** Ends with `.jpg` ➡️ passes strict extension checks.
- ⚠️ **Problem:** If the server config (like `FilesMatch`) lacks the `$` anchor, it will still execute the `.php` part.

### 3. 🧬 Character Injection
Injecting special characters to break the backend's string handling.
- **Null Byte (%00):** `shell.php%00.jpg` ➡️ Older PHP versions stop reading at the null byte, saving it as `shell.php`.
- **New Line (%0a):** `shell.php%0a.jpg`
- **Windows Data Streams:** `shell.aspx:.jpg` ➡️ Stored as `shell.aspx`.

### 4. 🧪 Advanced Fuzzing
Automating the search for the right combination:
```bash
for char in '%00' '%0a' '/' '.' ':'; do
  echo "shell${char}.php.jpg"
done
```
👉 Use **Burp Intruder** to test these variations and identify which ones bypass the filter and still execute.

---

## ⚠️ Regex Validation Issues
- ❌ **Incorrect:** `^.*\.(jpg|png)` ➡️ Matches any filename starting with these or containing them.
- ✔️ **Correct:** `^.*\.(jpg|png)$` ➡️ The `$` anchor ensures the string MUST end with the allowed extension.

---

## 🔥 Why It Works
1. The system confuses the filename string with the actual file type.
2. Weak Regex validation (missing anchors).
3. The server trusts superficial metadata.

---

## 🛡️ Secure Implementation
A secure backend must:
- **Strict Whitelist:** Use `$`: `/^.*\.(jpg|png)$|i`.
- **Content Validation:** Check "Magic Bytes" (file signatures).
- **MIME Validation:** Verify the `Content-Type` header (though this can be spoofed).
- **Rename Files:** Force a new name like `upload_592.jpg`.
- **Non-Executable Storage:** Save files in directories where script execution is disabled.

---

## 💣 Key Summary
1. Whitelist is only safe if it's strict.
2. Use Double Extensions to trick partial matches.
3. Use Character Injection to break file naming logic.
4. If it executes ➡️ Full RCE.

---

## 🧠 Pentester Mindset
- Is the validation checking the *entire* filename?
- Does the server execute based on *partial* matches?
- Can I "hide" my malicious extension inside an allowed one?

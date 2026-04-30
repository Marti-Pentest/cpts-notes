# File Upload Attacks - Introduction

## 📌 Overview

File upload functionality is widely used in modern applications:

- Social platforms → images and videos  
- Business systems → documents (PDF, Excel, etc.)  
- Web apps → avatars, reports, backups  

⚠️ However, it is one of the most critical attack surfaces when not properly secured.

---

## Why Is It Dangerous?

Allowing users to upload files means allowing them to write data on the server.

➡️ User uploads file → potential execution of malicious code  

If not properly validated, this can lead to full system compromise.

---

## 🧨 Common Vulnerabilities

### 1. Arbitrary File Upload

The application allows uploading any type of file without restrictions.

🔥 Impact:
- Remote Code Execution (RCE)
- Full server compromise

### 2. Weak File Validation

Typical issues:

- Only file extension is checked (.jpg)
- No validation of actual content
- MIME type can be spoofed

➡️ Result: filter bypass

### 3. Missing Authentication

Upload functionality accessible to unauthenticated users.

🚨 Impact: high risk exposure

### 4. Vulnerable Libraries

Outdated frameworks or plugins may introduce upload bypasses.

---

## 💥 Real-World Impact

- Remote Code Execution (RCE)  
- Stored XSS  
- XXE  
- Denial of Service (DoS)  
- File overwrite (config.php, .htaccess)  

---

## 🎯 Common Attack Vectors

- Malicious images  
- Weaponized PDFs  
- Hidden scripts  
- Compressed files (ZIP/TAR)  
- SVG with embedded JavaScript  

---

## Why Do These Vulnerabilities Exist?

Common developer mistakes:

- Trusting file extensions  
- Not validating file content  
- Storing files in web root  
- Not sanitizing file names  
- Allowing execution in upload directories  

---

## 🛡️ Secure Implementation (High-Level)

- Strict validation (extension, MIME, magic bytes)  
- Rename uploaded files  
- Store outside web root  
- Disable execution  
- Limit file size  
- Scan files  
- Apply least privilege  

---

## 🧠 Key Takeaway

File Upload ≠ Data Storage  
File Upload = Potential Code Execution  

---

## 📝 Notes

Part of my practical learning while preparing for CPTS.

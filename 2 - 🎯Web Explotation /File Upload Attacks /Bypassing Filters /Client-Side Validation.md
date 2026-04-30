# File Upload Attacks - Bypassing Client-Side Validation

## 🛑 What is Client-Side Validation?
Validation that occurs in the user's browser **before** the file is even sent to the server. Usually implemented via JavaScript or HTML attributes.

---

## 🔍 How to Identify It?
1. **Instant Feedback:** You get an "Invalid File" error immediately after selecting the file, without any network traffic.
2. **HTML Attributes:** Look for `accept=".jpg,.png"` in the `<input>` tag.
3. **Source Code:** Check for JavaScript functions like `validateFile()` or `checkExtension()` triggered on the `onsubmit` event.

---

## 🛠️ Bypass Techniques

### 1. Intercept and Modify (The Burp Suite Method)
This is the most reliable way as it bypasses the browser's logic entirely.
1. Rename your malicious file to a "safe" name (e.g., `shell.php` -> `shell.jpg`).
2. Prepare your upload in the browser and turn on **Interception** in Burp Suite.
3. Hit **Upload**.
4. In Burp, locate the `filename="shell.jpg"` part of the POST request.
5. Change it back to `filename="shell.php"`.
6. Forward the request.

### 2. Disable JavaScript
If the validation is purely JS-based:
- Disable JavaScript in your browser settings or via DevTools (F12 -> Debugger -> Disable JS).
- Some sites may break, but the upload form might still function without the "check".

### 3. Modify the Page Source (DOM Manipulation)
1. Open DevTools (F12).
2. Find the `<input>` tag.
3. Remove the `accept` attribute or any `onsubmit` triggers.
4. Upload your file directly.

---

## ⚙️ Attack Workflow
1. **Prepare:** Have your `.php` shell ready.
2. **Rename:** `shell.php` ➡️ `shell.png`
3. **Capture:** Catch the request in Burp Suite.
4. **Manipulate:** Change the filename extension back to `.php` in the raw HTTP body.
5. **Verify:** Check if the file was saved as a script on the server.

---

## 💡 Why this works
Developers often trust the client to "clean" the data. However, **any validation happening on the client can be bypassed** because the user has full control over the browser and the data being sent.

---

## 💥 Impact
Once bypassed, you return to the **Basic Exploitation** stage:
- Remote Code Execution (RCE).
- Web Shell access.
- System takeover.

---

## 🧠 Pentester Note
Always check if there is a **Server-Side** validation following the client-side one. If the server only checks the MIME-type or uses Blacklists, you'll need further bypassing techniques.

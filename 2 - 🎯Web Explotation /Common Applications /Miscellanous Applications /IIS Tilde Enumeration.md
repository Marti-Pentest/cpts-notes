
## 🧠 Overview: The 8.3 Legacy

Internet Information Services (IIS) legacy support for **8.3 Short File Names** allows attackers to uncover files and folders that are otherwise hidden or protected. When Windows creates a file with a long name (e.g., `SecretDocuments`), it automatically creates a short alias for compatibility: `SECRET~1`.

➡️ **The Vulnerability:** By sending specially crafted HTTP requests using the tilde (`~`) character, an attacker can brute-force the existence of files and directories character by character, even if they don't know the full name.

---

## 🔍 Identification & Enumeration

### 🧪 Manual Concept (The Tilde Method)

The attack relies on the server responding differently when a short name prefix exists versus when it doesn't.

* **Request:** `GET /a~1* /index.aspx`
* **Response 404:** The character 'a' is not the start of any short name.
* **Response 200/403:** A file or folder starting with 'a' exists.

### 🧪 Automated Scanning (IIS-ShortName-Scanner)

Manual enumeration is tedious. The `iis_shortname_scanner` is the industry standard tool to automate this "binary search" of characters.

```bash
# Running the scanner
java -jar iis_shortname_scanner.jar 0 5 http://TARGET_IP/

```

**Output Example:**

```text
[+] The target is vulnerable.
[+] Directories found:  6
    - SECRE~1
    - TRANSF~1
[+] Files found: 2
    - BACKUP~1.ZIP

```

---

## 🚀 From Enumeration to Access

Once you have the short name (e.g., `TRANSF~1`), you need to reconstruct the full name or find accessible files within it.

### 1. Brute Forcing the Full Name

If you know the directory starts with `transf`, you can create a targeted wordlist to find the actual folder name.

```bash
# Create a targeted wordlist from system dictionaries
grep -r "^transf" /usr/share/wordlists/dirb/*.txt | cut -d ":" -f 2 > /tmp/target_list.txt

# Use Gobuster to find the real directory
gobuster dir -u http://TARGET_IP/ -w /tmp/target_list.txt -x .aspx,.asp,.php

```

### 2. Direct File Access

Sometimes you can access the files directly using the short name if the application logic allows it:

* `http://target.com/SECRE~1/config.xml`
* `http://target.com/backup~1.zip`

---

## 🛠️ Summary of Impact

| Feature | Risk |
| --- | --- |
| **Information Disclosure** | Discovering hidden backup files (`web~1.con` for `web.config.bak`). |
| **WAF Bypass** | Some WAFs filter `SecretDocuments` but allow `SECRE~1`. |
| **Service Discovery** | Finding hidden administrative panels or API endpoints. |

---

## 🛡️ Defensive Measures (Remediation)

1. **Disable 8.3 Name Creation:** Edit the Windows Registry:
`HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\NtfsDisable8dot3NameCreation` set to `1`.
2. **Remove Existing Short Names:** Use the `fsutil` command to strip existing 8.3 names from the drive:
`fsutil 8dot3name strip /s C:\inetpub\wwwroot`
3. **Web.config:** Ensure IIS is configured to reject requests containing the `~` character if not required.

---

## 💣 Pentester Mindset

* **The "Index" Increment:** If `SECRET~1` exists, always check for `SECRET~2`. There might be multiple folders with the same prefix.
* **File Extensions:** Don't forget that extensions also get shortened. `.aspx` might be `.ASP` or `.AS~1`.
* **Combination with LFI:** If you have a Local File Inclusion vulnerability, using short names can bypass filters that look for long, sensitive filenames.


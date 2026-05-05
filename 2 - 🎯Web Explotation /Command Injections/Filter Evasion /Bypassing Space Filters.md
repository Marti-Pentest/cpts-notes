
# OS Command Injection - Operators & Space Bypass

## 🧠 Overview
When basic command injection operators (like `;`) or space characters are blacklisted, we must leverage the shell's alternative syntax. Modern shells provide multiple ways to define commands and arguments, which simple filters often miss.

---

## 🚫 Bypassing Blacklisted Operators

### 🔹 New Line Injection (%0a)
Filters often block semicolons (`;`) or pipes (`|`), but overlook the newline character. A newline is effectively a command terminator in almost every shell.

- **Payload:** `127.0.0.1%0awhoami`
- **Why:** The server processes this as:
  ```bash
  original_command 127.0.0.1
  whoami
  ```

---

## 🚫 Bypassing Blacklisted Spaces
If the filter blocks the ASCII space character (`%20`), we can replace it with shell-compatible alternatives.

### 1. Internal Field Separator ($IFS)
The `$IFS` variable in Linux defaults to space, tab, and newline.
- **Payload:** `127.0.0.1%0a${IFS}whoami`
- **Pro Tip:** If `${IFS}` is blocked, try `${IFS:0:1}` to extract just the space.

### 2. Tab Characters (%09)
Most shells interpret a Tab (`%09`) exactly like a space character.
- **Payload:** `127.0.0.1%0a%09whoami`

### 3. Brace Expansion
Bash can execute commands without spaces by using braces to group arguments.
- **Syntax:** `{ls,-la}`
- **Injection:** `127.0.0.1%0a{ls,-la}`
- **Note:** The comma is mandatory here; it replaces the space separator.

---

## 🛠️ Summary Reference Table

| Goal | Technique | Payload Example |
| :--- | :--- | :--- |
| **New Command** | New Line | `%0a` |
| **Space Bypass** | Tab | `%09` |
| **Space Bypass** | `$IFS` variable | `${IFS}` |
| **Space Bypass** | Brace Expansion | `{cmd,arg}` |

---

## 🧠 Pentester Mindset
* **The "Environment" is the Key.** Don't just fight the filter—look for features of the underlying shell (bash, sh, powershell) that the filter developer forgot existed.
* **Always test multiple separators.** A filter might block ` ` (space) but ignore `\t` (tab).
* **Automate the discovery.** If one separator is blocked, move immediately to the next in your list. Never spend time trying to "fix" a blocked payload when you can simply "swap" the syntax.

---

## 📚 Further Reading
- [Bash Brace Expansion Documentation](https://www.gnu.org/software/bash/manual/html_node/Brace-Expansion.html)
- [How Shell Interpreters Parse Arguments](https://pubs.opengroup.org/onlineggroup/9699919799/utilities/V3_chap02.html)


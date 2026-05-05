# OS Command Injection - Character & Pattern Bypass

## 🧠 Overview
When security filters block specific strings (e.g., `whoami`), we can bypass them by "breaking" the command pattern. The shell will re-assemble these parts into a valid command before execution.

---

## 🔤 Breaking Patterns (Obfuscation)

### 1. Quoting (Linux & Windows)
The shell ignores quotes used in the middle of a command, but filters often look for the full string.
- **Linux/Windows:** `w'h'o'am'i` or `w"h"o"am"i`
- **Result:** The shell treats this as `whoami`.

### 2. Linux-Specific Techniques
Useful when the filter is looking for specific command patterns:
- **Positional Parameters:** `who$@ami`
  - *Context:* `$@` is a special variable that defaults to empty.
- **Escape Characters:** `w\ho\am\i`
  - *Context:* The backslash escapes the next character; the shell ignores it, but the filter sees a corrupted string.

### 3. Windows (CMD) Specifics
- **Caret Escape:** `who^ami`
  - *Context:* In Windows CMD, the `^` character escapes the following character, making it invisible to the logic but processed by the shell.

---

## 🛠️ Advanced Concatenation Table
Useful for when specific characters are filtered:

| Technique | Example Payload | Logic |
| :--- | :--- | :--- |
| **Quotes** | `c'a't /etc/passwd` | Bypasses simple keyword match. |
| **Backslashes** | `c\at /etc/passwd` | Hides the command from regex. |
| **Variables** | `w$@hoami` | Interjects empty shell variables. |
| **Windows Caret** | `c^at /etc/passwd` | Windows CMD special escape. |

---

## 💣 Pentester Mindset
* **The "Shell vs. Filter" Battle:** Remember, the **Filter** runs first (trying to find a pattern), and the **Shell** runs second (interpreting the command). If you can make the string look "broken" to the filter but "whole" to the shell, you win.
* **Never assume the filter is perfect.** If your first attempt fails, combine techniques (e.g., `w\h'o'$@a^m"i"`).
* **Test in a local terminal first.** If you can make it work in your own local terminal, the target shell will likely process it exactly the same way.

---

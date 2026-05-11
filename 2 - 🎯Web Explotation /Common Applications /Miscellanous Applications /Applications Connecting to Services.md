
# Reverse Engineering for Credential Discovery

## 🧠 Overview

Developers sometimes hardcode sensitive information (passwords, API keys, connection strings) directly into compiled applications. While the code is not "human-readable" at first glance, reverse engineering tools can reconstruct it to reveal these hidden secrets.

---

## 🐧 ELF Executable Examination (Linux)

ELF (*Executable and Linkable Format*) is the standard binary format for Linux. When dealing with compiled C/C++ binaries, we use debuggers to inspect memory and logic.

### 🧪 Practical Example: `octopus_checker`

If a binary connects to a database, the connection string must exist somewhere in its memory or code.

**1. Static Analysis (The Quick Way):**
Before debugging, always check for plaintext strings:

```bash
strings ./octopus_checker | grep -i "db_"

```

**2. Dynamic Analysis with GDB & PEDA:**
If strings are obfuscated, we use **GDB** with the **PEDA** extension to see the code as it executes.

```bash
gdb ./octopus_checker
# Inside GDB:
gdb-peda$ set disassembly-flavor intel
gdb-peda$ disas main

```

👉 **What to look for:** Look for calls to functions like `mysql_real_connect`, `connect`, or `sprintf`. The arguments passed to these functions (stored in registers like `RDI`, `RSI`) often contain the credentials.

---

## 🪟 DLL & .NET Examination (Windows)

DLLs (*Dynamic Link Libraries*) are used by Windows apps. Many modern enterprise tools are written in **.NET (C# or VB.NET)**, which is "intermediate code" and very easy to reverse.

### 🧪 Practical Example: `MultimasterAPI.dll`

If a file is identified as a **.NET assembly**, we don't need to read assembly code; we can see the original C# code.

**1. Identification:**
Use `file` or `Detect It Easy (DIE)` to confirm it's a .NET binary.

**2. Decompilation with dnSpy:**

1. Open `MultimasterAPI.dll` in **dnSpy**.
2. Navigate through the namespaces and classes.
3. Search (CTRL+SHIFT+K) for keywords like `Password`, `ConnectionString`, `conn`, or `key`.

**💥 Result:** You might find a hardcoded string like:
`this.connectionString = "Server=db.internal;Port=3306;Uid=svc_octopus;Pwd=P@ssw0rd123!";`

---

## 🛠️ Essential Tools for Binary Secrets

| Tool | Platform | Purpose |
| --- | --- | --- |
| **strings** | Cross-platform | Extract plaintext strings from any file. |
| **GDB + PEDA** | Linux | Dynamic analysis and assembly debugging. |
| **dnSpy** | Windows | Decompiling and debugging .NET binaries (C#). |
| **Ghidra** | Cross-platform | Powerful disassembler and decompiler for almost any architecture. |
| **jadx** | Cross-platform | Decompiling Android APKs to Java code. |

---

## 🛡️ Defensive Measures (Remediation)

1. **Never Hardcode:** Use environment variables or secure Vaults (HashiCorp Vault, AWS Secrets Manager).
2. **Obfuscation:** Use tools like `Dotfuscator` for .NET, though this only slows down attackers, it doesn't stop them.
3. **Configuration Files:** Store connection strings in encrypted configuration files that require a unique machine key to decrypt.

---

## 💣 Pentester Mindset

* **Follow the Data:** If an app asks for a login, look at the function that **validates** the login. Sometimes it compares your input against a hardcoded string.
* **The "Temp" Trap:** Check if the binary creates temporary files or logs where it might write the credentials in plaintext during execution.
* **Configuration is Key:** Sometimes the binary isn't vulnerable, but it reads a `.config` or `.xml` file in the same folder that contains the secrets.


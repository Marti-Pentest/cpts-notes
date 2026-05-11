

# GitLab - Enumeration & Exploitation

## 🧠 Overview

GitLab is the central nervous system of DevOps. For a pentester, it represents the highest-value target in a network. Accessing GitLab often provides the "keys to the kingdom": source code, deployment scripts, and production environment credentials.

---

## 🔍 Discovery & Initial Enumeration

### 🧪 Identifying GitLab

Beyond the obvious `/users/sign_in`, GitLab can be identified by specific headers and paths:

* **Version Check (Authenticated):** `http://gitlab.target.htb/help` (Requires login, but essential for CVE matching).
* **Public API:** `http://gitlab.target.htb/api/v4/projects` (Often lists public projects without authentication).

### 🧪 Registration & User Discovery

1. **Self-Registration:** Always check if the "Register" tab is enabled. If it is, you have an entry point for **Authenticated RCE**.
2. **Internal User Discovery:** * Use the search bar in `/explore/users` (if public).
* **Email Enumeration:** Use the password reset or registration forms. If the response says *"Email has already been taken"*, you've confirmed a valid target for password spraying.



---

## 🔑 Hunting for Secrets (The "Low-Hanging Fruit")

Public or internal repositories often leak critical information. Search for:

| File / Pattern | Why it's a Gold Mine |
| --- | --- |
| **`.gitlab-ci.yml`** | Contains CI/CD variables, runner tokens, and deployment logic. |
| **`id_rsa` / `id_ed25519**` | Private SSH keys for lateral movement to other servers. |
| **`.env` / `config.php**` | Database credentials and API keys (AWS, Stripe, Azure). |
| **Commit History:** | Developers often "delete" a password in the latest version, but it stays in the **history**. |

---

## 💥 Remote Code Execution (CVE-2021-22205)

The most famous modern GitLab exploit is the **ExifTool RCE**. It allows an attacker to execute commands by uploading a malformed image file.

### 🚀 Attack Flow:

1. **Registration:** Register a low-privileged account (if enabled).
2. **Upload:** Upload a specially crafted `.jpg` file to a Project snippet or User upload.
3. **Bypass:** The server uses `ExifTool` to process the image metatada. Due to poor validation, the metadata triggers a Perl command injection.

**The Payload Concept:**

```python
# The payload uses DjVu metadata to trigger the injection
payload = f"\" . qx{{{command}}} . \\\n"

```

### 🚀 Exploitation (Authenticated):

```bash
# Example using a common RCE script
python3 gitlab_rce.py -t http://gitlab.target.htb -u user -p pass -c "whoami"

```

---

## 🛠️ Summary of GitLab Attack Vectors

| Attack Vector | Requirement | Impact |
| --- | --- | --- |
| **Public Secret Leak** | None | Credential theft / Infrastructure access. |
| **CVE-2021-22205** | Auth (Self-Reg) | **Critical** (RCE as `git` user). |
| **CI/CD Runner Abuse** | Repo Access | RCE on the Build Server / Token theft. |
| **SSRF via Webhooks** | Auth | Internal network scanning and Cloud Metadata access. |

---

## 🛡️ Defensive Measures

1. **Disable Public Registration:** If the GitLab instance is internal, do not allow anyone to create accounts.
2. **Secret Detection:** Enable GitLab's native **Secret Detection** to scan every commit automatically.
3. **Patching:** This is non-negotiable. Critical CVEs in GitLab move from "Public" to "Weaponized" in less than 24 hours.
4. **Least Privilege Runners:** Ensure CI/CD runners are isolated and don't have access to the master node's SSH keys.

---

## 💣 Pentester Mindset

* **Git is Forever:** If you find a repository, don't just look at the code. **Download the entire `.git` directory** and use tools like `trufflehog` or `gitleaks` to find passwords in old commits.
* **The "Runner" Pivot:** If you get access to a GitLab Runner, you can often pivot into the production environment where the code is deployed.
* **MFA is Key:** Always report if MFA (Multi-Factor Authentication) is not enforced for all users, as GitLab is a high-privilege target.

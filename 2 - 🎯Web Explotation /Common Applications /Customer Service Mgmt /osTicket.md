
# osTicket - Enumeration & Abuse Cases

## 🧠 Overview

osTicket is one of the most popular open-source support ticket systems. While it is generally well-maintained and has a low number of critical CVEs compared to other platforms, it is a **gold mine for internal information** and a perfect pivot point for registration-based attacks.

---

## 🔍 Discovery & Identification

### 🧪 Fingerprinting

* **Cookies:** Look for the `OSTSESSID` cookie in HTTP responses.
* **Footer:** Common strings include `"Support Ticket System"` or `"osTicket"`.
* **Visuals:** Eyewitness or screenshots will often show the classic ticket submission form.

---

## 💥 Attacking Logic: The "Registration Pivot"

This is one of the most creative and effective attacks against a company using osTicket.

### 🧩 Concept: The Confirmation Loop

Many corporate services (Slack, GitLab, Mattermost) allow **auto-registration** if you have a company email (`@company.com`).

1. **The Trap:** An attacker identifies a valid company email (e.g., `support@inlanefreight.local`).
2. **The Action:** The attacker goes to GitLab and tries to register using that company email.
3. **The Leak:** GitLab sends a confirmation email to `support@inlanefreight.local`.
4. **The Access:** Since osTicket is designed to **automatically convert incoming emails into public/accessible tickets**, the confirmation link from GitLab appears as a new ticket or a comment in a ticket.
5. **The Compromise:** The attacker reads the ticket, clicks the link, and successfully registers an account inside the corporate infrastructure.

---

## 🔥 Known Vulnerabilities & Data Exposure

### 1. SSRF (CVE-2020-24881)

In version **1.14.1**, an SSRF (Server-Side Request Forgery) vulnerability allowed attackers to make the server perform requests to internal resources.

* **Impact:** Scanning internal ports or accessing cloud metadata (AWS/Azure) from the support server.

### 2. Credential Harvesting (Dehashed)

If the software itself is patched, the users might not be. Using data leak search engines is a standard part of the OSINT phase for osTicket.

```bash
# Using a script to query Dehashed for leaked company credentials
python3 dehashed.py -q inlanefreight.local -p

```

👉 **Pentester Tip:** If you find a password for an employee, try it on the `/login.php` portal of osTicket. Accessing the agent panel gives you access to **all** internal communications of the company.

---

## 🛡️ Defensive Measures

1. **Sanitize Automated Tickets:** Configure osTicket to filter or redact sensitive information (like password reset links) from incoming emails.
2. **Restrict Self-Registration:** Corporate services (Slack, GitLab) should require **SSO (Single Sign-On)** instead of just email confirmation.
3. **MFA:** Enforce Multi-Factor Authentication for all Support Agents.
4. **Internal Only:** If the ticket system is for employees, do not expose the portal to the public internet.

---

## 💣 Pentester Mindset

* **Information is Power:** Even without an exploit, reading tickets can reveal:
* Internal server names and IP addresses.
* Employee names and roles.
* Software versions used internally (found in "Troubleshooting" tickets).

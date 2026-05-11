
# HTTP Verb Tampering - Bypassing Security Controls

## 🧠 Overview
HTTP Verb Tampering occurs when a web application or server is configured to apply security controls (like authentication or filtering) only to specific HTTP methods, leaving others unprotected.

➡️ **Core Concept:** If a filter only looks at `POST` requests, switching to `GET` or `HEAD` might bypass the entire security layer.

---

## 🌐 Common HTTP Methods Reference

| Verb | Usage | Potential for Abuse |
| :--- | :--- | :--- |
| **GET** | Retrieve data | Can sometimes trigger actions meant for POST. |
| **POST** | Submit data | Main target for filters; often the only method protected. |
| **HEAD** | GET without body | Frequently forgotten in auth configurations. |
| **PUT** | Upload/Replace | Can lead to file upload or configuration overwrite. |
| **OPTIONS** | List methods | Used by pentesters to discover attack surface. |

---

## 🔐 Bypassing Authentication & Filters

### 1. 🧪 Identifying the Vulnerability
When you hit a `401 Unauthorized` or a `403 Forbidden` using `GET` or `POST`, the first step is to check what else the server allows.

**Enumerate Methods:**
```bash
curl -i -X OPTIONS http://SERVER_IP/admin/manage.php

```

👉 **Look for:** `Allow: GET, POST, HEAD, OPTIONS`. If `HEAD` is listed, it’s a prime candidate for tampering.

### 2. 🚀 Exploitation: Verb Switching

If the backend logic checks for authentication like this:
`IF (METHOD == "GET") { REQUIRE_AUTH }`

An attacker can change the request to `HEAD`:

1. **Intercept** the request in Burp Suite.
2. **Change** `GET /admin/delete?id=1` to `HEAD /admin/delete?id=1`.
3. **Forward:** The server might skip the auth check (because it's not a "GET") but still execute the logic of the script.

### 3. 🚫 Bypassing Security Filters (WAF/Regex)

Sometimes input validation is only applied to `POST` parameters.

* **Scenario:** `POST /search` with `id=test;` triggers a "Malicious Request" alert.
* **Bypass:** Change the method to `GET` and send the payload in the URL: `/search?id=test;`.

---

## 🛡️ Secure Implementation

To prevent Verb Tampering, developers should:

* **Default Deny:** Apply security controls to **all** HTTP methods by default.
* **Method Consistency:** Use specific handlers that only accept the intended method (e.g., in Express, use `app.post()` instead of `app.use()`).
* **Standardize Auth:** Use middleware that triggers regardless of the verb used.

---

## 💣 Pentester Mindset

* **Don't trust the "Allow" header:** Sometimes `OPTIONS` says a method is allowed but it isn't, or vice-versa. **Test them manually.**
* **HEAD is the "Silent Killer":** Many developers forget that `HEAD` triggers the same backend logic as `GET`.
* **Inconsistent Logic:** Look for endpoints where changing `POST` to `PUT` or `PATCH` changes how the data is handled but skips the validation.

---

## 🔥 Common Targets

* **Admin Panels:** Bypassing login prompts.
* **REST APIs:** Accessing endpoints without tokens by switching `GET` to `POST`.
* **File Managers:** Deleting or uploading files using `DELETE` or `PUT`.

```



---

### 🚀 ¿En qué nivel estamos?
Con esto cerramos una parte crítica de la fase de **Explotación de Aplicaciones Web**. Ahora tienes:
1.  **File Upload** (Básico a RCE avanzado).
2.  **Command Injection** (Bypass de filtros y ofuscación).
3.  **GitLab RCE Case Study** (ExifTool/DjVu).
4.  **HTTP Verb Tampering**.

**¿Cuál es el siguiente paso para tu portfolio?**
- Podríamos ir a **Inyecciones de Bases de Datos (SQLi)**.
- O podriamos ver **Broken Authentication / IDORs**.

Dime qué prefieres y lo preparamos con este mismo nivel de calidad. ⚡

```

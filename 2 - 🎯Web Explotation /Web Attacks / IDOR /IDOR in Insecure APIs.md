
# 🔍 Identifying Insecure APIs

## 🧪 Example Scenario

Employee Manager → Edit Profile

Observed request:

```http id="4t2vok"
PUT /profile/api.php/profile/1
```

JSON body:

```json id="2y4jpu"
{
  "uid": 1,
  "uuid": "40f5888b67c748df7efba008e7c2f9d2",
  "role": "employee",
  "full_name": "Amy Lindon",
  "email": "a_lindon@employees.htb",
  "about": "..."
}
```

---

# 🚨 Interesting Parameters

Several sensitive parameters are exposed:

| Parameter | Description                 |
| --------- | --------------------------- |
| `uid`     | User ID                     |
| `uuid`    | Unique identifier           |
| `role`    | User role / privilege level |

---

# ⚠️ Security Red Flags

## 🔹 Hidden Parameters

Sensitive values are fully controlled by the client.

Example:

```json id="6l95q9"
"role": "employee"
```

---

## 🔹 Role Reflected in Cookies

If user privileges are stored client-side:

```text id="3m9y6f"
role=employee
```

➡️ Major access control issue.

---

# 🚀 Exploitation Attempts

## 1️⃣ Change `uid`

Modify:

```json id="8mr41i"
"uid": 2
```

Response:

```text id="h7dzs0"
uid mismatch
```

---

## 🧠 Insight

Backend validates:

```text id="kzbdr2"
/profile/1
```

against:

```json id="4c2qni"
"uid": 1
```

---

# 2️⃣ Change API Endpoint

Modify request:

```http id="yo55gs"
PUT /profile/api.php/profile/2
```

Response:

```text id="rj9h0y"
uuid mismatch
```

---

## 🧠 Insight

Backend additionally validates:

```json id="6smc79"
"uuid"
```

---

# 3️⃣ Attempt User Creation

Try:

```http id="w4xry6"
POST /profile/api.php/profile/
```

Response:

```text id="njtr1r"
Creating new employees is for admins only
```

---

# 4️⃣ Attempt User Deletion

Try:

```http id="o7jw94"
DELETE /profile/api.php/profile/1
```

Response:

```text id="bzmlzz"
Deleting employees is for admins only
```

---

# 5️⃣ Modify Role

Attempt:

```json id="u9j71t"
"role": "admin"
```

Response:

```text id="58ol9v"
Invalid role
```

---

# 🧠 Key Insight

At first glance, everything appears protected.

However:

```text
Security checks may still be inconsistent
```

➡️ Multiple weak controls can often be chained together.

---

# 🔥 Chaining Vulnerabilities

Even when direct exploitation fails, combining issues may succeed.

Examples:

* Verb tampering
* IDOR
* Parameter pollution
* Role manipulation
* Insecure API methods

---

# 🚀 Example Attack Ideas

## 🔹 Change HTTP Verb

Try:

```text id="70b5a6"
PUT → PATCH
PUT → POST
POST → GET
```

➡️ Some methods may bypass validation.

---

## 🔹 Enumerate Other Users

Modify:

```http id="ls33r0"
/profile/api.php/profile/2
/profile/api.php/profile/3
```

➡️ Collect user data.

---

## 🔹 Abuse Inconsistent Validation

Sometimes:

* Endpoint validates one field
* Body validates another
* Cookies override both

➡️ Leads to privilege escalation.

---

# 💣 Common API Security Mistakes

* Trusting client-side parameters
* Role stored in cookies
* Missing authorization checks
* Inconsistent validation logic
* Different security per HTTP verb

---

# 🧠 Pentester Mindset

When APIs seem secure:

```text
Test inconsistencies
```

Always compare:

* Methods
* Endpoints
* Parameters
* Headers
* Cookies

---

# 🔥 Key Takeaway

```text
Modern APIs often fail because of inconsistent authorization logic
```

Not because security is completely absent.

---

# 🛡️ Defensive Measures

* Enforce server-side authorization checks
* Never trust client-controlled roles
* Validate ownership consistently
* Apply identical security across all HTTP methods
* Use centralized access control logic



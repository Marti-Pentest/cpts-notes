
# Mass Assignment / Overposting Vulnerabilities

## 🧠 Overview

Mass Assignment occurs when an application takes user-provided data (usually from a JSON body or a Form) and binds it directly to a database model without filtering which fields are allowed to be modified.

➡️ **The Risk:** Attackers can "overpost" extra parameters (like `is_admin`, `balance`, or `role_id`) that the developer never intended for the user to touch, leading to Privilege Escalation or Account Takeover.

---

## 🔍 Vulnerability Mechanism

### 🧪 Framework-Specific Examples

Many modern frameworks facilitate this by providing a single command to save all incoming data:

* **Ruby on Rails (Legacy):** `User.create(params[:user])`
* **Node.js/Sequelize:** `User.create(req.body)`
* **PHP/Laravel:** `User::create($request->all());`

If the `User` model has an `is_admin` column in the database, sending `{"username": "hacker", "is_admin": true}` will set that user as an administrator immediately.

---

## 💥 Case Study: Asset Manager Bypass

### 1. Code Analysis (Whitebox)

Reviewing the registration logic in `app.py`:

```python
try:
    if request.form['confirmed']:
        cond = True
except:
    cond = False

# Database Insertion
cur.execute('insert into users values(?,?,?)', (username, password, cond))

```

**The Flaw:** The code checks if *any* parameter named `confirmed` exists in the POST request. If it does, it sets the `cond` variable to `True`. In the database, the third column (`cond`) is likely the `is_approved` flag.

### 2. Exploitation (Blackbox/Graybox)

By default, the registration form only sends `username` and `password`. The `confirmed` parameter is "hidden" because it's not in the HTML `<form>`.

**Normal Request:**
`POST /register`
`username=attacker&password=P@ssw0rd123`
*Result: `cond = False` (Pending approval).*

**Exploited Request (Via Burp Suite):**
Add the missing parameter to the body:
`POST /register`
`username=attacker&password=P@ssw0rd123&confirmed=true`
*Result: `cond = True` (Account automatically approved).*

---

## 🚀 Common Attack Targets

| Attribute | Impact |
| --- | --- |
| **role / group_id** | Privilege escalation to Admin. |
| **balance / credits** | Financial fraud (adding money to an account). |
| **user_id / owner_id** | Transferring ownership of an object to yourself. |
| **is_confirmed / verified** | Bypassing email/admin verification steps. |

---

## 🛡️ Defensive Measures (Remediation)

### 1. Allowlisting (Strong Parameters)

Explicitly define which fields the user is allowed to touch.

* **Ruby on Rails:** Use `params.require(:user).permit(:username, :email)`.
* **Python/Flask:** Manually extract fields: `user = User(username=request.form['username'])`.

### 2. Data Transfer Objects (DTOs)

Use a separate class for the request data that only contains the safe fields, then map that DTO to your internal database model.

### 3. Read-Only Attributes

Mark sensitive fields as "protected" or "read-only" at the framework/ORM level.

---

## 💣 Pentester Mindset

* **The "Hidden Field" Hunt:** Always check the JavaScript source code or the API documentation (Swagger/Redoc) for fields that aren't in the UI but exist in the model.
* **Guess the Admin Flag:** Try common names for administrative flags: `admin`, `isAdmin`, `is_admin`, `role`, `privilege`, `root`, `confirmed`, `approved`.
* **JSON vs Form-URL-Encoded:** Sometimes an application is secure against form-encoded mass assignment but vulnerable if you send the same data as a JSON object (or vice-versa).

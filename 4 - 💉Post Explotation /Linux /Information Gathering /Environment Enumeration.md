## Linux Local Enumeration

Enumeration is the foundation of privilege escalation. Tools like [LinPEAS](https://github.com/carlospolop/PEASS-ng/tree/master/linPEAS) and [LinEnum](https://github.com/rebootuser/LinEnum) can automate much of this, but understanding what to look for manually is essential.

Three areas to always prioritize:

- **OS version** — identifies available tools and potential public exploits
- **Kernel version** — surface for kernel-level CVEs
- **Running services** — each one is a potential attack vector

---

### 🧭 Situational awareness

First commands after landing on a box:

```shell
whoami && id
hostname
ip -a
sudo -l
```

---

### Operating system & kernel

```shell
cat /etc/os-release   # distro and version
uname -a              # kernel version and architecture
lscpu                 # CPU details
```

---

### PATH & environment variables

```shell
echo $PATH   # check for hijackable paths
env          # may leak credentials or tokens
```

---

### Login shells

Sessions like `tmux` or `screen` left open by other users can be hijacked:

```shell
cat /etc/shells
```

---

### External defenses

Enumerate what's in place before running noisy tools. Common ones to look for:

- [Exec Shield](https://en.wikipedia.org/wiki/Exec_Shield) — memory protection
- [AppArmor](https://apparmor.net/) / [SELinux](https://www.redhat.com/en/topics/linux/what-is-selinux) — mandatory access control
- [iptables](https://linux.die.net/man/8/iptables) / [ufw](https://wiki.ubuntu.com/UncomplicatedFirewall) — firewall rules
- [Fail2ban](https://github.com/fail2ban/fail2ban) / [Snort](https://www.snort.org/) — intrusion detection

Even without permission to read their configs, knowing they exist shapes your approach.

---

### Drives & shares

```shell
lsblk                              # block devices (disks, USBs)
lpstat                             # printers — queued jobs may leak data
cat /etc/fstab                     # mounted and unmounted drives
df -h                              # currently mounted filesystems
cat /etc/fstab | grep -v "#" | column -t   # unmounted filesystems
```

---

### Network & routing

```shell
route          # or: netstat -rn
arp -a         # hosts the machine has recently talked to
cat /etc/resolv.conf   # internal DNS — useful in AD environments
```

> 💡 Cross-referencing the ARP cache with available SSH private keys can reveal reachable hosts for lateral movement.

---

### Users & groups

```shell
cat /etc/passwd | cut -f1 -d:   # all users
grep "*sh$" /etc/passwd          # users with login shells
cat /etc/group                   # all groups
getent group sudo                # members of the sudo group
```

When `/etc/shadow` is readable, identify the hashing algorithm by the prefix:

| Algorithm  | Prefix        |
| ---------- | ------------- |
| Salted MD5 | `$1$`         |
| SHA-256    | `$5$`         |
| SHA-512    | `$6$`         |
| BCrypt     | `$2a$`        |
| Scrypt     | `$7$`         |
| Argon2     | `$argon2i$`   |

---

### Key targets to review manually

- `/home/*/` — personal files and history
- `~/.bash_history` — previous commands, possible credentials
- `~/.ssh/` — private keys and `known_hosts`
- Files with `.conf` / `.config` extensions

---

### Hidden files & directories

```shell
# Hidden files (filtered to current user)
find / -type f -name ".*" -exec ls -l {} \; 2>/dev/null | grep htb-student

# Hidden directories
find / -type d -name ".*" -ls 2>/dev/null
```

---

### Temporary directories

World-writable, often overlooked — check for scripts, credentials, or payloads left behind:

```shell
ls -l /tmp /var/tmp /dev/shm
```

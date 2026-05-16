## SUID / SGID Binaries

Special permission bits allow a binary to run with the privileges of its owner (SUID) or group (SGID) regardless of who executes it. A SUID binary owned by root runs as root — making any exploitable one a direct escalation path.

The `s` in place of the execute bit indicates the flag is set:

```
-rwsr-xr-x 1 root root ... /usr/bin/passwd
```

### Find SUID binaries

```shell
find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null
```

### Find SUID + SGID binaries

```shell
find / -user root -perm -6000 -exec ls -ldb {} \; 2>/dev/null
```

---

## GTFOBins

[GTFOBins](https://gtfobins.github.io/) is a curated reference of Unix binaries that can be abused to bypass security restrictions — including SUID abuse, sudo misconfigurations, restricted shell escapes, and more.

Each entry documents the exact conditions required and the commands needed to exploit them. It's worth becoming familiar with the most common ones, since they appear repeatedly across CTFs, lab environments, and real engagements.

### Example — escaping a restricted environment via `apt-get`

If `apt-get` can be run with elevated privileges, the pre-invoke hook can be abused to spawn a shell:

```shell
sudo apt-get update -o APT::Update::Pre-Invoke::=/bin/sh
```

> 💡 Cross-reference every SUID binary found against GTFOBins before moving on — many standard system binaries have documented escalation paths that are trivial to exploit once identified.

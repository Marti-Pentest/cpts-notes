## Internals

### Network interfaces
```shell
ip a
```

### Hosts file
```shell
cat /etc/hosts
```

### Last login per user
```shell
lastlog
```

### Currently logged-in users
```shell
w
```

### Command history
```shell
history

# Search for history files across the filesystem
find / -type f \( -name *_hist -o -name *_history \) -exec ls -l {} \; 2>/dev/null
```

### Cron jobs
```shell
ls -la /etc/cron.daily/
```

### Process cmdlines via /proc

A stealthier alternative to `ps` — reads process arguments directly from the kernel:

```shell
find /proc -name cmdline -exec cat {} \; 2>/dev/null | tr " " "\n"
```

---

## Services & Installed Software

### Installed packages

Outdated packages are a common escalation path — always cross-reference versions against known CVEs:

```shell
apt list --installed | tr "/" " " | cut -d" " -f1,3 | sed 's/[0-9]://g' | tee -a installed_pkgs.list
```

### Sudo version

```shell
sudo -V
```

Older versions of `sudo` are vulnerable to well-known CVEs (e.g. CVE-2021-3156 — Baron Samedit).

### System binaries

```shell
ls -l /bin /usr/bin/ /usr/sbin/
```

### GTFOBins

[GTFOBins](https://gtfobins.github.io/) catalogs binaries that can be abused for privilege escalation. The one-liner below compares installed packages against the GTFOBins list automatically:

```shell
for i in $(curl -s https://gtfobins.github.io/ | html2text | cut -d" " -f1 | sed '/^[[:space:]]*$/d'); do
  if grep -q "$i" installed_pkgs.list; then
    echo "Check GTFO for: $i"
  fi
done
```

### Trace system calls

`strace` follows every syscall a binary makes — useful for understanding how a program accesses files, sockets, or credentials at runtime:

```shell
strace ping -c1 10.129.112.20
```

> 💡 Redirect output to a file for easier analysis: `strace <command> 2>/tmp/trace.out`

### Configuration files

Config files frequently contain hardcoded credentials, API keys, or internal hostnames:

```shell
find / -type f \( -name *.conf -o -name *.config \) -exec ls -l {} \; 2>/dev/null
```

### Scripts

```shell
find / -type f -name "*.sh" 2>/dev/null | grep -v "src\|snap\|share"
```

### Running services by user

Scripts or services running as root without strict permissions are a direct escalation vector:

```shell
ps aux | grep root
```

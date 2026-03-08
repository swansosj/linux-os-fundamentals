# DNS Server (BIND9) — Complete Lecture Guide

> **Prerequisites:** Students should have completed the Web Server guide (web.md) first. The Azure VM should already have Nginx running.
>
> **Sample files location:** `../lesson6-maintain-system-startup-services/sample-files/dns/`
> All zone files and BIND9 configs are there. If you followed the tar/scp steps in the Web Server guide, they're already on the VM in `~/dns/`.

---

# Table of Contents

1. [What is DNS?](#1--what-is-dns)
2. [How DNS Resolution Works](#2--how-dns-resolution-works)
3. [DNS Record Types](#3--dns-record-types)
4. [Why BIND9?](#4--why-bind9)
5. [Command Reference — Every Command We Will Use](#5--command-reference--every-command-we-will-use)
6. [Step 1: Installing BIND9](#step-1-installing-bind9)
7. [Step 2: Understanding BIND9 File Layout](#step-2-understanding-bind9-file-layout)
8. [Step 3: Configuring BIND9 Options](#step-3-configuring-bind9-options)
9. [Step 4: Defining Zones (named.conf.local)](#step-4-defining-zones-namedconflocal)
10. [Step 5: Creating the Forward Zone File](#step-5-creating-the-forward-zone-file)
11. [Step 6: Creating the Reverse Zone File](#step-6-creating-the-reverse-zone-file)
12. [Step 7: Validating Zone Files](#step-7-validating-zone-files)
13. [Step 8: Restarting BIND9 and Testing](#step-8-restarting-bind9-and-testing)
14. [Step 9: Configuring the Server to Use Its Own DNS](#step-9-configuring-the-server-to-use-its-own-dns)
15. [Step 10: Testing From a Browser](#step-10-testing-from-a-browser)
16. [DNS Troubleshooting](#dns-troubleshooting)
17. [Appendix — Zone File Quick Reference](#appendix--zone-file-quick-reference)

---

---

# 1 — What is DNS?

**DNS** (Domain Name System) translates **human-readable names** into **IP addresses** and vice versa.

Without DNS, you'd have to type `192.168.1.100` every time you wanted to visit a website. DNS lets you type `www.lab.local` instead.

```
           "What's the IP for www.lab.local?"
┌──────────┐  ──────────────────────────>  ┌──────────────┐
│  Client  │                                │  DNS Server   │
│ (Browser)│  <──────────────────────────   │  (BIND9)     │
└──────────┘   "It's 192.168.1.100"        │  Port 53      │
                                           └──────────────┘
```

### Analogy

DNS is like a **phone book** for the internet:
- You know the **name** (www.google.com)
- You need the **number** (142.250.80.46)
- The phone book (DNS) translates between the two

---

# 2 — How DNS Resolution Works

When you type `www.lab.local` in a browser:

```
Step 1: Browser checks its cache — "Do I already know this IP?"
        ↓ No
Step 2: OS checks /etc/resolv.conf — "Which DNS server should I ask?"
        ↓ nameserver 127.0.0.1 (our BIND9 server)
Step 3: OS sends a DNS query to 127.0.0.1 port 53
        ↓
Step 4: BIND9 checks its zone files:
        →  db.lab.local has:  www  IN  A  192.168.1.100
        ↓
Step 5: BIND9 responds: "www.lab.local = 192.168.1.100"
        ↓
Step 6: Browser connects to 192.168.1.100:80 (HTTP)
        ↓
Step 7: Nginx receives the request, serves the website
```

### Two Types of Lookups

| Type | Question | Answer | Zone File |
|------|----------|--------|-----------|
| **Forward** | "What IP is www.lab.local?" | 192.168.1.100 | `db.lab.local` |
| **Reverse** | "What name has IP 192.168.1.100?" | www.lab.local | `db.192.168.1` |

---

# 3 — DNS Record Types

| Record | Name | Purpose | Example |
|--------|------|---------|---------|
| **A** | Address | Maps a name to an IPv4 address | `www IN A 192.168.1.100` |
| **AAAA** | Quad-A | Maps a name to an IPv6 address | `www IN AAAA ::1` |
| **CNAME** | Canonical Name | An alias — points one name to another | `webserver IN CNAME www` |
| **MX** | Mail Exchange | Which server handles email for this domain | `@ IN MX 10 mail.lab.local.` |
| **NS** | Name Server | Which server is authoritative for this zone | `@ IN NS ns1.lab.local.` |
| **PTR** | Pointer | Reverse lookup — maps an IP to a name | `100 IN PTR www.lab.local.` |
| **SOA** | Start of Authority | Zone metadata (serial, refresh, retry, expire) | At the top of every zone file |
| **TXT** | Text | Arbitrary text (used for SPF, DKIM, verification) | `@ IN TXT "Our Lab DNS Server"` |

---

# 4 — Why BIND9?

| Feature | BIND9 | dnsmasq | systemd-resolved |
|---------|-------|---------|-----------------|
| Full authoritative DNS | Yes | No | No |
| Forward and reverse zones | Yes | Limited | No |
| Industry standard | Yes (most used worldwide) | For small networks | Desktop only |
| Zone file support | Full | No | No |
| Available on Debian | Yes (`apt install bind9`) | Yes | Yes (built-in) |

BIND9 is the reference implementation of DNS and powers a large portion of DNS on the internet. Learning BIND9 teaches real DNS concepts that apply everywhere.

---

---

# 5 — Command Reference — Every Command We Will Use

## `apt` — Install BIND9

```bash
# Install bind9 and DNS utilities (dig, nslookup, host)
sudo apt update
sudo apt install -y bind9 bind9-utils dnsutils

# Verify
named -v
# BIND 9.18.x (Extended Support Version)
```

---

## `systemctl` — Manage BIND9 Service

```bash
# Start BIND9
sudo systemctl start named

# Stop BIND9
sudo systemctl stop named

# Restart after config changes (REQUIRED — BIND9 doesn't support simple reload for zone changes)
sudo systemctl restart named

# Reload config only (without zone changes)
sudo rndc reload

# Check if running
systemctl status named
systemctl is-active named

# Enable on boot
sudo systemctl enable named

# View logs
sudo journalctl -u named -n 30
sudo journalctl -u named -f
```

> **Important:** The BIND9 service name is `named` (short for "name daemon"), not "bind9" (though Debian also creates a `bind9` alias). Use `named` to be consistent with other Linux distributions.

---

## `named-checkconf` — Validate BIND9 Configuration

### What is it?
Checks the main BIND9 configuration files (`named.conf`, `named.conf.local`, `named.conf.options`) for syntax errors. This is the DNS equivalent of `nginx -t`.

```bash
# Check the configuration
sudo named-checkconf

# If no output → config is OK
# If there's an error, it tells you the file and line:
# /etc/bind/named.conf.local:5: unknown option 'zne'
```

### Always Run Before Restarting

```bash
# 1. Edit config
sudo nano /etc/bind/named.conf.local

# 2. Validate
sudo named-checkconf

# 3. Only restart if validation passed
sudo systemctl restart named
```

---

## `named-checkzone` — Validate Zone Files

### What is it?
Checks a specific zone file for syntax errors, missing records, and serial number issues. This is critical — a bad zone file will prevent BIND9 from loading that zone.

```bash
# Syntax: named-checkzone ZONE_NAME ZONE_FILE

# Check the forward zone
sudo named-checkzone lab.local /etc/bind/zones/db.lab.local
# zone lab.local/IN: loaded serial 2025010101
# OK

# Check the reverse zone
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/zones/db.192.168.1
# zone 1.168.192.in-addr.arpa/IN: loaded serial 2025010101
# OK
```

### Common Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| `no NS RRs found` | Missing NS record in zone | Add `@ IN NS ns1.lab.local.` |
| `not at top of zone` | SOA record not first | Move SOA to be the first record |
| `has no address records` | NS hostname has no A record | Add A record for ns1 |
| `bad dotted quad` | Malformed IP address | Check for typos in IPs |
| `unexpected end of input` | Missing closing parenthesis | Check SOA serial block for `)` |

---

## `dig` — DNS Lookup Tool (Most Detailed)

### What is it?
`dig` (Domain Information Groper) is the best DNS troubleshooting tool. It sends DNS queries and shows detailed results including the server that answered, TTL values, and all sections of the DNS response.

### Common Usage

```bash
# Basic A record lookup
dig www.lab.local

# Query a SPECIFIC DNS server (our BIND9 server)
dig @127.0.0.1 www.lab.local

# Query a specific record type
dig @127.0.0.1 lab.local MX
dig @127.0.0.1 lab.local NS
dig @127.0.0.1 lab.local TXT
dig @127.0.0.1 lab.local SOA

# Short answer only (less verbose)
dig +short www.lab.local
dig +short @127.0.0.1 www.lab.local

# Reverse lookup (IP → name)
dig -x 192.168.1.100
dig @127.0.0.1 -x 192.168.1.100

# Trace the full resolution path
dig +trace www.lab.local

# Show all records for a domain
dig @127.0.0.1 lab.local ANY
```

### Common Options

| Option | Meaning |
|--------|---------|
| `@SERVER` | Query a specific DNS server |
| `+short` | Show only the answer (no headers) |
| `-x IP` | Reverse lookup |
| `+trace` | Trace the DNS resolution chain |
| `ANY` | Request all record types |
| `A`, `MX`, `NS`, etc. | Request a specific record type |

### Reading dig Output

```
; <<>> DiG 9.18.x <<>> @127.0.0.1 www.lab.local
;; QUESTION SECTION:
;www.lab.local.          IN    A           ← What we asked

;; ANSWER SECTION:
www.lab.local.    86400  IN    A    192.168.1.100    ← The answer
│                 │      │     │    │
│                 │      │     │    └─ The IP address
│                 │      │     └─ Record type
│                 │      └─ Class (IN = Internet)
│                 └─ TTL (time to live, in seconds)
└─ Name queried

;; AUTHORITY SECTION:
lab.local.        86400  IN    NS   ns1.lab.local.   ← Who's authoritative

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)                   ← Which DNS server answered
```

---

## `nslookup` — Simple DNS Lookup

### What is it?
`nslookup` is a simpler DNS lookup tool. Less detailed than `dig`, but easier for beginners.

```bash
# Basic lookup
nslookup www.lab.local

# Query a specific server
nslookup www.lab.local 127.0.0.1

# Reverse lookup
nslookup 192.168.1.100
```

### Reading the Output

```
Server:     127.0.0.1            ← DNS server we asked
Address:    127.0.0.1#53         ← Server IP and port

Name:   www.lab.local            ← The name we looked up
Address: 192.168.1.100           ← The answer
```

---

## `host` — Simplest DNS Lookup

### What is it?
The simplest DNS lookup tool. Great for quick checks.

```bash
# Forward lookup
host www.lab.local
# www.lab.local has address 192.168.1.100

# Reverse lookup
host 192.168.1.100
# 100.1.168.192.in-addr.arpa domain name pointer www.lab.local.

# Query specific record type
host -t MX lab.local
host -t NS lab.local
host -t TXT lab.local

# Query a specific server
host www.lab.local 127.0.0.1
```

### Comparison: dig vs nslookup vs host

| Feature | `dig` | `nslookup` | `host` |
|---------|-------|------------|--------|
| Detail level | Very detailed | Medium | Minimal |
| Best for | Troubleshooting | Quick checks | Scripting |
| Shows TTL | Yes | No | No |
| Shows authority section | Yes | No | No |
| Reverse lookup | `dig -x` | `nslookup IP` | `host IP` |

> **Teaching Note:** Teach `host` first (simple output), then `nslookup` (a bit more), then `dig` (full details). Students should be comfortable with all three, but `dig` is the professional standard.

---

## `ss` — Check if BIND9 Is Listening

```bash
# Check TCP port 53
sudo ss -tlnp | grep :53

# Check UDP port 53 (DNS primarily uses UDP)
sudo ss -ulnp | grep :53

# Check both TCP and UDP
sudo ss -tulnp | grep :53
# udp   UNCONN  0  0  0.0.0.0:53  0.0.0.0:*  users:(("named",pid=1234,fd=15))
# tcp   LISTEN  0  10 0.0.0.0:53  0.0.0.0:*  users:(("named",pid=1234,fd=16))
```

> **Teaching Note:** DNS uses **UDP port 53** for normal queries and **TCP port 53** for zone transfers and large responses. BIND9 listens on both.

---

---

# Step 1: Installing BIND9

```bash
# Update package lists
sudo apt update

# Install BIND9 and DNS utilities
sudo apt install -y bind9 bind9-utils dnsutils

# What we installed:
#   bind9         → The DNS server daemon (named)
#   bind9-utils   → named-checkconf, named-checkzone, rndc
#   dnsutils      → dig, nslookup, host

# Verify the version
named -v
# BIND 9.18.x (Extended Support Version) ...

# Check that it's running
systemctl status named

# Check that it's listening on port 53
sudo ss -tulnp | grep :53
```

> **Live Demo Point:** After installing, BIND9 is running but only as a caching DNS server. It can forward queries to upstream servers (like 8.8.8.8) but doesn't know about our `lab.local` domain yet. We need to configure zones.

---

# Step 2: Understanding BIND9 File Layout

```bash
# Show the BIND9 configuration directory
ls -la /etc/bind/
```

| Path | Purpose |
|------|---------|
| `/etc/bind/named.conf` | Main entry point (includes the other files) |
| `/etc/bind/named.conf.options` | **Global options** (forwarders, recursion, listen addresses) |
| `/etc/bind/named.conf.local` | **Zone definitions** (what domains this server is authoritative for) |
| `/etc/bind/named.conf.default-zones` | Default built-in zones (localhost, etc.) — don't edit |
| `/etc/bind/zones/` | **Zone files** directory — we'll create this |
| `/var/log/named/` | Log files (if custom logging is configured) |
| `/usr/sbin/named` | The BIND9 daemon binary |
| `/lib/systemd/system/named.service` | The systemd unit file |

### How the Config Files Fit Together

```
/etc/bind/named.conf            ← Master config (includes everything)
    ├── include "named.conf.options"    ← Global behavior
    ├── include "named.conf.local"      ← Our zone definitions  
    └── include "named.conf.default-zones"  ← Built-in zones (don't touch)

/etc/bind/zones/                 ← Zone file directory (we create this)
    ├── db.lab.local            ← Forward zone (name → IP)
    └── db.192.168.1            ← Reverse zone (IP → name)
```

```bash
# View how they're included
cat /etc/bind/named.conf
# include "/etc/bind/named.conf.options";
# include "/etc/bind/named.conf.local";
# include "/etc/bind/named.conf.default-zones";
```

---

# Step 3: Configuring BIND9 Options

### Our Config: `/etc/bind/named.conf.options`

```bash
# Back up the original first!
sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup

# Deploy our config
sudo cp ~/dns/named.conf.options /etc/bind/named.conf.options
```

Let's examine every line:

```
// BIND9 Options Configuration for Lab Environment
options {
    // Where BIND stores its working files (zone transfers, cache)
    directory "/var/cache/bind";

    // Accept DNS queries from anyone
    // In production you'd restrict this: allow-query { 192.168.1.0/24; };
    allow-query { any; };

    // Allow recursive queries (this server will look up names on behalf of clients)
    recursion yes;

    // When this server doesn't know an answer, ask these upstream DNS servers
    forwarders {
        8.8.8.8;     // Google Public DNS
        1.1.1.1;     // Cloudflare Public DNS
    };

    // Listen for DNS queries on all network interfaces, port 53
    listen-on { any; };

    // Listen on IPv6 too
    listen-on-v6 { any; };

    // DNSSEC validation (security feature for DNS)
    dnssec-validation auto;
};
```

### Key Options Explained

| Option | What it does | Our setting |
|--------|-------------|-------------|
| `directory` | Working directory for cache and temp files | `/var/cache/bind` |
| `allow-query` | Who can send DNS queries to this server | `any` (everyone) |
| `recursion` | Whether to resolve queries on behalf of clients | `yes` |
| `forwarders` | Upstream DNS servers for names we don't know | Google + Cloudflare |
| `listen-on` | Which network interfaces to listen on | `any` (all interfaces) |
| `dnssec-validation` | Validate DNSSEC signatures | `auto` |

### What Are Forwarders?

Our server is authoritative for `lab.local` — it knows those answers directly. But if someone asks for `www.google.com`, our server doesn't know that. It **forwards** the query to Google's DNS (8.8.8.8) or Cloudflare's DNS (1.1.1.1) and relays the answer back.

```
Client asks: "What's www.google.com?"
    ↓
BIND9: "I don't know lab.local? No. Let me ask my forwarders..."
    ↓
BIND9 → 8.8.8.8: "What's www.google.com?"
    ↓
8.8.8.8 → BIND9: "It's 142.250.80.46"
    ↓
BIND9 → Client: "It's 142.250.80.46"
```

---

# Step 4: Defining Zones (named.conf.local)

### Our Config: `/etc/bind/named.conf.local`

```bash
# Deploy our zone definitions
sudo cp ~/dns/named.conf.local /etc/bind/named.conf.local
```

Let's examine it:

```
// Zone definitions for lab.local

// Forward zone — lab.local
// Translates names like www.lab.local → 192.168.1.100
zone "lab.local" {
    type master;                          // This server is the authoritative source
    file "/etc/bind/zones/db.lab.local";  // Path to the zone data file
};

// Reverse zone — 192.168.1.x
// Translates IPs like 192.168.1.100 → www.lab.local
zone "1.168.192.in-addr.arpa" {
    type master;                          // This server is the authoritative source
    file "/etc/bind/zones/db.192.168.1";  // Path to the reverse zone file
};
```

### Understanding Zone Definitions

| Directive | Meaning |
|-----------|---------|
| `zone "lab.local"` | Domain name this zone covers |
| `type master` | This server is the primary/authoritative source |
| `file "..."` | Path to the zone file with the actual records |

### Why is the Reverse Zone Named Backwards?

The reverse zone `1.168.192.in-addr.arpa` is the **IP octets reversed** plus `.in-addr.arpa`:
- Network: `192.168.1.0/24`
- Reversed: `1.168.192`
- Full name: `1.168.192.in-addr.arpa`

This is how DNS reverse lookups work — they read the IP backwards using the special `in-addr.arpa` domain.

---

# Step 5: Creating the Forward Zone File

The forward zone file maps **names to IP addresses** (the most common DNS task).

### Create the Zones Directory

```bash
# Create the directory for zone files
sudo mkdir -p /etc/bind/zones
```

### Deploy Our Zone File

```bash
# Copy the zone file
sudo cp ~/dns/db.lab.local /etc/bind/zones/db.lab.local
```

### Walk Through Every Line

```
;
; Forward zone file for lab.local
;
; TTL = Time To Live — how long (in seconds) other DNS servers
; should cache this answer before asking again
$TTL    86400       ; 86400 seconds = 24 hours

; SOA = Start of Authority
; This record defines who is responsible for this zone
;
; Format: zone  IN  SOA  primary-ns  admin-email  ( serial refresh retry expire minimum )
@       IN      SOA     ns1.lab.local. admin.lab.local. (
                        2025010101  ; Serial — MUST increment on every change (YYYYMMDDnn)
                        3600        ; Refresh — how often secondary servers check for updates (1 hour)
                        1800        ; Retry — if refresh fails, try again after this (30 min)
                        604800      ; Expire — secondary stops answering after this (1 week)
                        86400       ; Minimum TTL — negative cache TTL (1 day)
)

; NS record — declares the authoritative name server for this zone
@       IN      NS      ns1.lab.local.

; A records — name to IP mappings (the core of DNS)
ns1     IN      A       192.168.1.100   ; The DNS server itself
www     IN      A       192.168.1.100   ; The web server
web     IN      A       192.168.1.100   ; Another name for the web server
mail    IN      A       192.168.1.100   ; Mail server
ftp     IN      A       192.168.1.100   ; FTP server
db      IN      A       192.168.1.100   ; Database server
app     IN      A       192.168.1.100   ; Application server

; CNAME records — aliases (point one name to another)
webserver  IN   CNAME   www             ; webserver.lab.local → www.lab.local
website    IN   CNAME   www             ; website.lab.local → www.lab.local
dns        IN   CNAME   ns1             ; dns.lab.local → ns1.lab.local

; MX record — mail exchange (which server handles email for this domain)
; The 10 is the priority (lower = higher priority)
@       IN      MX      10  mail.lab.local.

; TXT record — arbitrary text (used for SPF, domain verification, etc.)
@       IN      TXT     "Our Lab DNS Server"
```

### Key Concepts

#### The `@` Symbol
`@` means "this zone" — it represents `lab.local` in this context.

#### The Trailing Dot (.)
Names ending with a **dot** are **fully qualified** (absolute). Names without a dot have the zone name appended automatically.

```
ns1.lab.local.     ← Fully qualified (the dot means "stop, this is the full name")
ns1                ← Relative (BIND appends the zone: ns1 → ns1.lab.local.)
```

> **Teaching Note:** The trailing dot is the **most common mistake** in zone files. If you write `ns1.lab.local` (no dot) in a zone file, BIND reads it as `ns1.lab.local.lab.local.` which is wrong.

#### Serial Number

```
2025010101  ; Format: YYYYMMDDnn
```

The serial number **MUST** be incremented every time you change the zone file. If you don't increment it, secondary DNS servers won't pick up your changes.

| Serial | Date | Change |
|--------|------|--------|
| 2025010101 | Jan 1, 2025 | First version (01) |
| 2025010102 | Jan 1, 2025 | Second change that day (02) |
| 2025010201 | Jan 2, 2025 | Next day, first change (01) |

---

# Step 6: Creating the Reverse Zone File

The reverse zone maps **IP addresses back to names** (PTR records).

```bash
# Deploy the reverse zone file
sudo cp ~/dns/db.192.168.1 /etc/bind/zones/db.192.168.1
```

### Walk Through the File

```
;
; Reverse zone file for 192.168.1.x network
;
$TTL    86400

@       IN      SOA     ns1.lab.local. admin.lab.local. (
                        2025010101  ; Serial
                        3600        ; Refresh
                        1800        ; Retry
                        604800      ; Expire
                        86400       ; Minimum TTL
)

; Name server
@       IN      NS      ns1.lab.local.

; PTR records — IP to name mappings (reverse of A records)
; ONLY the last octet is specified because the zone covers 192.168.1.x
100     IN      PTR     ns1.lab.local.
100     IN      PTR     www.lab.local.
```

### Why Only the Last Octet?

The zone name `1.168.192.in-addr.arpa` already defines the first three octets (`192.168.1`). In the zone file, we only specify the **host** part:

```
Zone: 1.168.192.in-addr.arpa  (covers 192.168.1.x)

100  IN  PTR  www.lab.local.
↑                            
This means 192.168.1.100     
            ↑↑↑↑↑↑↑↑↑  ↑↑↑
           from zone   from record
```

---

# Step 7: Validating Zone Files

**Always validate before restarting BIND9.** A broken zone file takes down DNS for that domain.

```bash
# Step 1: Check the main configuration
sudo named-checkconf
# (no output = success)

# Step 2: Check the forward zone
sudo named-checkzone lab.local /etc/bind/zones/db.lab.local
# zone lab.local/IN: loaded serial 2025010101
# OK

# Step 3: Check the reverse zone
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/zones/db.192.168.1
# zone 1.168.192.in-addr.arpa/IN: loaded serial 2025010101
# OK
```

### If Validation Fails

```bash
# Example error:
sudo named-checkzone lab.local /etc/bind/zones/db.lab.local
# zone lab.local/IN: NS 'ns1.lab.local' has no address records (A or AAAA)
# zone lab.local/IN: not loaded due to errors.

# This means the NS record points to ns1.lab.local but there's no A record for it
# Fix: add  ns1  IN  A  192.168.1.100  to the zone file
```

---

# Step 8: Restarting BIND9 and Testing

```bash
# Restart BIND9 to load our new configuration
sudo systemctl restart named

# Check that it's running
systemctl status named

# Check it's listening on port 53
sudo ss -tulnp | grep :53
```

### Test Forward Lookups (Name → IP)

```bash
# Using dig (most detailed)
dig @127.0.0.1 www.lab.local
dig @127.0.0.1 www.lab.local +short
# 192.168.1.100

# Test other records
dig @127.0.0.1 ns1.lab.local +short
dig @127.0.0.1 mail.lab.local +short
dig @127.0.0.1 ftp.lab.local +short
dig @127.0.0.1 db.lab.local +short

# Test CNAME (alias)
dig @127.0.0.1 webserver.lab.local
# webserver.lab.local.  86400  IN  CNAME  www.lab.local.
# www.lab.local.        86400  IN  A      192.168.1.100

# Test MX (mail exchange)
dig @127.0.0.1 lab.local MX +short
# 10 mail.lab.local.

# Test NS (name server)
dig @127.0.0.1 lab.local NS +short
# ns1.lab.local.

# Test TXT
dig @127.0.0.1 lab.local TXT +short
# "Our Lab DNS Server"

# Using nslookup
nslookup www.lab.local 127.0.0.1

# Using host
host www.lab.local 127.0.0.1
# www.lab.local has address 192.168.1.100
```

### Test Reverse Lookup (IP → Name)

```bash
# Using dig
dig @127.0.0.1 -x 192.168.1.100 +short
# ns1.lab.local.
# www.lab.local.

# Using nslookup
nslookup 192.168.1.100 127.0.0.1

# Using host
host 192.168.1.100 127.0.0.1
# 100.1.168.192.in-addr.arpa domain name pointer ns1.lab.local.
# 100.1.168.192.in-addr.arpa domain name pointer www.lab.local.
```

### Test Forwarding (External Names)

```bash
# Our server should also resolve external names via forwarders
dig @127.0.0.1 www.google.com +short
# (should return Google's IP addresses)

# This works because of the forwarders in named.conf.options
```

> **Live Demo Point:** Have students watch as you query different record types. Show how `dig` gives all the details while `host` gives just the answer. Let them try `dig @127.0.0.1 lab.local ANY` to see all records at once.

---

# Step 9: Configuring the Server to Use Its Own DNS

Right now, the server uses whatever DNS was configured by Azure (usually Azure's internal DNS). We need to point it at our own BIND9 server.

### Update /etc/resolv.conf

```bash
# Check current DNS config
cat /etc/resolv.conf

# Back up the original
sudo cp /etc/resolv.conf /etc/resolv.conf.backup

# Point DNS to our own server (localhost) FIRST, then fall back to Azure
echo -e "nameserver 127.0.0.1\nnameserver 168.63.129.16" | sudo tee /etc/resolv.conf
```

### What is resolv.conf?

```
nameserver 127.0.0.1       ← First: ask our BIND9 server
nameserver 168.63.129.16   ← Fallback: ask Azure's DNS if ours fails
```

The system tries each nameserver in order. If the first doesn't respond within a timeout, it falls back to the next.

### Verify It Works

```bash
# Now we can query without specifying @127.0.0.1
dig www.lab.local +short
# 192.168.1.100

host lab.local
# lab.local has address 192.168.1.100

# External names should still work
dig google.com +short

# The web server should now be reachable by name
curl http://www.lab.local
# (shows our website HTML!)
```

> **Important Note:** On many cloud VMs, `resolv.conf` gets overwritten on reboot by the DHCP client or systemd-resolved. For a persistent change, you'd need to configure the DHCP client or systemd-resolved. For our lab, simply re-running the command after a reboot is fine.

---

# Step 10: Testing From a Browser

### From the Azure VM Itself

```bash
# Test with curl using the domain name
curl http://lab.local
curl http://www.lab.local
curl http://web.lab.local
curl http://webserver.lab.local

# All should return the same HTML page (they all resolve to 192.168.1.100)

# Check headers
curl -I http://www.lab.local
# HTTP/1.1 200 OK
# Server: nginx/1.22.1

# Try the info page with custom headers
curl -I http://www.lab.local/info.html
# X-Served-By: Nginx on Debian
# X-Lab: FSCJ Linux Fundamentals
```

### From a Student's Own Machine

Students can add an entry to their local hosts file to test:

**macOS/Linux:**
```bash
echo "<VM-PUBLIC-IP> lab.local www.lab.local web.lab.local" | sudo tee -a /etc/hosts
# Then open http://www.lab.local in a browser
```

**Windows (Run as Administrator):**
```
notepad C:\Windows\System32\drivers\etc\hosts
# Add: <VM-PUBLIC-IP> lab.local www.lab.local web.lab.local
```

> **Teaching Note:** The `hosts` file is checked before DNS. Adding an entry there lets the browser resolve `www.lab.local` to the Azure VM's public IP without needing to configure DNS clients to point to our BIND9 server (which is on a private IP not reachable from the internet).

---

---

# DNS Troubleshooting

## Problem: BIND9 Won't Start

```bash
# Check the journal for errors
sudo journalctl -u named -n 30

# Validate configuration
sudo named-checkconf
# Fix any errors reported

# Common causes:
# - Typo in named.conf.options or named.conf.local
# - Zone file doesn't exist at the specified path
# - Permission problem on zone file directory
```

## Problem: dig Returns "SERVFAIL"

```bash
dig @127.0.0.1 www.lab.local
# ;; ->>HEADER<<- ... status: SERVFAIL

# This usually means the zone file has errors
# Validate the zone file:
sudo named-checkzone lab.local /etc/bind/zones/db.lab.local

# Common causes:
# - Missing dot at end of fully qualified names
# - Missing NS record
# - SOA record error
# - File permissions (bind user can't read the file)

# Check permissions:
ls -la /etc/bind/zones/
# Files should be readable by bind:bind
sudo chown bind:bind /etc/bind/zones/*
```

## Problem: dig Returns "REFUSED"

```bash
dig @127.0.0.1 www.lab.local
# ;; ->>HEADER<<- ... status: REFUSED

# This means BIND9 is refusing to answer your query
# Check allow-query in named.conf.options:
#   allow-query { any; };     ← Should be this
#   allow-query { localhost; };  ← Too restrictive
```

## Problem: dig Returns "NXDOMAIN" (Name Not Found)

```bash
dig @127.0.0.1 www.lab.local
# ;; ->>HEADER<<- ... status: NXDOMAIN

# NXDOMAIN = "this name doesn't exist in any zone I know about"

# Check 1: Is the zone defined in named.conf.local?
grep -A3 "lab.local" /etc/bind/named.conf.local

# Check 2: Does the zone file have the right records?
grep "www" /etc/bind/zones/db.lab.local

# Check 3: Is the zone loaded? Check logs:
sudo journalctl -u named | grep "lab.local"
# Look for: "zone lab.local/IN: loaded serial 2025010101"
# If missing: the zone wasn't loaded (check file path in named.conf.local)
```

## Problem: DNS Works on Server but Not from Browser

```bash
# Verify DNS works on the server:
dig @127.0.0.1 www.lab.local +short
# 192.168.1.100  ← works

# From your local machine, can you reach the DNS port?
nc -zv <VM-PUBLIC-IP> 53
# If timeout → Azure NSG is blocking UDP/TCP 53

# Alternative: Use the hosts file on your local machine (simpler)
# See Step 10 for details
```

## Problem: External Names Stopped Resolving

```bash
# Check if forwarders are configured
grep -A5 "forwarders" /etc/bind/named.conf.options

# Check if the VM has internet connectivity
ping -c 3 8.8.8.8

# Check resolv.conf didn't get corrupted
cat /etc/resolv.conf
# Should have: nameserver 127.0.0.1
```

### DNS Troubleshooting Quick Reference

| Symptom | First Command | Likely Cause |
|---------|---------------|-------------|
| BIND9 won't start | `sudo journalctl -u named -n 20` | Config syntax error |
| SERVFAIL | `sudo named-checkzone lab.local /etc/bind/zones/db.lab.local` | Zone file error |
| REFUSED | Check `allow-query` in named.conf.options | Queries not allowed |
| NXDOMAIN | `grep "www" /etc/bind/zones/db.lab.local` | Record missing or zone not loaded |
| Timeout from outside | `nc -zv <IP> 53` | Firewall / NSG blocking port 53 |
| External names fail | `ping -c 3 8.8.8.8` | No internet or forwarders misconfigured |
| Changes don't take effect | Check serial number in zone file | Serial not incremented |

---

---

# Appendix — Zone File Quick Reference

### Record Format

```
name   TTL   class   type   data
www    86400  IN      A      192.168.1.100
```

| Field | Meaning | Example |
|-------|---------|---------|
| `name` | The hostname (relative to zone) | `www`, `mail`, `@` |
| `TTL` | Cache duration in seconds | `86400` (24 hours) |
| `class` | Always `IN` (Internet) | `IN` |
| `type` | Record type | `A`, `CNAME`, `MX`, `PTR`, `NS` |
| `data` | The answer | IP, hostname, priority+hostname |

### SOA Record Format

```
@  IN  SOA  primary-ns.  admin-email.  (
    serial      ; MUST increment on changes
    refresh     ; How often secondaries check
    retry       ; Retry interval if refresh fails
    expire      ; Stop answering if primary unreachable
    minimum     ; Negative cache TTL
)
```

### Common Records At a Glance

```dns
; A record — name to IP
www     IN  A       192.168.1.100

; CNAME — alias to another name
alias   IN  CNAME   www

; MX — mail server (priority + hostname)
@       IN  MX      10  mail.lab.local.

; NS — name server for this zone
@       IN  NS      ns1.lab.local.

; PTR — reverse lookup (IP to name)
100     IN  PTR     www.lab.local.

; TXT — text data
@       IN  TXT     "v=spf1 mx -all"
```

### Rules to Remember

1. **Trailing dot** on fully qualified names: `ns1.lab.local.` (with dot) is correct in zone files
2. **No trailing dot** on relative names: `www` (BIND adds `.lab.local.` automatically)
3. **Always increment the serial** when changing a zone file
4. **Validate before restarting**: `named-checkconf` + `named-checkzone`
5. **`@`** means "this zone" — equivalent to `lab.local.` in our forward zone

---

---

# Full DNS Deployment Walkthrough — Start to Finish

```bash
# === Prerequisites ===
# Files should already be on the VM (from tar+scp — see web.md Appendix A)
# ls ~/dns/ should show: named.conf.options  named.conf.local  db.lab.local  db.192.168.1

# === Step 1: Install ===
sudo apt update
sudo apt install -y bind9 bind9-utils dnsutils

# === Step 2: Deploy configs ===
sudo cp ~/dns/named.conf.options /etc/bind/named.conf.options
sudo cp ~/dns/named.conf.local /etc/bind/named.conf.local

# === Step 3: Deploy zone files ===
sudo mkdir -p /etc/bind/zones
sudo cp ~/dns/db.lab.local /etc/bind/zones/db.lab.local
sudo cp ~/dns/db.192.168.1 /etc/bind/zones/db.192.168.1
sudo chown -R bind:bind /etc/bind/zones/

# === Step 4: Validate ===
sudo named-checkconf
sudo named-checkzone lab.local /etc/bind/zones/db.lab.local
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/zones/db.192.168.1

# === Step 5: Restart ===
sudo systemctl restart named
sudo systemctl enable named
systemctl is-active named

# === Step 6: Configure DNS resolution ===
sudo cp /etc/resolv.conf /etc/resolv.conf.backup
echo -e "nameserver 127.0.0.1\nnameserver 168.63.129.16" | sudo tee /etc/resolv.conf

# === Step 7: Test ===
dig www.lab.local +short              # Should return 192.168.1.100
dig @127.0.0.1 lab.local MX +short   # Should return mail server
dig -x 192.168.1.100 +short          # Should return www.lab.local
host lab.local                        # Should return the A record
curl http://www.lab.local             # Should return website HTML

# === Step 8: Enable on boot ===
sudo systemctl enable named
```

> **Or use the automated deploy script:**
> ```bash
> sudo bash deploy-lab6.sh
> ```
> This handles both DNS and Nginx installation, configuration, and validation in one shot.

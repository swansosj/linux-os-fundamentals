# Web Server (Nginx) — Complete Lecture Guide

> **Prerequisites:** Students should have completed lessons on systemctl and services (6.1.1, 6.2.1). The lab VM is a Debian server running in Azure.
>
> **Sample files location:** `../lesson6-maintain-system-startup-services/sample-files/`
> The website HTML/CSS, nginx config, and deploy script are all there. Use `tar` + `scp` to transfer them to the Azure VM (see the [Transfer Guide](#appendix-a--packaging-with-tar-and-transferring-with-scp) at the end).

---

# Table of Contents

1. [What is a Web Server?](#1--what-is-a-web-server)
2. [Why Nginx?](#2--why-nginx)
3. [Command Reference — Every Command We Will Use](#3--command-reference--every-command-we-will-use)
4. [Step 1: Installing Nginx](#step-1-installing-nginx)
5. [Step 2: Understanding Nginx File Layout](#step-2-understanding-nginx-file-layout)
6. [Step 3: Managing Nginx with systemctl](#step-3-managing-nginx-with-systemctl)
7. [Step 4: Deploying Website Files](#step-4-deploying-website-files)
8. [Step 5: Configuring a Virtual Host](#step-5-configuring-a-virtual-host)
9. [Step 6: Enabling the Site (Symbolic Links)](#step-6-enabling-the-site-symbolic-links)
10. [Step 7: Testing and Validating](#step-7-testing-and-validating)
11. [Step 8: Viewing Logs](#step-8-viewing-logs)
12. [Basic Troubleshooting](#basic-troubleshooting)
13. [Appendix A — Packaging with tar and Transferring with scp](#appendix-a--packaging-with-tar-and-transferring-with-scp)
14. [Appendix B — Useful Networking Commands](#appendix-b--useful-networking-commands)

---

---

# 1 — What is a Web Server?

A **web server** is software that:

1. **Listens** on a network port (usually port 80 for HTTP, port 443 for HTTPS)
2. **Receives** HTTP requests from clients (web browsers, curl, etc.)
3. **Reads** files from the local filesystem (HTML, CSS, images, etc.)
4. **Sends** the file contents back to the client as an HTTP response

```
┌──────────────┐         HTTP Request          ┌──────────────────────┐
│   Browser    │  ────── GET /index.html ────>  │    Nginx Web Server  │
│  (client)    │                                │  Port 80             │
│              │  <── 200 OK + HTML content ──  │  Reads from disk:    │
│              │                                │  /var/www/lab.local/ │
└──────────────┘         HTTP Response          └──────────────────────┘
```

---

# 2 — Why Nginx?

| Feature | Nginx | Apache |
|---------|-------|--------|
| Performance | Excellent (event-driven) | Good (process/thread-per-connection) |
| Memory usage | Very low | Higher under load |
| Config style | Concise, block-based | XML-like, `.htaccess` files |
| Market share | #1 worldwide | #2 worldwide |
| Available on Debian | Yes (`apt install nginx`) | Yes (`apt install apache2`) |

For this class we use **Nginx** because it's the most widely deployed web server, it's lightweight, and the configuration is clean and easy to understand.

---

---

# 3 — Command Reference — Every Command We Will Use

This section documents every command needed to install, configure, and manage the web server. Read through it first, then follow the step-by-step walkthrough.

---

## `apt` — Package Manager (Install Software)

### What is it?
`apt` is the package manager for Debian/Ubuntu. It downloads, installs, updates, and removes software packages from official repositories.

### Common Usage

```bash
# Update the package list (always run this first)
sudo apt update

# Install one or more packages
sudo apt install nginx

# Install without confirmation prompts
sudo apt install -y nginx

# Remove a package (keeps config files)
sudo apt remove nginx

# Remove a package AND its config files
sudo apt purge nginx

# Upgrade all installed packages
sudo apt upgrade

# Search for a package
apt search nginx

# Show info about a package
apt show nginx

# List installed packages
apt list --installed

# List installed packages matching a pattern
apt list --installed | grep nginx
```

### Common Options

| Option | Meaning |
|--------|---------|
| `-y` | Assume "yes" to all prompts |
| `-qq` | Extra quiet — suppress most output |
| `--no-install-recommends` | Install only the package, not recommended extras |

### Scenario: Install Nginx

```bash
# Step 1: Always update the package list first
sudo apt update

# Step 2: Install nginx
sudo apt install -y nginx

# Step 3: Verify it's installed
apt list --installed | grep nginx
# OR
nginx -v
```

> **Teaching Note:** Always run `sudo apt update` before `sudo apt install`. Without it, the system might try to download packages from outdated URLs and fail.

---

## `systemctl` — Manage Services

### Quick Reference for This Lab

```bash
# Start nginx right now
sudo systemctl start nginx

# Stop nginx right now
sudo systemctl stop nginx

# Restart nginx (stop + start)
sudo systemctl restart nginx

# Reload nginx config without downtime
sudo systemctl reload nginx

# Check if nginx is running
systemctl status nginx
systemctl is-active nginx

# Enable nginx to start on boot
sudo systemctl enable nginx

# Enable AND start right now (two in one)
sudo systemctl enable --now nginx

# Check if enabled on boot
systemctl is-enabled nginx

# See recent logs
sudo journalctl -u nginx -n 30

# Follow logs in real time
sudo journalctl -u nginx -f
```

---

## `nginx -t` — Test Nginx Configuration

### What is it?
Checks the Nginx configuration files for syntax errors **without** restarting or reloading the server. Always run this before reloading.

```bash
# Test the config
sudo nginx -t
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful

# If there's an error, it tells you the file and line number:
# nginx: [emerg] unknown directive "serv_name" in /etc/nginx/sites-enabled/lab.local:5
```

### Workflow: Edit → Test → Reload

```bash
# 1. Edit the config
sudo nano /etc/nginx/sites-available/lab.local

# 2. Test for errors
sudo nginx -t

# 3. Only reload if the test passed
sudo systemctl reload nginx
```

> **Teaching Note:** Never skip `nginx -t`. If you reload a broken config, Nginx will refuse to restart and your website goes down. Test first, reload second.

---

## `curl` — Make HTTP Requests from the Terminal

### What is it?
`curl` (Client URL) sends HTTP requests from the command line. It's how you test a web server without opening a browser.

### Common Usage

```bash
# Fetch a webpage (shows HTML content)
curl http://localhost

# Fetch only the HTTP response headers
curl -I http://localhost

# Verbose mode — see the full HTTP conversation
curl -v http://localhost

# Follow redirects
curl -L http://example.com

# Show only the HTTP status code
curl -s -o /dev/null -w '%{http_code}' http://localhost

# Download a file
curl -O http://example.com/file.tar.gz

# Save output to a file
curl -o page.html http://localhost

# Send a request to a specific IP with a Host header
curl -H "Host: www.lab.local" http://192.168.1.100
```

### Common Options

| Option | Meaning |
|--------|---------|
| `-I` | Fetch headers only (HEAD request) |
| `-v` | Verbose — show request and response headers |
| `-s` | Silent — no progress bar |
| `-o FILE` | Save output to FILE |
| `-O` | Save with the remote filename |
| `-L` | Follow redirects (301, 302) |
| `-H "Header: value"` | Send a custom HTTP header |
| `-w FORMAT` | Write specific info after transfer |

### Scenario: Test If the Website Is Working

```bash
# Quick test — does it return 200?
curl -s -o /dev/null -w '%{http_code}\n' http://localhost
# 200

# See the HTML content
curl http://localhost

# See the full headers
curl -I http://localhost
```

---

## `ss` — Show Network Sockets (What's Listening)

### What is it?
`ss` (socket statistics) shows network connections and listening ports. It replaced the older `netstat` command.

### Common Usage

```bash
# Show all listening TCP ports with process names
sudo ss -tlnp

# Break down the flags:
#   -t  TCP only
#   -l  Listening only (not established connections)
#   -n  Show port numbers (not service names)
#   -p  Show process name and PID

# Check if port 80 is in use
sudo ss -tlnp | grep :80

# Check if port 53 is in use 
sudo ss -tlnp | grep :53

# Show all listening ports (TCP and UDP)
sudo ss -tulnp

# Show established connections
sudo ss -tnp
```

### Reading the Output

```
State     Recv-Q    Send-Q    Local Address:Port    Peer Address:Port    Process
LISTEN    0         511       0.0.0.0:80            0.0.0.0:*            users:(("nginx",pid=1235,fd=6))
```

| Field | Meaning |
|-------|---------|
| State | LISTEN = waiting for connections |
| Local Address:Port | 0.0.0.0:80 = listening on all interfaces, port 80 |
| Process | nginx, PID 1235 |

### Scenario: Verify Nginx Is Listening on Port 80

```bash
sudo ss -tlnp | grep :80
# LISTEN  0  511  0.0.0.0:80  0.0.0.0:*  users:(("nginx",pid=1235,fd=6))
# If no output → nginx is not listening → check systemctl status nginx
```

---

## `ln` — Create Links (Symbolic Links for Nginx)

### Why is this here?
Nginx uses symbolic links to enable/disable sites:
- **Available sites** live in `/etc/nginx/sites-available/` (the config file)
- **Enabled sites** are symlinks in `/etc/nginx/sites-enabled/` pointing to sites-available

```bash
# Enable a site (create the symlink)
sudo ln -s /etc/nginx/sites-available/lab.local /etc/nginx/sites-enabled/lab.local

# Disable a site (remove the symlink — does NOT delete the config)
sudo rm /etc/nginx/sites-enabled/lab.local

# Verify the symlink
ls -la /etc/nginx/sites-enabled/
```

---

## `mkdir` — Create Directories

```bash
# Create the document root for our website
sudo mkdir -p /var/www/lab.local/css

# -p creates parent directories if they don't exist
# Without -p, you'd get an error if /var/www/ didn't exist
```

---

## `cp` — Copy Files

```bash
# Copy a file
sudo cp index.html /var/www/lab.local/

# Copy multiple files
sudo cp *.html /var/www/lab.local/

# Copy a directory recursively
sudo cp -r website/ /var/www/lab.local/

# Common options:
#   -r   Recursive (for directories)
#   -v   Verbose (show each file copied)
#   -i   Interactive (ask before overwriting)
```

---

## `chown` — Change File Ownership

### What is it?
Changes the owner and/or group of files. The web server runs as the `www-data` user, so website files need to be owned by `www-data`.

```bash
# Change owner to www-data, group to www-data
sudo chown www-data:www-data /var/www/lab.local/index.html

# Change ownership recursively (entire website directory)
sudo chown -R www-data:www-data /var/www/lab.local/

# Syntax: chown USER:GROUP FILE
# -R = recursive (all files and subdirectories)
```

### Why This Matters

```bash
# Nginx runs as the www-data user
ps aux | grep nginx
# www-data  1236  ... nginx: worker process

# Worker processes need READ permission on website files
# If files are owned by root with 700 permissions, www-data can't read them → 403 Forbidden
```

---

## `chmod` — Change File Permissions

```bash
# Set standard web permissions
# Directories: 755 (owner=rwx, group=rx, others=rx)
sudo find /var/www/lab.local -type d -exec chmod 755 {} \;

# Files: 644 (owner=rw, group=r, others=r)
sudo find /var/www/lab.local -type f -exec chmod 644 {} \;
```

---

---

# Step 1: Installing Nginx

### On the Azure VM:

```bash
# Update package lists
sudo apt update

# Install nginx
sudo apt install -y nginx

# Verify installation
nginx -v
# nginx version: nginx/1.22.1

# Check the package is installed
dpkg -l | grep nginx
```

### What just happened?

`apt` downloaded the nginx package from the Debian repository and:
- Installed the binary to `/usr/sbin/nginx`
- Created the config directory at `/etc/nginx/`
- Created a systemd unit file at `/lib/systemd/system/nginx.service`
- Created the default document root at `/var/www/html/`
- Started the service automatically

### Verify it's running

```bash
# Check status
systemctl status nginx

# Is it listening on port 80?
sudo ss -tlnp | grep :80

# Test with curl
curl http://localhost
# (shows the default Nginx welcome page HTML)
```

> **Live Demo Point:** Open a browser and navigate to `http://<VM-PUBLIC-IP>`. You should see the default Nginx welcome page. This proves the web server is installed and running.
>
> **Azure Note:** Make sure NSG (Network Security Group) rules allow inbound TCP port 80. The Azure VM needs to allow HTTP traffic.

---

# Step 2: Understanding Nginx File Layout

```bash
# Show the full directory tree
find /etc/nginx -type f | sort
```

| Path | Purpose |
|------|---------|
| `/etc/nginx/nginx.conf` | **Main** config file — usually don't edit this |
| `/etc/nginx/sites-available/` | Virtual host configs (available but not necessarily active) |
| `/etc/nginx/sites-enabled/` | **Symlinks** to configs that are active |
| `/etc/nginx/sites-enabled/default` | Default site (the welcome page) |
| `/var/www/html/` | Default document root |
| `/var/www/lab.local/` | **Our** document root (we'll create this) |
| `/var/log/nginx/access.log` | Global access log |
| `/var/log/nginx/error.log` | Global error log |
| `/usr/sbin/nginx` | The nginx binary |
| `/lib/systemd/system/nginx.service` | The systemd unit file |

### The sites-available / sites-enabled Pattern

```
/etc/nginx/sites-available/          /etc/nginx/sites-enabled/
├── default                          ├── default → ../sites-available/default
├── lab.local    ←── real config     └── lab.local → ../sites-available/lab.local
└── other-site                                        ↑ symlink = enabled
                                                      
    "All configs live here"          "Only symlinked configs are active"
```

```bash
# See the symlinks
ls -la /etc/nginx/sites-enabled/
# default -> /etc/nginx/sites-available/default
```

> **Teaching Note:** This is the same symlink concept from lesson 6.1.1. Enabling a site = creating a symlink. Disabling a site = removing the symlink. The config file itself stays safe in `sites-available/`.

---

# Step 3: Managing Nginx with systemctl

```bash
# Check current status
systemctl status nginx

# Stop it (website goes down)
sudo systemctl stop nginx
curl http://localhost        # Connection refused!

# Start it (website comes back)
sudo systemctl start nginx
curl http://localhost        # 200 OK

# Restart (stop + start — brief downtime)
sudo systemctl restart nginx

# Reload (re-read config — NO downtime)
sudo systemctl reload nginx

# Enable on boot (survives reboot)
sudo systemctl enable nginx

# Check boot status
systemctl is-enabled nginx
# enabled
```

### The Reload Workflow

Reload is preferred over restart because it doesn't drop existing connections:

```bash
# 1. Edit a config file
sudo nano /etc/nginx/sites-available/lab.local

# 2. Always test first!
sudo nginx -t
# nginx: ... syntax is ok
# nginx: ... test is successful

# 3. Reload (zero downtime)
sudo systemctl reload nginx
```

---

# Step 4: Deploying Website Files

We have a complete website in our sample files. Let's deploy it to the server.

### Create the Document Root

```bash
# Create the directory for our website
sudo mkdir -p /var/www/lab.local/css
```

### Option A: Copy Files Directly (If You're Already on the Server)

```bash
# Assuming you SCP'd the sample-files to ~/sample-files/
sudo cp ~/sample-files/website/*.html /var/www/lab.local/
sudo cp ~/sample-files/website/css/style.css /var/www/lab.local/css/
```

### Option B: Use tar + scp (Covered in Appendix A)

```bash
# On your LOCAL machine — create a tarball
cd lesson6-maintain-system-startup-services/sample-files/
tar -czf lab-website.tar.gz website/ nginx/ dns/

# Transfer to the VM
scp lab-website.tar.gz student@<VM-IP>:~/

# On the VM — extract 
cd ~
tar -xzf lab-website.tar.gz

# Deploy the website files
sudo cp website/*.html /var/www/lab.local/
sudo cp website/css/style.css /var/www/lab.local/css/
```

### Set Ownership and Permissions

```bash
# Nginx runs as www-data, so give it ownership
sudo chown -R www-data:www-data /var/www/lab.local/

# Set proper permissions
sudo find /var/www/lab.local -type d -exec chmod 755 {} \;
sudo find /var/www/lab.local -type f -exec chmod 644 {} \;

# Verify
ls -la /var/www/lab.local/
# All files should show: -rw-r--r-- www-data www-data

ls -la /var/www/lab.local/css/
```

### Verify the Files Are There

```bash
find /var/www/lab.local -type f
# /var/www/lab.local/index.html
# /var/www/lab.local/about.html
# /var/www/lab.local/network.html
# /var/www/lab.local/services.html
# /var/www/lab.local/info.html
# /var/www/lab.local/404.html
# /var/www/lab.local/css/style.css
```

---

# Step 5: Configuring a Virtual Host

A **virtual host** (called a "server block" in Nginx) tells Nginx how to handle requests for a specific domain.

### Our Config: `/etc/nginx/sites-available/lab.local`

```bash
# Copy our config to the proper location
sudo cp ~/nginx/lab.local /etc/nginx/sites-available/lab.local
```

Let's walk through what each line does:

```nginx
server {
    # Listen on port 80 for both IPv4 and IPv6
    listen 80;
    listen [::]:80;

    # What hostnames this server block responds to
    # If the browser sends Host: www.lab.local, this block handles it
    server_name lab.local www.lab.local web.lab.local;

    # Where the website files live on disk
    root /var/www/lab.local;
    
    # Default file to serve when someone visits a directory
    index index.html;

    # Separate log files for this site (not the global ones)
    access_log /var/log/nginx/lab.local.access.log;
    error_log  /var/log/nginx/lab.local.error.log;

    # Main location block — how to handle requests for /
    location / {
        # Try: exact file → directory → return 404 error
        try_files $uri $uri/ =404;
    }

    # Custom 404 error page
    error_page 404 /404.html;
    location = /404.html {
        internal;    # Can't be accessed directly, only on 404 errors
    }

    # Add custom headers to the info page (for teaching HTTP headers)
    location = /info.html {
        add_header X-Served-By "Nginx on Debian";
        add_header X-Lab "FSCJ Linux Fundamentals";
        try_files $uri =404;
    }

    # Security: deny access to hidden files (like .htaccess, .git)
    location ~ /\. {
        deny all;
    }
}
```

### Key Config Directives Explained

| Directive | Purpose | Example |
|-----------|---------|---------|
| `listen` | What port to listen on | `listen 80;` |
| `server_name` | What domain names this block handles | `server_name www.lab.local;` |
| `root` | Where website files are on disk | `root /var/www/lab.local;` |
| `index` | Default file for directory requests | `index index.html;` |
| `access_log` | Where to log successful requests | Path to log file |
| `error_log` | Where to log errors | Path to log file |
| `location` | URL pattern matching block | `location / { ... }` |
| `try_files` | Try files in order, fall back to last option | `try_files $uri =404;` |
| `error_page` | Custom error pages | `error_page 404 /404.html;` |
| `add_header` | Add custom HTTP response headers | `add_header X-Lab "value";` |

---

# Step 6: Enabling the Site (Symbolic Links)

This is where symlinks from lesson 6.1.1 come back:

```bash
# Step 1: Create a symlink from sites-available to sites-enabled
sudo ln -s /etc/nginx/sites-available/lab.local /etc/nginx/sites-enabled/lab.local

# Step 2: Remove the default site (so it doesn't conflict on port 80)
sudo rm /etc/nginx/sites-enabled/default

# Step 3: Verify the symlinks
ls -la /etc/nginx/sites-enabled/
# lab.local -> /etc/nginx/sites-available/lab.local

# Step 4: Test the configuration
sudo nginx -t
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful

# Step 5: Reload nginx (zero downtime)
sudo systemctl reload nginx
```

### What if nginx -t Fails?

```bash
sudo nginx -t
# nginx: [emerg] unknown directive "sever_name" in /etc/nginx/sites-enabled/lab.local:5
# nginx: configuration file /etc/nginx/nginx.conf test failed

# The error tells you:
# - File: /etc/nginx/sites-enabled/lab.local
# - Line: 5
# - Problem: "sever_name" is misspelled (should be "server_name")

# Fix it:
sudo nano /etc/nginx/sites-available/lab.local
# Go to line 5, fix the typo
# Test again:
sudo nginx -t
```

---

# Step 7: Testing and Validating

### From the Server Itself

```bash
# Test with curl — does it return 200?
curl -s -o /dev/null -w '%{http_code}\n' http://localhost
# 200

# See the HTML content
curl http://localhost | head -20

# Check response headers
curl -I http://localhost
# HTTP/1.1 200 OK
# Server: nginx/1.22.1

# Test the custom headers on /info.html
curl -I http://localhost/info.html
# X-Served-By: Nginx on Debian
# X-Lab: FSCJ Linux Fundamentals

# Test the 404 page
curl http://localhost/nonexistent
# (should show our custom 404 page)

# Test specific pages
curl -s -o /dev/null -w '%{http_code}\n' http://localhost/about.html
curl -s -o /dev/null -w '%{http_code}\n' http://localhost/network.html
curl -s -o /dev/null -w '%{http_code}\n' http://localhost/services.html
```

### From a Browser

Open `http://<VM-PUBLIC-IP>` in a web browser. You should see the full lab website with:
- Home page with links to all sections
- "How the Web Works" page
- "DNS & Networking" page
- "systemd Services" page
- "Server Info" page

### From Another Machine (Using the VM's IP)

```bash
# Test from your local machine using the Azure VM public IP
curl http://<VM-PUBLIC-IP>
```

> **Azure Note:** Ensure the Azure NSG allows inbound TCP port 80. If the browser times out, the firewall is likely blocking it.

---

# Step 8: Viewing Logs

### Access Logs (Successful Requests)

```bash
# View recent access log entries
sudo tail -20 /var/log/nginx/lab.local.access.log

# Follow the log in real time (watch as people browse)
sudo tail -f /var/log/nginx/lab.local.access.log

# Search for specific patterns
sudo grep "404" /var/log/nginx/lab.local.access.log
sudo grep "GET /about" /var/log/nginx/lab.local.access.log
```

### Reading an Access Log Line

```
192.168.1.50 - - [01/Mar/2026:15:00:00 +0000] "GET /index.html HTTP/1.1" 200 5432 "-" "Mozilla/5.0"
│              │  │                            │                          │   │     │   │
│              │  │                            │                          │   │     │   └─ User-Agent
│              │  │                            │                          │   │     └─ Referrer
│              │  │                            │                          │   └─ Bytes sent
│              │  │                            │                          └─ Status code
│              │  │                            └─ Request line (method, path, protocol)
│              │  └─ Timestamp
│              └─ Remote user (- = none)
└─ Client IP address
```

### Error Logs

```bash
# View recent errors
sudo tail -20 /var/log/nginx/lab.local.error.log

# Follow errors in real time
sudo tail -f /var/log/nginx/lab.local.error.log

# View via systemd journal
sudo journalctl -u nginx -n 30
sudo journalctl -u nginx -f
```

---

---

# Basic Troubleshooting

A simple decision tree for when things aren't working:

## Problem: Browser Shows "Connection Refused" or Times Out

```bash
# Is nginx running?
systemctl is-active nginx
# If "inactive" → sudo systemctl start nginx

# Is nginx listening on port 80?
sudo ss -tlnp | grep :80
# If no output → nginx isn't listening → check config

# Is the firewall blocking it?
sudo ufw status
# If active, allow HTTP:
sudo ufw allow 80/tcp

# Azure: Is the NSG allowing port 80 inbound?
# Check in Azure Portal → VM → Networking → Inbound rules
```

## Problem: Browser Shows "403 Forbidden"

```bash
# Check file ownership
ls -la /var/www/lab.local/
# Files should be owned by www-data:www-data

# Fix ownership
sudo chown -R www-data:www-data /var/www/lab.local/

# Check permissions
# Directories need at least 755 (r-x for others)
# Files need at least 644 (r-- for others)
sudo find /var/www/lab.local -type d -exec chmod 755 {} \;
sudo find /var/www/lab.local -type f -exec chmod 644 {} \;
```

## Problem: Browser Shows Default Nginx Page Instead of Our Site

```bash
# Check that the default site is removed from sites-enabled
ls -la /etc/nginx/sites-enabled/
# Should show lab.local but NOT default

# If default is still there:
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl reload nginx

# Check that our site is enabled
ls -la /etc/nginx/sites-enabled/lab.local
# Should be a symlink to sites-available/lab.local
```

## Problem: nginx -t Reports Errors

```bash
# Run the test
sudo nginx -t

# Common errors:
# "unexpected end of file" → missing closing brace }
# "unknown directive" → typo in a directive name
# "duplicate listen" → two server blocks on the same port/server_name
# "could not open error log" → directory doesn't exist

# Fix the config and test again
sudo nano /etc/nginx/sites-available/lab.local
sudo nginx -t
```

## Problem: Nginx Won't Start After Editing Config

```bash
# Check what went wrong
sudo journalctl -u nginx -n 20

# Test the config
sudo nginx -t

# If you can't figure out the error, restore the backup:
sudo cp /etc/nginx/sites-available/lab.local.backup /etc/nginx/sites-available/lab.local
sudo nginx -t
sudo systemctl start nginx
```

### Troubleshooting Quick Reference

| Symptom | First Command | Likely Cause |
|---------|---------------|-------------|
| Connection refused | `systemctl is-active nginx` | Nginx not running |
| Connection times out | `sudo ss -tlnp \| grep :80` | Firewall / NSG blocking port 80 |
| 403 Forbidden | `ls -la /var/www/lab.local/` | Bad ownership or permissions |
| 404 Not Found | `ls /var/www/lab.local/` | File doesn't exist or wrong `root` path |
| Default page shows | `ls -la /etc/nginx/sites-enabled/` | Default site not removed or our site not linked |
| Config error | `sudo nginx -t` | Syntax error in config file |
| Can't start/reload | `sudo journalctl -u nginx -n 20` | Check the log for details |

---

---

# Appendix A — Packaging with tar and Transferring with scp

These commands let you bundle files on one machine and transfer them to another — essential for deploying configs and website files to your Azure lab VM.

---

## `tar` — Tape Archive (Create and Extract Archives)

### What is it?
`tar` bundles multiple files and directories into a single archive file. Combined with gzip compression, it creates `.tar.gz` files (also called "tarballs").

### Common Usage

```bash
# CREATE a compressed archive
tar -czf archive_name.tar.gz folder_or_files

# Flags breakdown:
#   -c   Create a new archive
#   -z   Compress with gzip (.gz)
#   -f   Filename of the archive (must be last flag before the name)
#   -v   Verbose — show files being added (optional)

# EXTRACT a compressed archive
tar -xzf archive_name.tar.gz

# Flags breakdown:
#   -x   Extract
#   -z   Decompress gzip
#   -f   Filename to extract

# LIST contents of an archive (without extracting)
tar -tzf archive_name.tar.gz
```

### Common Options

| Flags | Meaning |
|-------|---------|
| `-c` | **C**reate an archive |
| `-x` | E**x**tract an archive |
| `-t` | Lis**t** contents (don't extract) |
| `-z` | Compress/decompress with g**z**ip |
| `-f NAME` | **F**ile — archive name (always needed) |
| `-v` | **V**erbose — list files processed |
| `-C DIR` | Change to DIR before extracting |

### Scenario: Package the Lab Files for Transfer

```bash
# On your LOCAL machine, navigate to the sample-files directory
cd lesson6-maintain-system-startup-services/sample-files/

# Create a tarball of everything we need
tar -czvf lab-server-files.tar.gz website/ nginx/ dns/ deploy-lab6.sh

# Verify what's in the archive
tar -tzf lab-server-files.tar.gz
# website/index.html
# website/about.html
# website/network.html
# website/services.html
# website/info.html
# website/404.html
# website/css/style.css
# nginx/lab.local
# dns/named.conf.options
# dns/named.conf.local
# dns/db.lab.local
# dns/db.192.168.1
# deploy-lab6.sh

# Check the file size
ls -lh lab-server-files.tar.gz
```

### Scenario: Extract Files on the Server

```bash
# On the Azure VM (after scp transfer)
cd ~

# Extract the tarball
tar -xzvf lab-server-files.tar.gz

# Files are now in ~/website/, ~/nginx/, ~/dns/
ls -la website/
ls -la nginx/
ls -la dns/
```

### Scenario: Extract to a Specific Directory

```bash
# Extract directly to /tmp
tar -xzf lab-server-files.tar.gz -C /tmp/

# Files are now in /tmp/website/, /tmp/nginx/, etc.
```

---

## `scp` — Secure Copy (Transfer Files Over SSH)

### What is it?
`scp` copies files between machines over SSH. It uses the same authentication as SSH (password or key), and all data is encrypted in transit.

### Basic Syntax

```
scp [OPTIONS] SOURCE DESTINATION
```

Where SOURCE or DESTINATION can be local paths or `user@host:path` for remote machines.

### Common Usage

```bash
# Copy a single file TO a remote server
scp file.txt student@20.84.43.108:~/

# Copy a single file FROM a remote server
scp student@20.84.43.108:~/file.txt ./

# Copy a directory recursively
scp -r website/ student@20.84.43.108:~/

# Copy with a custom SSH port
scp -P 2222 file.txt student@20.84.43.108:~/

# Copy with a specific SSH key
scp -i ~/.ssh/mykey.pem file.txt student@20.84.43.108:~/
```

### Common Options

| Option | Meaning |
|--------|---------|
| `-r` | **R**ecursive — copy entire directories |
| `-P PORT` | Use a custom SSH **P**ort (capital P, unlike ssh -p) |
| `-i KEYFILE` | Use a specific SSH key for authentication |
| `-v` | **V**erbose — show detailed transfer info |
| `-C` | **C**ompress data during transfer |

### Scenario: Transfer the Lab Tarball to the Azure VM

```bash
# On your LOCAL machine
# Step 1: Create the tarball
cd lesson6-maintain-system-startup-services/sample-files/
tar -czf lab-server-files.tar.gz website/ nginx/ dns/ deploy-lab6.sh

# Step 2: SCP it to the Azure VM
scp lab-server-files.tar.gz student@20.84.43.108:~/
# Enter password when prompted
# lab-server-files.tar.gz          100%   15KB   1.2MB/s   00:00

# Step 3: SSH into the VM
ssh student@20.84.43.108

# Step 4: Extract on the VM
cd ~
tar -xzf lab-server-files.tar.gz
ls -la website/ nginx/ dns/
```

### Scenario: Copy an Entire Directory

```bash
# Copy the website directory recursively
scp -r website/ student@20.84.43.108:~/website/

# Copy multiple files
scp config.conf deploy.sh student@20.84.43.108:~/
```

### tar + scp vs scp -r: Which is Better?

| Method | Pros | Cons |
|--------|------|------|
| `tar` + `scp` | Faster (one file transfer), preserves permissions | Extra steps (create, transfer, extract) |
| `scp -r` | Simpler (one command) | Slower for many files, may lose some permissions |

> **Teaching Note:** For transferring more than a handful of files, always use tar + scp. It's a single network transfer of one compressed file, which is much faster than copying hundreds of individual files. This is the standard practice in system administration.

---

---

# Appendix B — Useful Networking Commands

These commands help verify the web server is reachable and diagnose networking issues.

```bash
# Check your VM's IP address
ip addr show
# Look for the "inet" line on eth0 (e.g., 10.0.0.4/24)

# Short version
hostname -I

# Check if a port is open from another machine
# (Run from your local machine, not the VM)
nc -zv <VM-PUBLIC-IP> 80

# Test HTTP from the server itself
curl http://localhost
curl -I http://localhost

# Watch live connections
watch -n 1 'sudo ss -tnp | grep :80'

# Check DNS resolution 
dig www.lab.local
nslookup www.lab.local

# Check the routing table
ip route show

# Check what process owns a port
sudo lsof -i :80
```

---

---

# Full Deployment Walkthrough — Start to Finish

If you want to run through the entire web server setup in one go, here's the condensed version:

```bash
# === ON YOUR LOCAL MACHINE ===

# 1. Package the files
cd lesson6-maintain-system-startup-services/sample-files/
tar -czf lab-server-files.tar.gz website/ nginx/ dns/ deploy-lab6.sh

# 2. Transfer to Azure VM
scp lab-server-files.tar.gz student@<VM-IP>:~/

# 3. SSH into the VM
ssh student@<VM-IP>

# === ON THE AZURE VM ===

# 4. Extract files
cd ~
tar -xzf lab-server-files.tar.gz

# 5. Install nginx
sudo apt update
sudo apt install -y nginx

# 6. Deploy website
sudo mkdir -p /var/www/lab.local/css
sudo cp website/*.html /var/www/lab.local/
sudo cp website/css/style.css /var/www/lab.local/css/
sudo chown -R www-data:www-data /var/www/lab.local/
sudo find /var/www/lab.local -type d -exec chmod 755 {} \;
sudo find /var/www/lab.local -type f -exec chmod 644 {} \;

# 7. Deploy nginx config
sudo cp nginx/lab.local /etc/nginx/sites-available/lab.local
sudo ln -s /etc/nginx/sites-available/lab.local /etc/nginx/sites-enabled/lab.local
sudo rm -f /etc/nginx/sites-enabled/default

# 8. Test and reload
sudo nginx -t
sudo systemctl reload nginx

# 9. Verify
curl -s -o /dev/null -w '%{http_code}\n' http://localhost
# 200

# 10. Enable on boot
sudo systemctl enable nginx
```

> **Or use the automated deploy script:**
> ```bash
> sudo bash deploy-lab6.sh
> ```
> This script does everything above plus the DNS setup — see the [DNS Guide](dns.md) for details.

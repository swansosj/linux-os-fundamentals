#!/usr/bin/env bash
# ============================================================================
#  deploy-lab6.sh — FSCJ Linux Fundamentals — Lesson 6.2.1
#  Master deployment script: BIND9 DNS + Nginx Web Server + Demo Website
#
#  USAGE:
#    1. SCP the entire sample-files/ directory to your Debian server
#    2. Run: sudo bash deploy-lab6.sh
#    3. (Optional) Edit SERVER_IP below if not 192.168.1.100
#
#  WHAT THIS SCRIPT DOES:
#    - Installs BIND9 and Nginx (apt)
#    - Deploys DNS zone files for lab.local
#    - Deploys Nginx virtual host config
#    - Deploys the demo website to /var/www/lab.local/
#    - Enables and starts both services
#    - Validates everything is working
# ============================================================================

set -euo pipefail

# ────────────────────────────────────────────
# CONFIGURATION — EDIT THESE IF NEEDED
# ────────────────────────────────────────────
SERVER_IP="${SERVER_IP:-192.168.1.100}"
DOMAIN="lab.local"
WEB_ROOT="/var/www/${DOMAIN}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ────────────────────────────────────────────
# COLOR OUTPUT
# ────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[  OK]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
fail()    { echo -e "${RED}[FAIL]${NC}  $*"; }

# ────────────────────────────────────────────
# PREFLIGHT CHECKS
# ────────────────────────────────────────────
echo ""
echo "============================================"
echo "  FSCJ Lab 6.2.1 — Full Deployment Script"
echo "============================================"
echo ""

# Must be root
if [[ $EUID -ne 0 ]]; then
    fail "This script must be run as root (use: sudo bash deploy-lab6.sh)"
    exit 1
fi

# Must be Debian/Ubuntu
if ! command -v apt &>/dev/null; then
    fail "This script requires a Debian-based system (apt not found)."
    exit 1
fi

# Check that sample-files directories exist
for dir in dns nginx website; do
    if [[ ! -d "${SCRIPT_DIR}/${dir}" ]]; then
        fail "Missing directory: ${SCRIPT_DIR}/${dir}"
        fail "Make sure you're running from the sample-files/ directory."
        exit 1
    fi
done

info "Server IP: ${SERVER_IP}"
info "Domain:    ${DOMAIN}"
info "Web Root:  ${WEB_ROOT}"
echo ""

# ────────────────────────────────────────────
# STEP 1: UPDATE PACKAGES
# ────────────────────────────────────────────
info "Updating package lists..."
apt update -qq
success "Package lists updated."

# ────────────────────────────────────────────
# STEP 2: INSTALL BIND9
# ────────────────────────────────────────────
info "Installing BIND9 DNS server..."
apt install -y -qq bind9 bind9-utils bind9-dnsutils > /dev/null
success "BIND9 installed."

# ────────────────────────────────────────────
# STEP 3: DEPLOY DNS CONFIGURATION
# ────────────────────────────────────────────
info "Deploying DNS configuration..."

# Backup originals if they exist
for f in named.conf.options named.conf.local; do
    if [[ -f "/etc/bind/${f}" ]]; then
        cp "/etc/bind/${f}" "/etc/bind/${f}.backup.$(date +%s)"
    fi
done

# Copy config files
cp "${SCRIPT_DIR}/dns/named.conf.options" /etc/bind/named.conf.options
cp "${SCRIPT_DIR}/dns/named.conf.local"   /etc/bind/named.conf.local

# Create zones directory and copy zone files
mkdir -p /etc/bind/zones
cp "${SCRIPT_DIR}/dns/db.lab.local"   /etc/bind/zones/db.lab.local
cp "${SCRIPT_DIR}/dns/db.192.168.1"   /etc/bind/zones/db.192.168.1

# Replace placeholder IP with actual server IP
if [[ "${SERVER_IP}" != "192.168.1.100" ]]; then
    warn "Replacing 192.168.1.100 with ${SERVER_IP} in zone files..."
    sed -i "s/192.168.1.100/${SERVER_IP}/g" /etc/bind/zones/db.lab.local
    sed -i "s/192.168.1.100/${SERVER_IP}/g" /etc/bind/named.conf.local

    # Reverse zone needs more careful handling
    REVERSE_ZONE=$(echo "${SERVER_IP}" | awk -F. '{print $3"."$2"."$1}')
    LAST_OCTET=$(echo "${SERVER_IP}" | awk -F. '{print $4}')
    FIRST_THREE=$(echo "${SERVER_IP}" | awk -F. '{print $1"."$2"."$3}')

    sed -i "s/1.168.192/${REVERSE_ZONE}/g" /etc/bind/named.conf.local
    sed -i "s/db\.192\.168\.1/db.${FIRST_THREE}/g" /etc/bind/named.conf.local

    # Copy + rename reverse zone file if needed
    if [[ "${FIRST_THREE}" != "192.168.1" ]]; then
        cp /etc/bind/zones/db.192.168.1 "/etc/bind/zones/db.${FIRST_THREE}"
        rm /etc/bind/zones/db.192.168.1
        sed -i "s/100/${LAST_OCTET}/g" "/etc/bind/zones/db.${FIRST_THREE}"
    fi
fi

# Set ownership
chown -R bind:bind /etc/bind/zones

# Validate DNS config
info "Validating DNS configuration..."
if named-checkconf; then
    success "named-checkconf passed."
else
    fail "named-checkconf FAILED — check your config files."
    exit 1
fi

if named-checkzone lab.local /etc/bind/zones/db.lab.local; then
    success "Forward zone validated."
else
    fail "Forward zone validation FAILED."
    exit 1
fi

success "DNS configuration deployed."

# ────────────────────────────────────────────
# STEP 4: START AND ENABLE BIND9
# ────────────────────────────────────────────
info "Starting BIND9..."
systemctl enable bind9 --now
systemctl restart bind9
sleep 2

if systemctl is-active --quiet bind9; then
    success "BIND9 is running."
else
    fail "BIND9 failed to start. Check: journalctl -u bind9 -n 20"
    exit 1
fi

# ────────────────────────────────────────────
# STEP 5: INSTALL NGINX
# ────────────────────────────────────────────
info "Installing Nginx web server..."
apt install -y -qq nginx > /dev/null
success "Nginx installed."

# ────────────────────────────────────────────
# STEP 6: DEPLOY WEBSITE FILES
# ────────────────────────────────────────────
info "Deploying website to ${WEB_ROOT}..."

mkdir -p "${WEB_ROOT}/css"
cp "${SCRIPT_DIR}"/website/*.html "${WEB_ROOT}/"
cp "${SCRIPT_DIR}"/website/css/style.css "${WEB_ROOT}/css/"

# Set ownership and permissions
chown -R www-data:www-data "${WEB_ROOT}"
find "${WEB_ROOT}" -type d -exec chmod 755 {} \;
find "${WEB_ROOT}" -type f -exec chmod 644 {} \;

success "Website deployed ($(find "${WEB_ROOT}" -type f | wc -l) files)."

# ────────────────────────────────────────────
# STEP 7: DEPLOY NGINX VIRTUAL HOST
# ────────────────────────────────────────────
info "Deploying Nginx virtual host..."

cp "${SCRIPT_DIR}/nginx/lab.local" /etc/nginx/sites-available/lab.local

# Create the symlink (enable the site)
ln -sf /etc/nginx/sites-available/lab.local /etc/nginx/sites-enabled/lab.local

# Remove default site if it exists (avoids conflict on port 80)
if [[ -L /etc/nginx/sites-enabled/default ]]; then
    rm /etc/nginx/sites-enabled/default
    info "Removed default Nginx site."
fi

# Validate Nginx config
info "Validating Nginx configuration..."
if nginx -t 2>&1; then
    success "nginx -t passed."
else
    fail "nginx -t FAILED — check your config."
    exit 1
fi

success "Nginx virtual host deployed."

# ────────────────────────────────────────────
# STEP 8: START AND ENABLE NGINX
# ────────────────────────────────────────────
info "Starting Nginx..."
systemctl enable nginx --now
systemctl restart nginx
sleep 1

if systemctl is-active --quiet nginx; then
    success "Nginx is running."
else
    fail "Nginx failed to start. Check: journalctl -u nginx -n 20"
    exit 1
fi

# ────────────────────────────────────────────
# STEP 9: CONFIGURE LOCAL DNS RESOLUTION
# ────────────────────────────────────────────
info "Configuring /etc/resolv.conf to use local DNS..."

# Add our DNS server to resolv.conf (prepend)
if ! grep -q "nameserver.*${SERVER_IP}" /etc/resolv.conf 2>/dev/null; then
    # Save original
    cp /etc/resolv.conf /etc/resolv.conf.backup.$(date +%s)
    # Prepend our nameserver
    {
        echo "nameserver ${SERVER_IP}"
        echo "search ${DOMAIN}"
        cat /etc/resolv.conf
    } > /tmp/resolv.conf.new
    mv /tmp/resolv.conf.new /etc/resolv.conf
    success "Local DNS added to resolv.conf."
else
    info "resolv.conf already points to ${SERVER_IP}."
fi

# Also add to /etc/hosts as a fallback
if ! grep -q "${DOMAIN}" /etc/hosts 2>/dev/null; then
    echo "${SERVER_IP}  ${DOMAIN} www.${DOMAIN} ns1.${DOMAIN}" >> /etc/hosts
    info "Added ${DOMAIN} entries to /etc/hosts."
fi

# ────────────────────────────────────────────
# STEP 10: VALIDATION
# ────────────────────────────────────────────
echo ""
echo "============================================"
echo "  VALIDATION"
echo "============================================"
echo ""

PASS=0
TOTAL=0

run_check() {
    local desc="$1"
    local cmd="$2"
    ((TOTAL++))
    if eval "$cmd" &>/dev/null; then
        success "$desc"
        ((PASS++))
    else
        fail "$desc"
    fi
}

run_check "BIND9 is active"             "systemctl is-active --quiet bind9"
run_check "Nginx is active"             "systemctl is-active --quiet nginx"
run_check "BIND9 is enabled (boot)"     "systemctl is-enabled --quiet bind9"
run_check "Nginx is enabled (boot)"     "systemctl is-enabled --quiet nginx"
run_check "Port 53 is listening"        "ss -tlnp | grep -q ':53 '"
run_check "Port 80 is listening"        "ss -tlnp | grep -q ':80 '"
run_check "DNS resolves www.lab.local"  "dig @127.0.0.1 www.${DOMAIN} +short | grep -q '[0-9]'"
run_check "HTTP returns 200 OK"         "curl -s -o /dev/null -w '%{http_code}' http://localhost | grep -q 200"
run_check "Website has content"         "curl -s http://localhost | grep -qi 'linux lab'"
run_check "Custom 404 page works"       "curl -s http://localhost/nonexistent | grep -qi '404'"

echo ""
echo "============================================"
echo "  Results: ${PASS}/${TOTAL} checks passed"
echo "============================================"
echo ""

if [[ ${PASS} -eq ${TOTAL} ]]; then
    success "ALL CHECKS PASSED — Lab is fully deployed!"
else
    warn "Some checks failed. See above for details."
fi

echo ""
info "Useful commands:"
echo "  systemctl status nginx       — Check web server"
echo "  systemctl status bind9       — Check DNS server"
echo "  dig @localhost www.lab.local  — Test DNS"
echo "  curl http://localhost         — Test website"
echo "  sudo journalctl -u nginx -f  — Follow web logs"
echo "  sudo journalctl -u bind9 -f  — Follow DNS logs"
echo ""

if [[ "${SERVER_IP}" == "192.168.1.100" ]]; then
    warn "You're using the default IP (192.168.1.100)."
    warn "If your server has a different IP, re-run with:"
    echo "  sudo SERVER_IP=<your-ip> bash deploy-lab6.sh"
fi

echo ""
success "Done! Open http://www.${DOMAIN} (or http://${SERVER_IP}) in a browser."
echo ""

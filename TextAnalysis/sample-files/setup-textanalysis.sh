#!/bin/bash
# ============================================================
# Setup Script for Text Analysis Lab
# Creates ~/textlab/ with all sample files for hands-on practice
# ============================================================

LAB_DIR="$HOME/textlab"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================="
echo "  Setting up Text Analysis Lab Environment"
echo "============================================="
echo ""

# Create lab directory
if [ -d "$LAB_DIR" ]; then
    echo "[!] $LAB_DIR already exists."
    read -p "    Remove and recreate? (y/n): " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        rm -rf "$LAB_DIR"
        echo "    Removed old lab directory."
    else
        echo "    Exiting without changes."
        exit 0
    fi
fi

mkdir -p "$LAB_DIR"
echo "[+] Created $LAB_DIR"

# Copy sample files
cp "$SCRIPT_DIR/server.log" "$LAB_DIR/" 2>/dev/null
cp "$SCRIPT_DIR/config.conf" "$LAB_DIR/" 2>/dev/null
cp "$SCRIPT_DIR/students.csv" "$LAB_DIR/" 2>/dev/null
cp "$SCRIPT_DIR/practice-sed.txt" "$LAB_DIR/" 2>/dev/null
cp "$SCRIPT_DIR/weblog.txt" "$LAB_DIR/" 2>/dev/null
cp "$SCRIPT_DIR/hostnames.txt" "$LAB_DIR/" 2>/dev/null

# Also copy lesson4 sample files if they exist alongside this script
if [ -f "$SCRIPT_DIR/../../lesson4-process-text-files/sample-files/employees.csv" ]; then
    cp "$SCRIPT_DIR/../../lesson4-process-text-files/sample-files/employees.csv" "$LAB_DIR/" 2>/dev/null
    echo "[+] Copied employees.csv from lesson4"
fi

# Create additional practice files inside the lab

# --- File for link practice ---
cat << 'EOF' > "$LAB_DIR/original-report.txt"
Quarterly Server Report
=======================
Date: March 2026
Status: All systems operational
Uptime: 99.97%
Total requests: 1,245,678
Average response time: 45ms
EOF

# --- File for variable/script practice ---
cat << 'SCRIPT' > "$LAB_DIR/system-info.sh"
#!/bin/bash
# system-info.sh — Practice using variables and command substitution

# Store values in variables
my_hostname=$(hostname)
my_user=$USER
my_date=$(date "+%Y-%m-%d %H:%M:%S")
my_uptime=$(uptime -p 2>/dev/null || uptime)
my_kernel=$(uname -r)
file_count=$(ls -1 "$HOME" 2>/dev/null | wc -l)

# Display the report
echo "======================================="
echo "  System Information Report"
echo "======================================="
echo "  Hostname    : $my_hostname"
echo "  User        : $my_user"
echo "  Date        : $my_date"
echo "  Kernel      : $my_kernel"
echo "  Uptime      : $my_uptime"
echo "  Files in ~  : $file_count"
echo "======================================="
SCRIPT
chmod +x "$LAB_DIR/system-info.sh"

# --- File for find practice: create a small directory tree ---
mkdir -p "$LAB_DIR/project/src"
mkdir -p "$LAB_DIR/project/docs"
mkdir -p "$LAB_DIR/project/logs"
mkdir -p "$LAB_DIR/project/config"

echo '#!/bin/bash' > "$LAB_DIR/project/src/app.sh"
echo 'echo "Hello from App"' >> "$LAB_DIR/project/src/app.sh"
echo 'print("Helper module")' > "$LAB_DIR/project/src/helper.py"
echo '# API Documentation' > "$LAB_DIR/project/docs/api.md"
echo '# User Guide' > "$LAB_DIR/project/docs/guide.md"
echo '# README' > "$LAB_DIR/project/docs/README.txt"
echo 'App started at 08:00' > "$LAB_DIR/project/logs/app.log"
echo 'Error at 09:15' > "$LAB_DIR/project/logs/error.log"
echo 'debug_mode=false' > "$LAB_DIR/project/config/app.conf"
echo 'db_host=localhost' > "$LAB_DIR/project/config/database.conf"

echo "[+] Copied all sample files to $LAB_DIR"
echo ""

# List what was created
echo "--- Lab Files ---"
echo ""
find "$LAB_DIR" -type f | sort | while read -r f; do
    echo "  $(echo "$f" | sed "s|$LAB_DIR/||")"
done

echo ""
echo "============================================="
echo "  Setup complete!"
echo "  To start the lab:"
echo "    cd ~/textlab"
echo "============================================="

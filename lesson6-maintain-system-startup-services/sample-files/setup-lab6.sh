#!/bin/bash
# setup-lab6.sh — Sets up the lab environment for lesson 6.1.1
# Run this script on the Debian lab system

LAB_DIR="$HOME/lab6"
echo "============================================"
echo "  Setting up Lab 6.1.1 — Init System & Links"
echo "============================================"

# Create lab directory structure
mkdir -p "$LAB_DIR"/{bin,docs,links-demo}
echo "[+] Created $LAB_DIR/ with subdirectories"

# ----------------------------
# Demo: Version-switching with symlinks
# ----------------------------
cat << 'EOF' > "$LAB_DIR/bin/myapp_v1.sh"
#!/bin/bash
echo "=== MyApp Version 1.0 ==="
echo "Release Date: 2025-01-15"
echo "Status: Stable (legacy)"
EOF
chmod +x "$LAB_DIR/bin/myapp_v1.sh"

cat << 'EOF' > "$LAB_DIR/bin/myapp_v2.sh"
#!/bin/bash
echo "=== MyApp Version 2.0 ==="
echo "Release Date: 2025-09-01"
echo "Status: Stable (current)"
EOF
chmod +x "$LAB_DIR/bin/myapp_v2.sh"

cat << 'EOF' > "$LAB_DIR/bin/myapp_v3.sh"
#!/bin/bash
echo "=== MyApp Version 3.0-beta ==="
echo "Release Date: 2026-02-28"
echo "Status: Beta (testing)"
EOF
chmod +x "$LAB_DIR/bin/myapp_v3.sh"

# Create the "current" symlink pointing to v2
ln -sf "$LAB_DIR/bin/myapp_v2.sh" "$LAB_DIR/bin/myapp"
echo "[+] Created version-switching demo (myapp -> myapp_v2.sh)"

# ----------------------------
# Demo: Hard link vs Soft link comparison
# ----------------------------
echo "This is the original file content." > "$LAB_DIR/links-demo/original.txt"
echo "It demonstrates the difference between hard and soft links." >> "$LAB_DIR/links-demo/original.txt"
echo "Modify this through any link and ALL names see the change." >> "$LAB_DIR/links-demo/original.txt"

# Create hard link
ln "$LAB_DIR/links-demo/original.txt" "$LAB_DIR/links-demo/hardlink.txt"

# Create soft link
ln -s "$LAB_DIR/links-demo/original.txt" "$LAB_DIR/links-demo/softlink.txt"

echo "[+] Created hard link and soft link demo files"

# ----------------------------
# Demo: Dangling symlink
# ----------------------------
echo "I will be deleted soon." > "$LAB_DIR/links-demo/will_be_deleted.txt"
ln -s "$LAB_DIR/links-demo/will_be_deleted.txt" "$LAB_DIR/links-demo/dangling_demo.txt"
echo "[+] Created dangling symlink setup (delete will_be_deleted.txt to demonstrate)"

# ----------------------------
# Demo: Nested symlink chain (simulates /sbin/init → systemd)
# ----------------------------
mkdir -p "$LAB_DIR/links-demo/chain"
echo '#!/bin/bash' > "$LAB_DIR/links-demo/chain/real_binary.sh"
echo 'echo "I am the REAL binary at the end of the chain."' >> "$LAB_DIR/links-demo/chain/real_binary.sh"
chmod +x "$LAB_DIR/links-demo/chain/real_binary.sh"

ln -s "$LAB_DIR/links-demo/chain/real_binary.sh" "$LAB_DIR/links-demo/chain/link_level2"
ln -s "$LAB_DIR/links-demo/chain/link_level2" "$LAB_DIR/links-demo/chain/link_level1"
ln -s "$LAB_DIR/links-demo/chain/link_level1" "$LAB_DIR/links-demo/chain/start_here"

echo "[+] Created symlink chain: start_here -> link_level1 -> link_level2 -> real_binary.sh"

# ----------------------------
# Demo: init-system identification script
# ----------------------------
cat << 'SCRIPT' > "$LAB_DIR/find_init.sh"
#!/bin/bash
# find_init.sh — Identify the system initialization method
echo "============================================"
echo " System Initialization Detection"
echo "============================================"
echo ""

echo "1. PID 1 process name:"
echo "   $(ps -p 1 -o comm=)"
echo ""

echo "2. Location of init:"
echo "   $(which init 2>/dev/null || echo 'init not in PATH')"
echo ""

echo "3. File type of /sbin/init:"
if [ -e /sbin/init ]; then
    echo "   $(file /sbin/init)"
else
    echo "   /sbin/init does not exist"
fi
echo ""

echo "4. Symlink resolution:"
if [ -L /sbin/init ]; then
    echo "   /sbin/init -> $(readlink /sbin/init)"
    echo "   Full path:  $(readlink -f /sbin/init)"
else
    echo "   /sbin/init is NOT a symlink"
fi
echo ""

echo "5. Init system detection:"
if [ -d /run/systemd/system ]; then
    echo "   ✓ systemd detected"
    echo "   Version: $(systemctl --version | head -1)"
elif [ -f /etc/init.d/README ]; then
    echo "   ✓ SysVinit detected"
else
    echo "   ? Unknown init system"
fi
echo ""

echo "6. Process tree (first 15 lines):"
if command -v pstree > /dev/null 2>&1; then
    pstree -p 1 | head -15
else
    ps -ejH | head -15
fi
echo ""

echo "============================================"
echo " Conclusion: This system uses $(ps -p 1 -o comm=)"
echo "============================================"
SCRIPT
chmod +x "$LAB_DIR/find_init.sh"
echo "[+] Created find_init.sh (init system identification script)"

# ----------------------------
# Summary
# ----------------------------
echo ""
echo "============================================"
echo "  Setup complete! Files in: $LAB_DIR/"
echo "============================================"
echo ""
echo "Directory contents:"
find "$LAB_DIR" -type f -o -type l | sort | while read f; do
    if [ -L "$f" ]; then
        echo "  (link) $f -> $(readlink "$f")"
    else
        echo "  (file) $f"
    fi
done
echo ""
echo "Quick start commands:"
echo "  cd ~/lab6"
echo "  bash find_init.sh                         # Detect init system"
echo "  ls -li links-demo/                        # Compare inodes"
echo "  readlink -f links-demo/chain/start_here   # Trace the chain"
echo "  ./bin/myapp                                # Run current version"

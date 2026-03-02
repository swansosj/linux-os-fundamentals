#!/bin/bash
# setup-lab4.sh — Creates all sample files in the student's home directory
# Run this script to set up the lab environment

LAB_DIR="$HOME/lab4"
echo "============================================"
echo "  Setting up Lab 4.1.1 sample files"
echo "============================================"

# Create lab directory
mkdir -p "$LAB_DIR"
echo "[+] Created $LAB_DIR"

# Copy sample files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/employees.csv" "$LAB_DIR/"
cp "$SCRIPT_DIR/server.log" "$LAB_DIR/"
cp "$SCRIPT_DIR/words.txt" "$LAB_DIR/"
cp "$SCRIPT_DIR/inventory.txt" "$LAB_DIR/"
cp "$SCRIPT_DIR/errors.log" "$LAB_DIR/"

echo "[+] Copied sample files to $LAB_DIR/"

# Create additional files for redirection exercises
# stdin_input.txt — used for input redirection demos
cat << 'EOF' > "$LAB_DIR/stdin_input.txt"
5
3
8
1
9
2
7
4
6
10
15
12
11
14
13
EOF
echo "[+] Created stdin_input.txt (numbers for sort/redirection demos)"

# names_unsorted.txt — used for sort + redirect exercises
cat << 'EOF' > "$LAB_DIR/names_unsorted.txt"
Charlie Brown
alice Walker
Bob Marley
alice Smith
David Lee
charlie Parker
bob Dylan
Eve Torres
Alice Johnson
Charlie Chaplin
Bob Ross
david Bowie
Eve Martinez
Alice Wonderland
EOF
echo "[+] Created names_unsorted.txt"

# mixed_output.sh — a script that produces BOTH stdout and stderr
cat << 'SCRIPT' > "$LAB_DIR/mixed_output.sh"
#!/bin/bash
# This script produces both stdout and stderr for redirection practice.
echo "Starting file check..."
echo "Checking /etc/hostname..."
cat /etc/hostname
echo "Checking /nonexistent/fake_file..."
cat /nonexistent/fake_file
echo "Checking /etc/passwd (first 3 lines)..."
head -3 /etc/passwd
echo "Checking /another/missing/path..."
ls /another/missing/path
echo "Checking /etc/shells..."
cat /etc/shells
echo "Checking /no/such/directory..."
ls /no/such/directory
echo "File check complete."
SCRIPT
chmod +x "$LAB_DIR/mixed_output.sh"
echo "[+] Created mixed_output.sh (stdout + stderr demo script)"

# redirect_practice.txt — instructions for students
cat << 'EOF' > "$LAB_DIR/redirect_practice.txt"
=== REDIRECTION PRACTICE EXERCISES ===

Exercise 1: Basic Output Redirection
  a) Run: echo "Hello Linux" > hello.txt
  b) Run: echo "Hello Again" >> hello.txt
  c) Run: cat hello.txt
  d) What is the difference between > and >> ?

Exercise 2: Separating stdout and stderr
  a) Run: bash mixed_output.sh
  b) Run: bash mixed_output.sh > stdout.txt
  c) Run: bash mixed_output.sh 2> stderr.txt
  d) Run: bash mixed_output.sh > stdout.txt 2> stderr.txt
  e) Run: bash mixed_output.sh &> all_output.txt
  f) Compare the contents of each file.

Exercise 3: Input Redirection
  a) Run: sort < stdin_input.txt
  b) Run: sort -n < stdin_input.txt
  c) Run: sort -n < stdin_input.txt > sorted_numbers.txt
  d) Run: wc -l < employees.csv

Exercise 4: Pipes
  a) Run: cat employees.csv | grep "Engineering"
  b) Run: cat employees.csv | grep "Engineering" | wc -l
  c) Run: cat employees.csv | cut -d ',' -f 1,3 | sort -t ',' -k 2
  d) Run: cat employees.csv | grep -v "^Name" | cut -d ',' -f 3 | sort | uniq -c | sort -rn

Exercise 5: Pipeline with tee
  a) Run: cat server.log | grep "ERROR" | tee errors_found.txt | wc -l
  b) Check: cat errors_found.txt

Exercise 6: Here Document
  a) Create a file using heredoc:
     cat << EOF > myinfo.txt
     Name: Your Name
     Date: $(date)
     User: $(whoami)
     Home: $HOME
     EOF
  b) Run: cat myinfo.txt
EOF
echo "[+] Created redirect_practice.txt (student exercise sheet)"

echo ""
echo "============================================"
echo "  Setup complete! Files in: $LAB_DIR/"
echo "============================================"
echo ""
ls -la "$LAB_DIR/"

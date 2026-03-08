# Text Manipulation, Redirection & System Commands — Quick Reference

> **How to use this guide:** Every command includes a description, when you'd use it, and a real scenario you can try. Sample files are in the `sample-files/` directory. Run `bash sample-files/setup-textanalysis.sh` to copy them into a `~/textlab/` working directory.

---

# Table of Contents

1. [Text Editors: nano & vim](#1--text-editors-nano--vim)
2. [cut — Extract Columns from Text](#2--cut--extract-columns-from-text)
3. [sed — Find and Replace in Text](#3--sed--find-and-replace-in-text)
4. [awk — Process Text Column by Column](#4--awk--process-text-column-by-column)
5. [find — Search for Files on Disk](#5--find--search-for-files-on-disk)
6. [whereis — Locate Binary, Source, and Man Pages](#6--whereis--locate-binary-source-and-man-pages)
7. [which — Show Full Path of a Command](#7--which--show-full-path-of-a-command)
8. [type — Identify What a Command Is](#8--type--identify-what-a-command-is)
9. [Redirecting Output and Input](#9--redirecting-output-and-input)
10. [Handling Errors with Redirection](#10--handling-errors-with-redirection)
11. [Piping Commands Together](#11--piping-commands-together)
12. [Hard Links and Soft Links](#12--hard-links-and-soft-links)
13. [Aliases — Create Command Shortcuts](#13--aliases--create-command-shortcuts)
14. [Variables — Store and Use Values](#14--variables--store-and-use-values)

---

---

# 1 — Text Editors: nano & vim

Linux gives you text editors that run entirely in the terminal — no mouse needed. The two most common are **nano** (beginner-friendly) and **vim** (powerful but has a learning curve).

---

## nano — The Beginner-Friendly Editor

### What is it?

`nano` is a simple terminal text editor. It shows helpful shortcut hints at the bottom of the screen. If you've never edited a file in the terminal before, start here.

### When would you use it?

- Quickly editing a configuration file
- Writing a short script
- Making a small change to an existing file

### Basic Syntax

```
nano [FILENAME]
```

### Opening and Creating Files

```bash
# Open an existing file for editing
nano /etc/hostname

# Create a new file (or open it if it exists)
nano mynotes.txt
```

### Essential Keyboard Shortcuts

In nano, `^` means the **Ctrl** key. So `^O` means **Ctrl + O**.

| Shortcut     | Action                              |
|--------------|-------------------------------------|
| `Ctrl + O`   | **Save** the file (Write Out)       |
| `Ctrl + X`   | **Exit** nano                       |
| `Ctrl + K`   | **Cut** (delete) the current line   |
| `Ctrl + U`   | **Paste** the last cut line         |
| `Ctrl + W`   | **Search** for text                 |
| `Ctrl + \`   | **Find and Replace**                |
| `Ctrl + G`   | **Help** — show all shortcuts       |
| `Ctrl + C`   | Show current **line number**        |
| `Alt + U`    | **Undo** last action                |
| `Alt + E`    | **Redo** last undo                  |

### Scenario: Edit a Configuration File

```bash
# You need to change the system hostname
sudo nano /etc/hostname

# 1. The file opens showing the current hostname
# 2. Delete the old name and type the new one
# 3. Press Ctrl + O, then Enter to save
# 4. Press Ctrl + X to exit
```

### Scenario: Create a Quick Script

```bash
nano hello.sh

# Type the following into the editor:
# #!/bin/bash
# echo "Hello, $(whoami)!"
# echo "Today is $(date)"

# Press Ctrl + O, Enter to save
# Press Ctrl + X to exit
# Then make it executable and run it:
chmod +x hello.sh
./hello.sh
```

> **Tip:** When nano asks for a filename (after Ctrl+O), just press **Enter** to confirm the current name.

---

## vim — The Power Editor

### What is it?

`vim` (Vi IMproved) is a powerful text editor found on virtually every Linux system. It uses different **modes** for editing vs. navigating, which is confusing at first but very efficient once learned.

### When would you use it?

- Editing files on a remote server (vim is almost always installed)
- When you need powerful search/replace or navigation
- When you see it referenced in documentation or scripts

### The Most Important Thing: Modes

vim has two main modes you need to know:

| Mode            | Purpose                        | How to enter               |
|-----------------|--------------------------------|----------------------------|
| **Normal Mode** | Navigate, delete, copy, paste  | Press `Esc` (default mode) |
| **Insert Mode** | Type and edit text             | Press `i`                  |

**The #1 beginner mistake:** Trying to type before pressing `i` to enter Insert Mode.

### Basic Syntax

```
vim [FILENAME]
```

### Essential Workflow: Open → Edit → Save → Quit

```bash
# Step 1: Open a file
vim mynotes.txt

# Step 2: Press i to enter INSERT MODE (you'll see -- INSERT -- at the bottom)

# Step 3: Type your text normally

# Step 4: Press Esc to go back to NORMAL MODE

# Step 5: Type :wq and press Enter to SAVE AND QUIT
```

### Essential Normal Mode Commands

| Command     | Action                                   |
|-------------|------------------------------------------|
| `i`         | Enter Insert Mode (start typing)         |
| `Esc`       | Return to Normal Mode                    |
| `:w`        | **Save** (write) the file                |
| `:q`        | **Quit** vim                             |
| `:wq`       | **Save and quit**                        |
| `:q!`       | **Quit without saving** (force quit)     |
| `dd`        | **Delete** (cut) the current line        |
| `yy`        | **Copy** (yank) the current line         |
| `p`         | **Paste** below the current line         |
| `u`         | **Undo** last change                     |
| `Ctrl + r`  | **Redo** last undo                       |
| `/text`     | **Search** forward for "text"            |
| `n`         | Jump to **next** search match            |
| `gg`        | Go to **first line** of file             |
| `G`         | Go to **last line** of file              |
| `:set number` | Show **line numbers**                  |

### Scenario: I'm Stuck in vim — How Do I Get Out?

This is the most common beginner question. Here's the escape plan:

```
1. Press Esc (maybe a few times to be safe)
2. Type  :q!  and press Enter     ← quits WITHOUT saving
   OR
   Type  :wq  and press Enter     ← SAVES and quits
```

### Scenario: Quick Edit with vim

```bash
vim server.conf

# Press i to start typing
# Make your changes
# Press Esc
# Type :wq and press Enter
```

### nano vs. vim — Which Should I Use?

| Feature            | nano                | vim                    |
|--------------------|---------------------|------------------------|
| Learning curve     | Easy                | Steep                  |
| Always installed   | Usually             | Almost always          |
| Mouse support      | Limited             | None (by default)      |
| Power/speed        | Basic               | Very powerful          |
| Best for beginners | Yes                 | Learn basics, use nano |

> **Teaching Note:** For this course, it's fine to use `nano` for everything. But every Linux user should know how to at least open, edit, save, and quit vim — because one day you'll SSH into a server that only has vim installed.

---

---

# 2 — cut — Extract Columns from Text

### What is it?

`cut` extracts specific columns or fields from each line of text. Think of it like selecting columns in a spreadsheet.

### When would you use it?

When you need to pull out specific pieces from structured text (CSV files, log files, system files like `/etc/passwd`).

### Basic Syntax

```
cut -d 'DELIMITER' -f FIELD_NUMBERS [FILE]
```

### Common Options

| Option | Meaning |
|--------|---------|
| `-d ','` | Set the delimiter (what separates columns) |
| `-f 1` | Extract field 1 |
| `-f 1,3` | Extract fields 1 and 3 |
| `-f 1-4` | Extract fields 1 through 4 |
| `-c 1-10` | Extract characters 1 through 10 |

### Scenario: Extract Names and Departments from a CSV

```bash
# employees.csv has: Name,ID,Department,Salary,Email,Start_Date
# Pull out just the names and departments
cut -d ',' -f 1,3 employees.csv
```

**Output:**
```
Name,Department
Alice Johnson,Engineering
Bob Smith,Marketing
...
```

### Scenario: Get All Usernames from the System

```bash
# /etc/passwd is colon-delimited: username:x:uid:gid:info:home:shell
cut -d ':' -f 1 /etc/passwd
```

### Scenario: Extract Salaries and Sort Them

```bash
# Get names and salaries, then sort by salary (highest first)
cut -d ',' -f 1,4 employees.csv | sort -t ',' -k 2 -rn
```

---

---

# 3 — sed — Find and Replace in Text

### What is it?

`sed` (Stream Editor) reads text line by line and applies changes — most commonly **find and replace**. It can modify files without opening them in an editor.

### When would you use it?

- Replacing text across an entire file (like changing a server name in a config)
- Deleting specific lines
- Making bulk edits in scripts

### Basic Syntax

```
sed 's/FIND/REPLACE/' [FILE]
```

The `s` means **substitute**. By default, it replaces only the **first** match on each line.

### Common Usage

```bash
# Replace first occurrence of "old" with "new" on each line
sed 's/old/new/' filename.txt

# Replace ALL occurrences on each line (g = global)
sed 's/old/new/g' filename.txt

# Case-insensitive replace (I flag)
sed 's/error/WARNING/Ig' server.log

# Actually MODIFY the file in place (-i flag)
sed -i 's/old/new/g' filename.txt

# Make a backup before modifying (-i.bak creates filename.txt.bak)
sed -i.bak 's/old/new/g' filename.txt
```

> **⚠️ Important:** Without `-i`, sed only prints the changes — it does NOT modify the file. Add `-i` to save changes.

### Scenario: Update a Server Name in a Config File

Your web server config has the old hostname. You need to change it everywhere.

```bash
# See what would change (preview without -i)
sed 's/oldserver.example.com/newserver.example.com/g' server.conf

# If it looks right, apply the change
sed -i 's/oldserver.example.com/newserver.example.com/g' server.conf
```

### Scenario: Remove Comment Lines from a Config File

```bash
# Delete lines that start with # (comments)
sed '/^#/d' config.conf

# Delete blank lines
sed '/^$/d' config.conf

# Delete both comments and blank lines
sed '/^#/d; /^$/d' config.conf
```

### Scenario: Add Text to the Beginning or End of Lines

```bash
# Add "Server: " to the beginning of each line
sed 's/^/Server: /' hostnames.txt

# Add ".local" to the end of each line
sed 's/$/.local/' hostnames.txt
```

### Scenario: Replace Only on a Specific Line

```bash
# Replace "foo" with "bar" only on line 3
sed '3s/foo/bar/' filename.txt

# Replace on lines 2 through 5
sed '2,5s/foo/bar/g' filename.txt
```

### Scenario: Delete Specific Lines

```bash
# Delete line 1 (e.g., remove a header row)
sed '1d' employees.csv

# Delete lines 1 through 3
sed '1,3d' filename.txt

# Delete the last line
sed '$d' filename.txt
```

### Scenario: Insert or Append Lines

```bash
# Insert a line BEFORE line 1
sed '1i\# This is a header comment' config.conf

# Append a line AFTER line 5
sed '5a\# End of section' config.conf
```

### Quick Reference

| Command | What it does |
|---------|-------------|
| `sed 's/old/new/'` | Replace first match per line |
| `sed 's/old/new/g'` | Replace all matches per line |
| `sed -i 's/old/new/g' file` | Replace and save to file |
| `sed -i.bak 's/old/new/g' file` | Replace, save, and keep backup |
| `sed '/pattern/d'` | Delete lines matching pattern |
| `sed '1d'` | Delete line 1 |
| `sed -n '5,10p'` | Print only lines 5–10 |
| `sed 's/^/prefix/'` | Add text to start of lines |
| `sed 's/$/suffix/'` | Add text to end of lines |

> **Teaching Note:** For beginners, focus on `sed 's/find/replace/g'` and `sed -i`. That covers 90% of real-world usage. The `d` (delete) and `-n ... p` (print range) are the next most useful.

---

---

# 4 — awk — Process Text Column by Column

### What is it?

`awk` is a text-processing tool that splits each line into columns (called **fields**) and lets you work with them. Think of it as a mini programming language for structured text.

### When would you use it?

- Printing specific columns from output (like `ps`, `ls -l`, `df`)
- Doing math on columns (totals, averages)
- Formatting output in a custom way

### Basic Syntax

```
awk '{action}' [FILE]
awk -F'DELIMITER' '{action}' [FILE]
```

By default, `awk` splits on **whitespace** (spaces and tabs). 

Each column is referenced by `$1`, `$2`, `$3`, etc.  `$0` is the **entire line**.

```
Line: "Alice Johnson  Engineering  95000"
       $1="Alice"  $2="Johnson"  $3="Engineering"  $4="95000"
```

### Common Usage

```bash
# Print the first column of every line
awk '{print $1}' filename.txt

# Print columns 1 and 3
awk '{print $1, $3}' filename.txt

# Use a comma delimiter (for CSV files)
awk -F',' '{print $1, $3}' employees.csv

# Use a colon delimiter (for /etc/passwd)
awk -F':' '{print $1, $6}' /etc/passwd
```

### Scenario: See Who's Using the Most CPU

```bash
# ps aux columns: USER PID %CPU %MEM ... COMMAND
# Print just the user, CPU%, and command name
ps aux | awk '{print $1, $3, $11}' | sort -k 2 -rn | head -10
```

### Scenario: Print Names and Salaries from a CSV

```bash
# employees.csv: Name,ID,Department,Salary,Email,Start_Date
awk -F',' '{print $1, "$"$4}' employees.csv
```

**Output:**
```
Name $Salary
Alice Johnson $95000
Bob Smith $72000
...
```

### Scenario: Filter Rows — Show Only Engineering Staff

```bash
# Only print lines where field 3 is "Engineering"
awk -F',' '$3 == "Engineering" {print $1, $4}' employees.csv
```

**Output:**
```
Alice Johnson 95000
Carol Davis 102000
Eve Martinez 110000
...
```

### Scenario: Calculate the Total of a Column

```bash
# Add up all salaries (field 4), skip the header
awk -F',' 'NR > 1 {total += $4} END {print "Total Salaries: $"total}' employees.csv
```

**Output:**
```
Total Salaries: $2131000
```

### Scenario: Calculate an Average

```bash
# Average salary
awk -F',' 'NR > 1 {total += $4; count++} END {print "Average: $"total/count}' employees.csv
```

### Scenario: Format Output into Columns

```bash
# Pretty-print name and department with alignment
awk -F',' 'NR > 1 {printf "%-20s %-15s\n", $1, $3}' employees.csv
```

**Output:**
```
Alice Johnson        Engineering    
Bob Smith            Marketing      
Carol Davis          Engineering    
...
```

### Useful Built-in Variables

| Variable | Meaning |
|----------|---------|
| `$0` | The entire current line |
| `$1, $2, $3…` | Field 1, 2, 3, etc. |
| `NR` | Current line number (Number of Record) |
| `NF` | Number of fields on the current line |
| `FS` | Field separator (same as -F) |

### Quick Reference

| Command | What it does |
|---------|-------------|
| `awk '{print $1}'` | Print first column |
| `awk '{print $1, $3}'` | Print columns 1 and 3 |
| `awk -F',' '{print $1}'` | Use comma as delimiter |
| `awk '$3 > 100 {print $0}'` | Print lines where col 3 > 100 |
| `awk 'NR > 1'` | Skip line 1 (header) |
| `awk '{sum += $1} END {print sum}'` | Sum a column |
| `awk '{print NR, $0}'` | Add line numbers |

> **Teaching Note:** `awk` can be intimidating at first. Start with just `awk '{print $1}'` and build from there. The key concept: awk automatically splits every line into numbered fields. For this course, focus on printing columns, filtering rows, and simple sums — that covers the vast majority of beginner use cases.

---

---

# 5 — find — Search for Files on Disk

### What is it?

`find` searches the filesystem for files and directories matching criteria you specify — by name, size, type, modification time, and more.

### When would you use it?

- Locating a file when you know part of its name but not where it is
- Finding large files eating up disk space
- Finding files that were recently changed
- Finding and cleaning up old log files

### Basic Syntax

```
find [WHERE_TO_LOOK] [CRITERIA]
```

### Common Usage

```bash
# Find a file by exact name starting from the current directory
find . -name "config.conf"

# Find a file by name starting from root (search entire system)
find / -name "config.conf"

# Case-insensitive name search
find / -iname "readme.md"

# Find by partial name (wildcard)
find /home -name "*.txt"
find /etc -name "*.conf"

# Find only directories
find /var -type d -name "log"

# Find only regular files
find /home -type f -name "*.sh"
```

### Scenario: Find All Log Files on the System

```bash
# Search from root, suppress permission errors
find / -name "*.log" -type f 2>/dev/null
```

### Scenario: Find Large Files Taking Up Disk Space

```bash
# Find files larger than 100MB
find / -type f -size +100M 2>/dev/null

# Find files larger than 1GB
find / -type f -size +1G 2>/dev/null

# Find large files and show their sizes
find /home -type f -size +50M -exec ls -lh {} \;
```

### Scenario: Find Recently Modified Files

```bash
# Files modified in the last 24 hours
find /etc -type f -mtime -1

# Files modified in the last 7 days
find /home -type f -mtime -7

# Files modified MORE than 30 days ago
find /tmp -type f -mtime +30
```

### Scenario: Find and Delete Old Files

```bash
# Find .tmp files older than 30 days in /tmp (preview first)
find /tmp -name "*.tmp" -type f -mtime +30

# If that looks right, add -delete to remove them
find /tmp -name "*.tmp" -type f -mtime +30 -delete
```

> **⚠️ Always preview the find results BEFORE adding `-delete`!**

### Scenario: Find Files by Permission

```bash
# Find all executable files in /home
find /home -type f -perm -u+x

# Find world-writable files (security concern)
find / -type f -perm -o+w 2>/dev/null
```

### Scenario: Find and Do Something with Results

```bash
# Find all .conf files and display their contents
find /etc -name "*.conf" -type f -exec cat {} \;

# Find all .sh files and make them executable
find /home/student -name "*.sh" -exec chmod +x {} \;

# Find .log files and count lines in each
find /var/log -name "*.log" -exec wc -l {} \;
```

### Quick Reference

| Command | What it does |
|---------|-------------|
| `find . -name "*.txt"` | Find .txt files in current dir |
| `find / -name "file" 2>/dev/null` | Search entire system (hide errors) |
| `find . -type d` | Find directories only |
| `find . -type f` | Find files only |
| `find . -size +100M` | Files larger than 100MB |
| `find . -mtime -7` | Modified in last 7 days |
| `find . -name "*.tmp" -delete` | Find and delete matching files |
| `find . -exec command {} \;` | Run a command on each result |

> **Teaching Note:** `find` is one of the most versatile commands in Linux. For entry-level students, focus on `-name`, `-type`, `-size`, and `2>/dev/null` to suppress permission errors. The `-exec` option is powerful but can be introduced after the basics are solid.

---

---

# 6 — whereis — Locate Binary, Source, and Man Pages

### What is it?

`whereis` locates the **binary** (executable), **source code**, and **manual page** files for a command. It only searches standard system directories.

### When would you use it?

- To find out where a program is installed
- To check if a man page exists for a command
- Quick lookup without searching the entire filesystem

### Basic Syntax

```
whereis [COMMAND_NAME]
```

### Common Usage

```bash
# Find everything related to the bash command
whereis bash
# bash: /usr/bin/bash /usr/share/man/man1/bash.1.gz

# Find where Python is installed
whereis python3
# python3: /usr/bin/python3 /usr/lib/python3 /usr/share/man/man1/python3.1.gz

# Find location of config files for a service
whereis nginx
```

### Limiting the Search

```bash
# Only show the binary location
whereis -b bash
# bash: /usr/bin/bash

# Only show the man page location
whereis -m bash
# bash: /usr/share/man/man1/bash.1.gz

# Only show the source location
whereis -s bash
```

### Scenario: Is a Program Installed?

```bash
# Check if Apache is installed and where
whereis apache2
# If installed: apache2: /usr/sbin/apache2 /etc/apache2 ...
# If not: apache2:     (nothing after the colon)
```

---

---

# 7 — which — Show Full Path of a Command

### What is it?

`which` shows the **full path** of the executable that runs when you type a command. It searches your `PATH` environment variable.

### When would you use it?

- To find out exactly which version of a program runs when you type its name
- To check if a command is installed and accessible
- Troubleshooting when a command isn't found or the wrong version runs

### Basic Syntax

```
which [COMMAND_NAME]
```

### Common Usage

```bash
# Where is python3?
which python3
# /usr/bin/python3

# Where is the ls command?
which ls
# /usr/bin/ls

# Check if a command exists
which nginx
# /usr/sbin/nginx (installed)
# OR no output / error (not installed)
```

### Scenario: Which Version of Python Am I Using?

```bash
which python3
# /usr/bin/python3

# Now you can check its version
/usr/bin/python3 --version
```

### Scenario: Check If a Tool Is Installed

```bash
# Quick check — use the exit code
which git && echo "Git is installed" || echo "Git is NOT installed"
```

---

---

# 8 — type — Identify What a Command Is

### What is it?

`type` tells you what kind of thing a command is — whether it's a **built-in shell command**, an **alias**, a **function**, or an **external program**.

### When would you use it?

- To understand if a command is built into the shell or is a separate program
- To debug unexpected behavior (maybe an alias is overriding a command)
- To see what an alias expands to

### Basic Syntax

```
type [COMMAND_NAME]
```

### Common Usage

```bash
# Check what 'cd' is
type cd
# cd is a shell builtin

# Check what 'ls' is (often aliased)
type ls
# ls is aliased to 'ls --color=auto'

# Check what 'grep' is
type grep
# grep is /usr/bin/grep

# Check what 'if' is
type if
# if is a shell keyword
```

### Scenario: Why Is My Command Acting Differently?

```bash
# You notice 'ls' shows colors — is it aliased?
type ls
# ls is aliased to 'ls --color=auto'
# That's why! The alias adds --color=auto automatically.

# Run the REAL ls without the alias
\ls
# OR
command ls
```

### Comparing which, whereis, and type

| Command | What it tells you | Searches |
|---------|-------------------|----------|
| `which` | Full path of the executable | PATH only |
| `whereis` | Binary, source, and man page paths | Standard system directories |
| `type` | What kind of command it is (alias, builtin, external) | Shell knowledge |

```bash
# Example: Compare all three for 'ls'
which ls       # /usr/bin/ls
whereis ls     # ls: /usr/bin/ls /usr/share/man/man1/ls.1.gz
type ls        # ls is aliased to 'ls --color=auto'
```

> **Teaching Note:** `type` is the most informative of the three because it knows about aliases and builtins. `which` only finds external programs. Use `type` when debugging "why is this command not behaving like I expect?"

---

---

# 9 — Redirecting Output and Input

### What is it?

Every command has three streams: **stdin** (input), **stdout** (normal output), and **stderr** (error output). Redirection lets you send these streams to files instead of the screen, or read from files instead of the keyboard.

### The Three Streams

| Stream | Number | Default | What it carries |
|--------|:------:|---------|-----------------|
| stdin  | `0`    | Keyboard | Input to the command |
| stdout | `1`    | Screen   | Normal output |
| stderr | `2`    | Screen   | Error messages |

### Output Redirection: `>` and `>>`

```bash
# OVERWRITE — Send stdout to a file (creates or replaces the file)
echo "Hello World" > greeting.txt

# APPEND — Add stdout to the end of a file (does not erase existing content)
echo "Another line" >> greeting.txt

# Save command output to a file
ls -la > file_listing.txt
date > timestamp.txt

# Save grep results
grep "Engineering" employees.csv > engineers.txt
```

> **⚠️ Warning:** `>` erases the file first. Use `>>` to add to the end of an existing file.

### Input Redirection: `<`

```bash
# Feed a file as input to a command (instead of typing on the keyboard)
sort < words.txt

# Count lines from a file via input redirection
wc -l < employees.csv

# Combine input and output redirection
sort < words.txt > sorted_words.txt
```

### Here Documents: `<<`

Feed multiple lines of text directly into a command:

```bash
# Create a file with multiple lines
cat << EOF > notes.txt
Line one of my notes
Line two of my notes
Line three of my notes
EOF

# Sort inline text
sort << END
banana
apple
cherry
END
```

### Scenario: Save a Daily System Report

```bash
echo "=== System Report $(date) ===" > daily_report.txt
echo "" >> daily_report.txt
echo "--- Disk Usage ---" >> daily_report.txt
df -h >> daily_report.txt
echo "" >> daily_report.txt
echo "--- Memory ---" >> daily_report.txt
free -h >> daily_report.txt
echo "" >> daily_report.txt
echo "--- Uptime ---" >> daily_report.txt
uptime >> daily_report.txt

cat daily_report.txt
```

### Quick Reference

| Operator | Name | What it does |
|----------|------|-------------|
| `>` | Redirect stdout (overwrite) | Send output to file, erase first |
| `>>` | Redirect stdout (append) | Send output to end of file |
| `<` | Redirect stdin | Read input from file |
| `<<` | Here document | Feed inline text as input |

---

---

# 10 — Handling Errors with Redirection

### What is it?

Commands can produce two kinds of output: **normal output** (stdout) and **error messages** (stderr). By default they both appear on screen, but you can redirect them separately.

### Why does this matter?

When you run a command that produces both results and errors, you often want to:
- See only the results (hide the errors)
- Save the errors to a log file
- Save everything to one file

### Redirect Errors (stderr) with `2>`

```bash
# This command produces both output AND errors
ls /etc/hostname /nonexistent

# Redirect ONLY errors to a file (normal output still prints)
ls /etc/hostname /nonexistent 2> errors.txt

# Look at the errors
cat errors.txt
# ls: cannot access '/nonexistent': No such file or directory
```

### Separate stdout and stderr

```bash
# Send normal output to one file, errors to another
ls /etc/hostname /nonexistent 1> found.txt 2> not_found.txt

cat found.txt
# /etc/hostname

cat not_found.txt
# ls: cannot access '/nonexistent': No such file or directory
```

### Combine stdout and stderr into One File

```bash
# Send EVERYTHING to one file
ls /etc/hostname /nonexistent &> all_output.txt

# Older equivalent syntax
ls /etc/hostname /nonexistent > all_output.txt 2>&1
```

### Throw Away Errors: `/dev/null`

`/dev/null` is like a trash can — anything you send there disappears.

```bash
# Suppress error messages (very common with find)
find / -name "*.conf" 2>/dev/null

# Suppress ALL output
command &>/dev/null

# Only care about whether a command succeeded, not its output
if grep -q "root" /etc/passwd 2>/dev/null; then
    echo "root user exists"
fi
```

### Scenario: Search the System Without Permission Errors

```bash
# Without error suppression — cluttered with "Permission denied"
find / -name "shadow"

# Clean output — only show what was actually found
find / -name "shadow" 2>/dev/null
```

### Scenario: Log Errors from a Script

```bash
# Run a script and capture any errors to a log
bash my_script.sh 2> script_errors.log

# Run a script, save all output and errors together
bash my_script.sh &> script_full.log
```

### Quick Reference

| Operator | What it does |
|----------|-------------|
| `2> file` | Send errors to file (overwrite) |
| `2>> file` | Send errors to file (append) |
| `&> file` | Send stdout AND stderr to file |
| `&>> file` | Append stdout AND stderr to file |
| `2>&1` | Merge stderr into stdout |
| `2>/dev/null` | Throw away error messages |
| `&>/dev/null` | Throw away all output |

---

---

# 11 — Piping Commands Together

### What is it?

A **pipe** (`|`) takes the output of one command and feeds it as input to the next command. It lets you chain simple commands together to do complex things.

### When would you use it?

Almost constantly. Piping is one of the most fundamental Linux concepts. Any time you want to filter, sort, count, or transform the output of a command — you pipe it.

### Basic Syntax

```
command1 | command2 | command3
```

The stdout of `command1` becomes the stdin of `command2`, and so on.

### Common Examples

```bash
# Search for a process
ps aux | grep "apache"

# Count how many files are in a directory
ls -1 | wc -l

# Sort output
cat employees.csv | sort

# Find and count matching lines
grep "ERROR" server.log | wc -l

# View long output one page at a time
cat /var/log/syslog | less
```

### Scenario: Find the 5 Highest-Paid Employees

```bash
# 1. Skip the header (tail -n +2)
# 2. Sort by salary column descending
# 3. Take the top 5
# 4. Show only name and salary
tail -n +2 employees.csv | sort -t ',' -k 4 -rn | head -5 | cut -d ',' -f 1,4
```

### Scenario: Count Unique Departments

```bash
# 1. Extract the department column
# 2. Skip the header
# 3. Sort (required before uniq)
# 4. Count unique values
tail -n +2 employees.csv | cut -d ',' -f 3 | sort | uniq -c | sort -rn
```

### Scenario: Find the Most Common Words in a File

```bash
# 1. Put each word on its own line (tr replaces spaces with newlines)
# 2. Convert to lowercase
# 3. Sort
# 4. Count unique
# 5. Sort by count descending
# 6. Show top 10
cat practice-sed.txt | tr ' ' '\n' | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -10
```

### Scenario: Save Output AND See It on Screen (tee)

```bash
# tee sends output to BOTH a file and the screen
ls -la | tee directory_listing.txt

# Use tee in the middle of a pipeline
grep "ERROR" server.log | tee errors.txt | wc -l
# Saves errors to file AND prints the count
```

### Pipeline Building Strategy

Build pipelines **one command at a time**:

```bash
# Step 1: Start with the raw data
cat employees.csv

# Step 2: Add the first filter — looks right?
cat employees.csv | grep "Engineering"

# Step 3: Add the next step — still looks right?
cat employees.csv | grep "Engineering" | cut -d ',' -f 1,4

# Step 4: Sort
cat employees.csv | grep "Engineering" | cut -d ',' -f 1,4 | sort -t ',' -k 2 -rn
```

> **Teaching Note:** The pipe is the "glue" of Linux. It's what makes dozens of small, simple tools incredibly powerful when combined. Encourage students to build pipelines incrementally — add one command at a time and check the output before adding the next.

---

---

# 12 — Hard Links and Soft Links

### What is it?

Links are a way to create **multiple names** (paths) that point to the same file or directory. There are two types:

- **Hard link** — A second name for the exact same file data on disk
- **Soft link** (symbolic link / symlink) — A shortcut that points to another filename

### When would you use them?

- **Soft links:** Creating shortcuts, pointing to the current version of software, organizing files
- **Hard links:** Creating a backup reference to a file that survives if the original name is deleted

### Understanding inodes (The Key Concept)

Every file on disk has an **inode number** — a unique ID for the actual data. A filename is just a label that points to an inode.

```
Filename "report.txt"  ───>  inode 12345  ───>  [actual file data on disk]
```

You can see inode numbers with `ls -i`:

```bash
ls -i report.txt
# 12345 report.txt
```

---

## Soft Links (Symbolic Links)

A soft link is a **shortcut** — a small file that contains the path to another file.

```
"shortcut.txt"  ───>  points to "original.txt"  ───>  inode 12345  ───>  [data]
```

### Creating a Soft Link

```bash
ln -s TARGET LINK_NAME
```

```bash
# Create a soft link called "shortcut.txt" pointing to "original.txt"
ln -s original.txt shortcut.txt

# Verify — ls -l shows the link with an arrow
ls -l shortcut.txt
# lrwxrwxrwx 1 user user 12 Mar 08 10:00 shortcut.txt -> original.txt
```

### Scenario: Create a Shortcut to a Config File

```bash
# The real config is buried deep
# /etc/nginx/sites-available/mysite.conf

# Create a shortcut in your home directory
ln -s /etc/nginx/sites-available/mysite.conf ~/mysite-config

# Now you can edit it more conveniently
nano ~/mysite-config
```

### Scenario: Point to the Current Version of Software

```bash
# You have multiple versions
ls /opt/myapp/
# myapp-1.0/  myapp-2.0/  myapp-3.0/

# Create a "current" link pointing to the latest
ln -s /opt/myapp/myapp-3.0 /opt/myapp/current

# Scripts can always reference /opt/myapp/current
```

### What Happens If the Original Is Deleted?

```bash
# Create a file and a soft link
echo "Important data" > original.txt
ln -s original.txt shortcut.txt

# Both work
cat shortcut.txt    # shows "Important data"

# Delete the original
rm original.txt

# The soft link is now BROKEN
cat shortcut.txt
# cat: shortcut.txt: No such file or directory

# ls shows it in red (broken link)
ls -l shortcut.txt
# lrwxrwxrwx 1 user user 12 Mar 08 10:00 shortcut.txt -> original.txt
```

> Soft links **break** when the target is deleted or moved.

---

## Hard Links

A hard link is a **second name** for the same data on disk. Both names point to the same inode.

```
"original.txt"   ───>  inode 12345  ───>  [actual data on disk]
"hardlink.txt"    ───>  inode 12345  ───┘
```

### Creating a Hard Link

```bash
ln TARGET LINK_NAME       # Note: no -s flag
```

```bash
# Create a hard link
echo "Important data" > original.txt
ln original.txt hardlink.txt

# Both files have the SAME inode number
ls -i original.txt hardlink.txt
# 12345 original.txt
# 12345 hardlink.txt

# Both files show the SAME content
cat original.txt     # Important data
cat hardlink.txt     # Important data
```

### What Happens If the Original Is Deleted?

```bash
# Delete the original name
rm original.txt

# The hard link STILL WORKS — data is not lost
cat hardlink.txt     # Important data

# The data is only deleted when ALL hard links to it are removed
```

> Hard links **survive** when the original name is deleted. The data stays until the last link is removed.

### Scenario: Protect Important Data

```bash
# Create a hard link as a safety net
ln important-report.txt backup-reference.txt

# Even if someone accidentally deletes important-report.txt,
# the data is still accessible through backup-reference.txt
```

---

## Comparing Hard Links vs. Soft Links

| Feature | Hard Link | Soft Link (Symlink) |
|---------|-----------|-------------------|
| Command | `ln file link` | `ln -s file link` |
| Points to | Same inode (data) | A filename (path) |
| If original deleted | **Still works** | **Breaks** |
| Cross filesystems | No | Yes |
| Link to directories | No | Yes |
| Has own inode | No (shares inode) | Yes (own inode) |
| Shown by `ls -l` | Looks like a regular file | Shows `->` arrow |

### How to Tell If a File Has Hard Links

```bash
# The second column in ls -l is the hard link count
ls -l original.txt
# -rw-r--r-- 2 user user 15 Mar 08 10:00 original.txt
#             ^
#             2 means there are 2 hard links pointing to this data
```

> **Teaching Note:** For beginners — soft links are like shortcuts on Windows. Hard links are harder to understand but think of them as "two names for the same physical file." The key takeaway: soft links break when the target is deleted; hard links don't. In practice, soft links are used far more often.

---

---

# 13 — Aliases — Create Command Shortcuts

### What is it?

An alias lets you create your own shortcut name for a command (or a long command with options). Instead of typing a long command every time, you give it a short name.

### When would you use it?

- You're tired of typing the same long command over and over
- You want to add default options to commands (like always using `ls --color`)
- You want to create safety nets (like making `rm` always ask for confirmation)

### Basic Syntax

```
alias SHORTNAME='FULL_COMMAND'
```

### Creating Aliases

```bash
# Make 'll' a shortcut for 'ls -la'
alias ll='ls -la'

# Now just type:
ll

# Make a short name for a long command
alias myip='ip addr show | grep "inet " | grep -v 127.0.0.1'

# Make 'cls' clear the screen (familiar to Windows users)
alias cls='clear'

# Always use color with grep
alias grep='grep --color=auto'
```

### Scenario: Add Safety to Dangerous Commands

```bash
# Make rm, cp, and mv always ask before overwriting
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Now 'rm file.txt' will ask: "remove file.txt?" before deleting
```

### Viewing Existing Aliases

```bash
# List all current aliases
alias

# Check what a specific alias does
alias ll
# alias ll='ls -la'
# OR
type ll
```

### Removing an Alias

```bash
# Remove the 'll' alias for this session
unalias ll
```

### Bypassing an Alias

```bash
# If rm is aliased to 'rm -i', you can bypass it:
\rm filename.txt         # Backslash skips the alias
command rm filename.txt  # 'command' skips the alias
```

### Making Aliases Permanent

Aliases created in the terminal **disappear** when you close the terminal. To make them permanent, add them to your shell configuration file:

```bash
# Edit your .bashrc file (for bash shell)
nano ~/.bashrc

# Add your aliases at the bottom:
# alias ll='ls -la'
# alias cls='clear'
# alias rm='rm -i'

# Save and reload the configuration
source ~/.bashrc
```

### Scenario: Set Up Common Aliases for a New System

```bash
# Add these to ~/.bashrc for everyday convenience
cat << 'EOF' >> ~/.bashrc

# Custom aliases
alias ll='ls -la'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias h='history'
alias grep='grep --color=auto'
alias ports='ss -tuln'
alias myip='hostname -I'
alias update='sudo apt update && sudo apt upgrade -y'
EOF

# Apply the changes
source ~/.bashrc
```

### Quick Reference

| Command | What it does |
|---------|-------------|
| `alias name='command'` | Create an alias |
| `alias` | List all aliases |
| `unalias name` | Remove an alias |
| `\command` | Run the real command, bypassing alias |
| `~/.bashrc` | File where permanent aliases are stored |
| `source ~/.bashrc` | Reload configuration after editing |

> **Teaching Note:** Aliases are one of the first "personalization" steps for new Linux users. It's a quick win — students feel productive when they create their own shortcuts. Emphasize that aliases without `~/.bashrc` are temporary (session-only).

---

---

# 14 — Variables — Store and Use Values

### What is it?

A variable is a name that stores a value. You can use variables to save information (usernames, paths, settings) and reuse it in commands.

### When would you use it?

- Storing a value you'll use multiple times (a filename, server address, etc.)
- Writing scripts
- Referencing system information (environment variables)

---

## Creating and Using Variables

### Setting a Variable

```bash
# Assign a value (NO SPACES around the =)
name="Alice"
course="Linux Fundamentals"
count=42

# WRONG — spaces cause errors
# name = "Alice"     ← ERROR: tries to run 'name' as a command
```

### Using a Variable

Put a `$` in front of the variable name to use its value:

```bash
name="Alice"
echo "Hello, $name"
# Hello, Alice

course="Linux Fundamentals"
echo "Welcome to $course"
# Welcome to Linux Fundamentals
```

### Using Variables in Commands

```bash
# Store a filename in a variable
myfile="employees.csv"

# Use it in commands
cat $myfile
head -5 $myfile
grep "Engineering" $myfile

# Store a directory path
logdir="/var/log"
ls $logdir
```

### Curly Braces for Clarity

Use `${variable}` when the variable name could be ambiguous:

```bash
fruit="apple"
echo "I have 3 ${fruit}s"
# I have 3 apples

# Without braces, the shell looks for a variable called "fruits"
echo "I have 3 $fruits"
# I have 3    (empty — $fruits doesn't exist)
```

---

## Environment Variables

Environment variables are **system-wide** variables set by the operating system. They're available to all programs.

### Common Environment Variables

```bash
echo $HOME       # Your home directory: /home/student
echo $USER       # Your username: student
echo $PWD        # Current working directory
echo $SHELL      # Your default shell: /bin/bash
echo $PATH       # Directories where the system looks for commands
echo $HOSTNAME   # The computer's hostname
```

### Scenario: Check Your Environment

```bash
# See all environment variables
env

# Or with less (for paging)
env | less

# Search for a specific variable
env | grep PATH
```

### The PATH Variable

`PATH` is a list of directories (separated by `:`) that the shell searches when you type a command:

```bash
echo $PATH
# /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# When you type "ls", the shell checks:
# 1. /usr/local/bin/ls — not found
# 2. /usr/bin/ls — FOUND! Runs it.
```

---

## Command Substitution

You can store the **output of a command** in a variable:

```bash
# Use $(command) to capture output
today=$(date)
echo "Today is $today"
# Today is Mon Mar 08 14:30:00 EST 2026

# Count number of files
file_count=$(ls -1 | wc -l)
echo "There are $file_count files here"

# Store your IP address
my_ip=$(hostname -I | awk '{print $1}')
echo "My IP is $my_ip"
```

---

## Exporting Variables

A regular variable is only available in the **current shell**. To make it available to child processes (scripts, programs you launch), use `export`:

```bash
# Regular variable — only this shell
greeting="Hello"
bash -c 'echo $greeting'    # Prints nothing (child shell can't see it)

# Exported variable — available to child processes
export greeting="Hello"
bash -c 'echo $greeting'    # Prints: Hello
```

### Scenario: Set a Variable for a Script to Use

```bash
export DB_HOST="192.168.1.50"
export DB_PORT="5432"

# Now any script you run can access $DB_HOST and $DB_PORT
bash my_database_script.sh
```

---

## Making Variables Permanent

Just like aliases, variables set in the terminal disappear when you close it. To make them permanent:

```bash
# Edit ~/.bashrc
nano ~/.bashrc

# Add your variables:
# export EDITOR="nano"
# export MY_SERVER="192.168.1.100"

# Reload
source ~/.bashrc
```

---

## Special Variables (For Scripts)

These are useful when you start writing scripts:

| Variable | Meaning |
|----------|---------|
| `$0` | Name of the script |
| `$1, $2, $3…` | Arguments passed to the script |
| `$#` | Number of arguments |
| `$?` | Exit code of the last command (0 = success) |
| `$$` | Process ID of the current script |

```bash
# Check if the last command succeeded
ls /nonexistent
echo $?
# 2 (non-zero = error)

ls /etc/hostname
echo $?
# 0 (zero = success)
```

### Scenario: Use Variables in a Simple Script

```bash
cat << 'EOF' > greet.sh
#!/bin/bash
name=$1
echo "Hello, $name!"
echo "You are logged in as: $USER"
echo "Your home directory is: $HOME"
echo "Today is: $(date)"
EOF
chmod +x greet.sh

./greet.sh Alice
# Hello, Alice!
# You are logged in as: student
# Your home directory is: /home/student
# Today is: Mon Mar 08 14:30:00 EST 2026
```

### Quick Reference

| Syntax | What it does |
|--------|-------------|
| `name="value"` | Create a variable (no spaces around `=`) |
| `echo $name` | Use a variable |
| `${name}` | Use a variable (safer with surrounding text) |
| `export name="value"` | Make variable available to child processes |
| `$(command)` | Store command output in a variable |
| `$?` | Exit code of last command |
| `env` | Show all environment variables |
| `unset name` | Delete a variable |

> **Teaching Note:** Variables are the bridge from "running commands" to "writing scripts." Start with simple assignments and `echo`, then introduce `$()` for command substitution and `$?` for exit codes. Don't overwhelm with special variables — introduce them when students start scripting.

---

---

# Appendix — Cheat Sheet

## Editors

| Task | nano | vim |
|------|------|-----|
| Open a file | `nano file` | `vim file` |
| Start typing | Just type | Press `i` first |
| Save | `Ctrl+O`, Enter | `Esc`, `:w`, Enter |
| Quit | `Ctrl+X` | `Esc`, `:q`, Enter |
| Save & Quit | `Ctrl+O`, `Ctrl+X` | `Esc`, `:wq`, Enter |
| Quit without saving | `Ctrl+X`, `N` | `Esc`, `:q!`, Enter |
| Search | `Ctrl+W` | `/pattern` |
| Undo | `Alt+U` | `u` |

## Text Processing

| Task | Command |
|------|---------|
| Extract column 1 (comma-delimited) | `cut -d ',' -f 1 file.csv` |
| Find and replace | `sed 's/old/new/g' file` |
| Find and replace (save) | `sed -i 's/old/new/g' file` |
| Print column 1 | `awk '{print $1}' file` |
| Print column 1 (CSV) | `awk -F',' '{print $1}' file.csv` |
| Sum a column | `awk '{s+=$1} END {print s}' file` |

## Finding Things

| Task | Command |
|------|---------|
| Find files by name | `find /path -name "*.txt"` |
| Find files (ignore errors) | `find / -name "file" 2>/dev/null` |
| Where is a program? | `which command` |
| Full info on a program | `whereis command` |
| What type is a command? | `type command` |

## Redirection & Pipes

| Task | Syntax |
|------|--------|
| Save output to file | `command > file` |
| Append output to file | `command >> file` |
| Send errors to file | `command 2> file` |
| Send everything to file | `command &> file` |
| Hide errors | `command 2>/dev/null` |
| Read input from file | `command < file` |
| Pipe output to next command | `command1 \| command2` |
| Save AND display output | `command \| tee file` |

## Links

| Task | Command |
|------|---------|
| Create soft link | `ln -s target linkname` |
| Create hard link | `ln target linkname` |
| View inode numbers | `ls -i file` |
| View link count | `ls -l file` |

## Aliases & Variables

| Task | Command |
|------|---------|
| Create alias | `alias name='command'` |
| List aliases | `alias` |
| Remove alias | `unalias name` |
| Set variable | `name="value"` |
| Use variable | `echo $name` |
| Export variable | `export name="value"` |
| Store command output | `var=$(command)` |
| Check last exit code | `echo $?` |
| Make permanent | Add to `~/.bashrc`, then `source ~/.bashrc` |

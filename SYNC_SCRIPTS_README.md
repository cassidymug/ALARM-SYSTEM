# Guardian System - Repository Sync Scripts

This directory contains batch scripts to help you easily sync the latest hardware designs and documentation from the remote repository to your local Windows machine.

## 📥 Available Scripts

### 1. `pull-latest.bat` — Quick Pull

**Purpose:** Quickly pull the latest changes from the hardware design branch.

**What it does:**
- Fetches latest changes from origin
- Switches to `cursor/zone-expander-kicad-skeleton-daa6` branch (if not already there)
- Pulls all new files and updates
- Shows a summary of what was updated
- Lists available PDF/SVG files

**Usage:**
```cmd
pull-latest.bat
```

Double-click the file or run from Command Prompt.

**Output includes:**
- ✅ Zone Expander schematics (PDF + SVG)
- ✅ Access Control Expander specification
- ✅ System Architecture documentation
- ✅ All hardware project files

---

### 2. `sync-repo.bat` — Advanced Menu

**Purpose:** Interactive menu with multiple sync and view options.

**Features:**
1. **Pull latest changes** (same as pull-latest.bat)
2. **Pull and view schematic PDF** (automatically opens zone-expander-complete.pdf)
3. **Pull and view access control docs** (opens ACCESS_CONTROL_EXPANDER.md)
4. **Pull and open schematics folder** (opens explorer to schematics-pdf/)
5. **Show git status** (see current repository state)
6. **Show recent commits** (view commit history)
7. **Switch to different branch** (change branches interactively)
0. **Exit**

**Usage:**
```cmd
sync-repo.bat
```

Navigate the menu by entering the number of your choice.

---

## 🎯 Quick Start

### First Time Setup

If you haven't cloned the repository yet:

```cmd
cd c:\dev
git clone https://github.com/cassidymug/ALARM-SYSTEM.git "alarm system"
cd "alarm system"
pull-latest.bat
```

### Regular Use

To get the latest hardware designs:

```cmd
cd "c:\dev\alarm system"
pull-latest.bat
```

Or use the interactive menu:

```cmd
cd "c:\dev\alarm system"
sync-repo.bat
```

---

## 📂 Files You'll Get

After running the pull script, you'll have:

### Zone Expander (32-zone alarm input module)
```
hardware/zone-expander/
├── schematics-pdf/
│   ├── zone-expander-complete.pdf           ← Complete schematic (all sheets)
│   ├── zone-expander.svg                    ← Root sheet (hierarchical overview)
│   ├── zone-expander-Power.svg              ← Power supply circuit
│   ├── zone-expander-MCU.svg                ← STM32G431 microcontroller
│   ├── zone-expander-Ethernet.svg           ← W5500 Ethernet
│   ├── zone-expander-ZoneBank1.svg          ← Zones 1-8
│   ├── zone-expander-ZoneBank2.svg          ← Zones 9-16
│   ├── zone-expander-ZoneBank3.svg          ← Zones 17-24
│   ├── zone-expander-ZoneBank4.svg          ← Zones 25-32
│   ├── zone-expander-Outputs.svg            ← Siren + relays
│   ├── zone-expander-Connectors & Status.svg ← LEDs, mounting
│   └── README.md                            ← Viewing guide
├── SYSTEM_ARCHITECTURE.md                   ← Complete system documentation
├── README.md                                ← Project overview
├── *.kicad_sch                              ← KiCad schematic files
└── *.kicad_pcb                              ← PCB layout (when ready)
```

### Access Control Expander (8-output access control module)
```
docs/hardware/
└── ACCESS_CONTROL_EXPANDER.md               ← Complete specification

hardware/access-control-expander/
├── README.md                                ← Project overview
└── (schematic files coming next)
```

---

## 🖼️ Viewing the Files

### PDF Files
Double-click to open in your default PDF viewer (Adobe Reader, Edge, Chrome, etc.)

### SVG Files
- **Option 1:** Double-click to open in your default browser
- **Option 2:** Right-click → Open with → Chrome/Firefox/Edge
- **Tip:** SVG files are vector graphics, so you can zoom in infinitely without losing quality

### Markdown Files (.md)
- **Option 1:** Open in any text editor (Notepad, VSCode, Cursor)
- **Option 2:** View on GitHub (prettier rendering)
- **Option 3:** Use a Markdown viewer (Typora, MarkdownPad)

---

## 🔧 Troubleshooting

### "Failed to fetch from origin"
**Problem:** No internet connection or GitHub is unreachable.
**Solution:** Check your internet connection and try again.

### "Failed to pull changes"
**Problem:** You have local modifications that conflict with remote changes.
**Solution:** 
```cmd
git status                  # See what's modified
git stash                   # Temporarily save your changes
pull-latest.bat             # Pull latest
git stash pop               # Restore your changes (if desired)
```

### "Branch does not exist"
**Problem:** The branch hasn't been created on your local machine yet.
**Solution:** The script will automatically create it from the remote branch.

### "Not a git repository"
**Problem:** You're running the script from the wrong directory.
**Solution:** Navigate to the root of the repository:
```cmd
cd "c:\dev\alarm system"
pull-latest.bat
```

---

## 📝 What's New in This Pull?

### Latest Updates (2026-09-13)

✅ **Zone Expander Schematics:**
- Complete hierarchical schematic (all 9 sheets)
- Exported to PDF (802 KB, all-in-one file)
- Exported to SVG (individual sheets for web viewing)
- Full component details, part numbers, connections

✅ **System Architecture:**
- 1,300+ lines of technical documentation
- Block diagrams (ASCII art, highly detailed)
- Power distribution architecture
- Zone input signal flow and ADC voltage levels
- MCU pinout (complete 48-pin diagram)
- Ethernet communication path
- Boot sequence and operational state machines

✅ **Access Control Expander:**
- Complete hardware specification (600+ lines)
- Support for mag locks, strikes, solenoids, gates
- 8 outputs (4 relay + 4 solid-state)
- 8 door status inputs (supervised)
- Fail-safe/fail-secure modes
- Emergency unlock integration
- Forced entry detection

---

## 🚀 Next Steps

After pulling the latest changes:

1. **Review the schematics:**
   ```cmd
   start hardware\zone-expander\schematics-pdf\zone-expander-complete.pdf
   ```

2. **Read the system architecture:**
   ```cmd
   start hardware\zone-expander\SYSTEM_ARCHITECTURE.md
   ```

3. **Check out the access control spec:**
   ```cmd
   start docs\hardware\ACCESS_CONTROL_EXPANDER.md
   ```

4. **Browse all schematic sheets:**
   ```cmd
   explorer hardware\zone-expander\schematics-pdf
   ```

---

## 💡 Tips

- **Bookmark these scripts:** Create shortcuts on your desktop for quick access
- **Run regularly:** New designs and updates are added frequently
- **Check GitHub:** Visit the [Pull Request](https://github.com/cassidymug/ALARM-SYSTEM/pulls) to see what's being worked on
- **Open in browser:** SVG files render beautifully in Chrome/Firefox and are searchable

---

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Review the git status: `git status`
3. Check recent commits: `git log --oneline -5`
4. Review the PR on GitHub: [Pull Request #2](https://github.com/cassidymug/ALARM-SYSTEM/pull/2)

---

**Last Updated:** 2026-09-13  
**Branch:** `cursor/zone-expander-kicad-skeleton-daa6`  
**Author:** Guardian Project / AI Design Assistant

# 🧼 NextLayerSec Cleanup Tool (`cleanup.bat`)

A safe but thorough Windows cleanup + repair script used for client machines in support environments.

---

## ✨ Features (v1.6)

- **Disk Cleanup**
  - Temp files (user + system)
  - Recycle Bin
  - Windows Update cache + Delivery Optimization
  - Windows logs & CBS logs
  - Crash dumps & WER (ReportQueue/ReportArchive)
  - Browser caches (Chrome, Edge, Firefox)
  - Old `Windows.old` directory (if present, optional)
- **System Repair**
  - `sfc /scannow` **with live console progress** and **full log capture**
  - `DISM /RestoreHealth` and **Component Cleanup** (also live + logged)
- **Security**
  - Optional **pagefile clearing at shutdown**
- **Updates**
  - Optional Windows Update **scan only** (`UsoClient StartScan`)
- **Reboot**
  - **Interactive prompt**: “Reboot now? (Y/N)” with default and timeout
  - Or **auto-schedule** reboot (configurable delay)
- **Logging**
  - Unique log per run: `C:\CleanupLogs\cleanup_YYYY-MM-DD_HH-MM.txt`
  - SFC/DISM output is **teed** to log while showing in console

---

## ⚙️ Usage

1. **Download** `cleanup.bat`
2. **Right-click** → **Run as Administrator**
3. Follow on-screen progress; at the end you’ll be prompted to reboot (or it can auto-schedule depending on toggles).

> Typical runtime: 10–30 minutes depending on SFC/DISM and system speed.

---

## 🔧 Configuration (top of the script)

```bat
:: Toggles — set to true or false
set "CLEAR_PAGEFILE=true"           :: Wipe pagefile on next shutdown
set "DELETE_WINDOWS_OLD=true"       :: Remove C:\Windows.old if present

:: Reboot behavior
set "PROMPT_REBOOT=true"            :: Ask (Y/N) at the end
set "DEFAULT_REBOOT_CHOICE=Y"       :: Default if user doesn't answer
set "FORCE_REBOOT=false"            :: If PROMPT_REBOOT=false, auto-schedule
set "SCHEDULE_REBOOT_MINUTES=30"    :: Delay before reboot (minutes)

:: Update scan (safe, scan-only)
:: (In v1.6 this is always on; set to false if you add a toggle)

# 🧼 NextLayerSec Cleanup Tool (`cleanup.bat`)

A safe but thorough Windows cleanup and repair script used for client machines in support environments.

---

## ✨ Features (v1.5)

- **Disk Cleanup**
  - Temp files (user + system)
  - Recycle Bin
  - Windows Update cache
  - Windows logs & CBS logs
  - Crash dumps & WER
  - Browser caches (Chrome, Edge, Firefox)
  - Old `Windows.old` directory (if present)
- **System Repair**
  - Runs `sfc /scannow`
  - Runs `DISM /RestoreHealth` and component cleanup
- **Security**
  - Optional pagefile clearing at shutdown
- **Automation**
  - Forced reboot scheduled after cleanup (default: 30 min)
- **Logging**
  - Logs before/after free space to `C:\CleanupLogs\cleanup_log.txt`

---

## ⚙️ Usage

1. **Download** `cleanup.bat`
2. **Right-click** → Run as Administrator
3. Wait until cleanup finishes (may take 10–20 minutes)
4. System will reboot in 30 minutes (configurable)

---

## 🔧 Configuration

At the top of the script:

```bat
:: Toggles — set to true or false
set "CLEAR_PAGEFILE=true"
set "DELETE_WINDOWS_OLD=true"
set "FORCE_REBOOT=true"
set "SCHEDULE_REBOOT_MINUTES=30"

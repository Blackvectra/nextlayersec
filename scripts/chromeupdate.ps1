#Requires -Version 5.1

<#
.SYNOPSIS
    Secure silent Google Chrome update script for ConnectWise RMM.

.DESCRIPTION
    Downloads the latest Chrome Enterprise MSI directly from Google,
    validates its digital signature, installs silently, and verifies
    the installed version. Skips endpoints already at current version.

.NOTES
    Author  : NRG Technology Services
    Version : 2.2.0
    Context : SYSTEM (ConnectWise RMM / LabTech)
    Compatible: PowerShell 5.1+

    Changes in 2.2.0:
    - 64-bit relaunch shim (32-bit agent hosts blinded Chrome detection)
    - Write-Log no longer pollutes function return values (Write-Host)
    - TLS 1.2 enforced; -UseBasicParsing; progress bar suppressed
    - Signer check pinned to O=Google LLC
    - Chrome process handling moved to immediately before install
    - Exit codes 1641/3010 translated to 0 for RMM success detection
    - MSI verbose log relocated to NRG log directory
    - Log archive retention cap added
#>

[CmdletBinding()]
param(
    [string]$LogPath        = "C:\ProgramData\NRG\Logs\ChromeUpdate.log",
    [int]$DownloadRetries   = 3,
    [long]$MaxLogBytes      = 500KB,
    [int]$MaxArchives       = 5,
    [switch]$ForceKillChrome
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# 64-bit Relaunch Shim
# LabTech/Automate agents commonly invoke 32-bit PowerShell.
# Under WOW64 both ProgramFiles variables resolve to (x86),
# which hides 64-bit Chrome from detection. Relaunch native.
# ------------------------------------------------------------

if ($env:PROCESSOR_ARCHITEW6432 -and $PSCommandPath) {

    $nativePS = Join-Path $env:windir "sysnative\WindowsPowerShell\v1.0\powershell.exe"

    $relaunchArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $PSCommandPath)

    foreach ($entry in $PSBoundParameters.GetEnumerator()) {

        if ($entry.Value -is [System.Management.Automation.SwitchParameter]) {

            if ($entry.Value.IsPresent) { $relaunchArgs += "-$($entry.Key)" }
        }
        else {

            $relaunchArgs += "-$($entry.Key)"
            $relaunchArgs += "$($entry.Value)"
        }
    }

    & $nativePS @relaunchArgs
    exit $LASTEXITCODE
}

# ------------------------------------------------------------
# Environment Hardening
# ------------------------------------------------------------

# Google endpoints require TLS 1.2+. Stock PS 5.1 on older .NET
# or hardened Schannel configs will not negotiate it by default.
[Net.ServicePointManager]::SecurityProtocol = `
    [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# Progress rendering cripples Invoke-WebRequest throughput on 5.1.
$ProgressPreference = "SilentlyContinue"

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp][$Level] $Message"

    Add-Content -Path $LogPath -Value $line -Force

    # Write-Host keeps the success stream clean so functions that
    # log internally do not contaminate their return values.
    # Console output is still captured in RMM stdout.
    Write-Host $line
}

# ------------------------------------------------------------
# Log Rotation
# ------------------------------------------------------------

function Invoke-LogRotation {

    if (Test-Path $LogPath) {

        $size = (Get-Item $LogPath).Length

        if ($size -ge $MaxLogBytes) {

            $archivePath = $LogPath -replace '\.log$', "_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

            Move-Item -Path $LogPath -Destination $archivePath -Force

            New-Item -ItemType File -Path $LogPath -Force | Out-Null
        }
    }

    # Retention cap so archives do not accumulate indefinitely.
    $filter   = [IO.Path]::GetFileNameWithoutExtension($LogPath) + "_*.log"
    $archives = Get-ChildItem -Path (Split-Path $LogPath) -Filter $filter -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending

    if ($archives -and $archives.Count -gt $MaxArchives) {

        $archives | Select-Object -Skip $MaxArchives |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

# ------------------------------------------------------------
# Cleanup Helper
# ------------------------------------------------------------

function Remove-TempMsi {

    param([string]$Path)

    if (Test-Path $Path) {

        Remove-Item $Path -Force -ErrorAction SilentlyContinue
        Write-Log "Temporary MSI removed: $Path"
    }
}

# ------------------------------------------------------------
# Version Detection
# ------------------------------------------------------------

function Get-ChromeVersion {

    # ProgramW6432 first: resolves to 64-bit Program Files even if
    # a 32-bit host slipped past the relaunch shim.
    $roots = @(
        $env:ProgramW6432,
        $env:ProgramFiles,
        ${env:ProgramFiles(x86)}
    ) | Where-Object { $_ } | Select-Object -Unique

    foreach ($root in $roots) {

        $exe = Join-Path $root "Google\Chrome\Application\chrome.exe"

        if (Test-Path $exe) {

            return (Get-Item $exe).VersionInfo.ProductVersion
        }
    }

    return $null
}

# ------------------------------------------------------------
# Latest Version Lookup
# ------------------------------------------------------------

function Get-LatestChromeVersion {

    try {

        $uri = "https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Windows&num=1"

        $response = Invoke-RestMethod -Uri $uri -TimeoutSec 15

        return $response[0].version
    }
    catch {

        Write-Log "Could not retrieve latest Chrome version from Chromium Dash: $_" -Level WARN
        return $null
    }
}

# ------------------------------------------------------------
# Install Helper
# ------------------------------------------------------------

function Invoke-ChromeInstall {

    param([string]$MsiPath)

    $msiArgs = @(
        "/i", "`"$MsiPath`"",
        "/qn",
        "/norestart",
        "ALLUSERS=1",
        "/L*v", "`"$msiLogPath`""
    )

    $proc = Start-Process `
        -FilePath "msiexec.exe" `
        -ArgumentList $msiArgs `
        -Wait `
        -PassThru

    return $proc.ExitCode
}

# ------------------------------------------------------------
# Exit Code Resolution
# ------------------------------------------------------------

function Resolve-ExitMessage {

    param([int]$Code)

    $map = @{
        0    = "Success"
        1603 = "Fatal installation error"
        1618 = "Another installation already in progress"
        1641 = "Success - reboot initiated"
        3010 = "Success - reboot required"
    }

    if ($map.ContainsKey($Code)) { return $map[$Code] }

    return "Unknown exit code"
}

# ------------------------------------------------------------
# Initialization
# ------------------------------------------------------------

$logDir = Split-Path $LogPath

if (-not (Test-Path $logDir)) {

    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Keep the MSI verbose log with the rest of the NRG logs.
$msiLogPath = Join-Path $logDir "ChromeInstall_MSI.log"

Invoke-LogRotation

Write-Log "=============================="
Write-Log "Chrome Update Script START v2.2.0"
Write-Log "Host: $env:COMPUTERNAME"
Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Log "Process Architecture: $env:PROCESSOR_ARCHITECTURE"

if (-not ([Security.Principal.WindowsIdentity]::GetCurrent().IsSystem)) {

    Write-Log "Script not running as SYSTEM. Intended for RMM deployment." -Level WARN
}

# ------------------------------------------------------------
# Detect Installed Version
# ------------------------------------------------------------

$versionBefore = Get-ChromeVersion

if ($versionBefore) {

    Write-Log "Detected Chrome version: $versionBefore"
}
else {

    Write-Log "Chrome not currently installed." -Level WARN
}

# ------------------------------------------------------------
# Minimum Version Gate
# ------------------------------------------------------------

$latestVersion = Get-LatestChromeVersion

if ($latestVersion) {

    Write-Log "Latest stable Chrome version: $latestVersion"

    if ($versionBefore -and ([version]$versionBefore -ge [version]$latestVersion)) {

        Write-Log "Chrome is already current ($versionBefore). Skipping update."
        Write-Log "Chrome Update Script COMPLETE"
        Write-Log "=============================="

        exit 0
    }
}
else {

    Write-Log "Version gate skipped - proceeding with install regardless." -Level WARN
}

# ------------------------------------------------------------
# Download MSI
# ------------------------------------------------------------

$downloadUrl = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"

$tempMsi = Join-Path $env:TEMP "ChromeEnterprise64.msi"

$downloadSuccess = $false

for ($i = 1; $i -le $DownloadRetries; $i++) {

    try {

        Write-Log "Download attempt $i of $DownloadRetries"

        Invoke-WebRequest `
            -Uri $downloadUrl `
            -OutFile $tempMsi `
            -UseBasicParsing `
            -TimeoutSec 120

        if (Test-Path $tempMsi) {

            $downloadSuccess = $true
            break
        }
    }
    catch {

        Write-Log "Download attempt $i failed: $_" -Level WARN

        if ($i -lt $DownloadRetries) {

            Start-Sleep 10
        }
    }
}

if (-not $downloadSuccess) {

    Write-Log "Download failed after $DownloadRetries attempts." -Level ERROR
    exit 1
}

$fileSize = (Get-Item $tempMsi).Length

Write-Log "MSI downloaded. Size: $([math]::Round($fileSize / 1MB,2)) MB"

if ($fileSize -lt 50MB) {

    Write-Log "Downloaded MSI appears invalid (size check failed)." -Level ERROR
    Remove-TempMsi $tempMsi
    exit 1
}

# ------------------------------------------------------------
# Verify Digital Signature
# ------------------------------------------------------------

$signature = Get-AuthenticodeSignature $tempMsi

if ($signature.Status -ne "Valid") {

    Write-Log "MSI signature validation failed. Status: $($signature.Status)" -Level ERROR
    Remove-TempMsi $tempMsi
    exit 1
}

# Pin to the organization attribute. A bare 'Google' substring match
# would pass any validly signed cert with a lookalike subject.
if ($signature.SignerCertificate.Subject -notmatch 'O=Google LLC') {

    Write-Log "Unexpected MSI signer: $($signature.SignerCertificate.Subject)" -Level ERROR
    Remove-TempMsi $tempMsi
    exit 1
}

Write-Log "MSI signature verified. Signer: $($signature.SignerCertificate.Subject); Thumbprint: $($signature.SignerCertificate.Thumbprint)"

# ------------------------------------------------------------
# Handle Running Chrome Processes
# (Immediately before install - the download window is long
# enough for a user to relaunch Chrome.)
# ------------------------------------------------------------

$chromeProcesses = Get-Process chrome -ErrorAction SilentlyContinue

if ($chromeProcesses) {

    if ($ForceKillChrome) {

        Write-Log "Chrome running - terminating processes prior to install."

        $chromeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue

        Start-Sleep 3
    }
    else {

        Write-Log "Chrome running - install proceeds; binary swap completes on next relaunch." -Level WARN
    }
}

# ------------------------------------------------------------
# Install Chrome
# ------------------------------------------------------------

Write-Log "Launching msiexec installer..."

$exitCode = Invoke-ChromeInstall -MsiPath $tempMsi

Write-Log "Installer exit code: $exitCode ($(Resolve-ExitMessage $exitCode))"

# ------------------------------------------------------------
# Exit Code Handling
# ------------------------------------------------------------

$successCodes = @(0, 1641, 3010)
$rebootCodes  = @(1641, 3010)
$fatalCodes   = @(1603)

if ($exitCode -eq 1618) {

    Write-Log "Competing installer detected. Waiting 120 seconds then retrying..." -Level WARN

    Start-Sleep 120

    $exitCode = Invoke-ChromeInstall -MsiPath $tempMsi

    Write-Log "Retry installer exit code: $exitCode ($(Resolve-ExitMessage $exitCode))"
}

if ($exitCode -in $fatalCodes) {

    Write-Log "Fatal installer error. MSI verbose log: $msiLogPath" -Level ERROR
    Remove-TempMsi $tempMsi
    exit 1
}

if ($exitCode -notin $successCodes) {

    Write-Log "Installer returned non-success exit code: $exitCode" -Level ERROR
    Remove-TempMsi $tempMsi
    exit 1
}

if ($exitCode -in $rebootCodes) {

    Write-Log "Install succeeded; reboot required to finalize (msiexec $exitCode)." -Level WARN
}

# ------------------------------------------------------------
# Version Verification
# ------------------------------------------------------------

Start-Sleep 5

$versionAfter = Get-ChromeVersion

if ($versionAfter) {

    Write-Log "Chrome version after update: $versionAfter"

    if ($versionBefore -and ($versionAfter -eq $versionBefore)) {

        Write-Log "On-disk version unchanged. If Chrome was running during install, the new build applies after relaunch; otherwise system was already current." -Level WARN
    }
    elseif ($versionBefore) {

        Write-Log "Upgrade successful: $versionBefore -> $versionAfter"
    }
    else {

        Write-Log "Chrome installed fresh: $versionAfter"
    }
}
else {

    Write-Log "Unable to detect Chrome version after installation." -Level WARN
}

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------

Remove-TempMsi $tempMsi

Write-Log "Chrome Update Script COMPLETE"
Write-Log "=============================="

# All success paths (0, 1641, 3010) report 0 so the RMM does not
# flag reboot-required endpoints as failed runs. Raw msiexec code
# is preserved in the log.
exit 0

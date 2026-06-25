[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptPath,

    [string[]]$ArgumentList = @(),

    [string]$LogDirectory = "",

    [switch]$Wait
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-LogDirectory {
    param([string]$Requested)

    if ($Requested) {
        return [System.IO.Path]::GetFullPath($Requested)
    }

    $localAppData = [Environment]::GetFolderPath("LocalApplicationData")
    if ([string]::IsNullOrWhiteSpace($localAppData)) {
        return [System.IO.Path]::Combine($PWD.Path, "logs")
    }

    return [System.IO.Path]::Combine($localAppData, "AgentAutomationTemplates", "logs")
}

function Quote-Argument {
    param([string]$Value)

    if ($Value -notmatch '\s|"') {
        return $Value
    }

    return '"' + ($Value -replace '"', '\"') + '"'
}

$resolvedScript = [System.IO.Path]::GetFullPath($ScriptPath)
if (-not (Test-Path -LiteralPath $resolvedScript -PathType Leaf)) {
    throw "ScriptPath does not exist: $resolvedScript"
}

$logRoot = Resolve-LogDirectory -Requested $LogDirectory
New-Item -ItemType Directory -Force -Path $logRoot | Out-Null

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedScript)
$stdoutPath = Join-Path $logRoot "$baseName-$stamp.out.log"
$stderrPath = Join-Path $logRoot "$baseName-$stamp.err.log"

$psArgs = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $resolvedScript
) + $ArgumentList

$startInfo = @{
    FilePath = "powershell.exe"
    ArgumentList = $psArgs
    WindowStyle = "Hidden"
    RedirectStandardOutput = $stdoutPath
    RedirectStandardError = $stderrPath
    PassThru = $true
}

if ($Wait) {
    $startInfo.Wait = $true
}

$process = Start-Process @startInfo

[pscustomobject]@{
    ProcessId = $process.Id
    ScriptPath = $resolvedScript
    StdoutLog = $stdoutPath
    StderrLog = $stderrPath
    Waited = [bool]$Wait
    ExitCode = if ($Wait) { $process.ExitCode } else { $null }
}


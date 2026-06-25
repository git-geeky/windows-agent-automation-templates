[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Command,

    [switch]$AllowDestructive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$secretPattern = '(?i)\b(api[_-]?key|access[_-]?token|refresh[_-]?token|password|secret)\b'
$destructivePatterns = @(
    '(?i)\brm\s+-rf\b',
    '(?i)\bRemove-Item\b.*\b-Recurse\b',
    '(?i)\bgit\s+reset\s+--hard\b'
)

if ($Command -match $secretPattern) {
    [pscustomobject]@{
        Verdict = "review"
        Reason = "command mentions credential-like terms"
    }
    exit 2
}

foreach ($pattern in $destructivePatterns) {
    if ($Command -match $pattern -and -not $AllowDestructive) {
        [pscustomobject]@{
            Verdict = "block"
            Reason = "destructive command requires explicit approval"
        }
        exit 3
    }
}

[pscustomobject]@{
    Verdict = "allow"
    Reason = "no generic policy concern detected"
}


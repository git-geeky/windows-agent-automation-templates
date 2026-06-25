[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Manifest,

    [Parameter(Mandatory = $true)]
    [string]$Template,

    [Parameter(Mandatory = $true)]
    [string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Read-JsonObject {
    param([string]$Path)

    $payload = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    if ($null -eq $payload) {
        throw "Manifest is empty: $Path"
    }
    return $payload
}

function ConvertTo-ReplacementMap {
    param($Payload)

    $map = @{}
    foreach ($property in $Payload.PSObject.Properties) {
        $name = "{{" + $property.Name + "}}"
        $value = [string]$property.Value
        if ($value -match '[\x00-\x08\x0B\x0C\x0E-\x1F]') {
            throw "Manifest value for $($property.Name) contains unsupported control characters"
        }
        $map[$name] = $value
    }
    return $map
}

$manifestPath = [System.IO.Path]::GetFullPath($Manifest)
$templatePath = [System.IO.Path]::GetFullPath($Template)
$outputPath = [System.IO.Path]::GetFullPath($OutFile)

$payload = Read-JsonObject -Path $manifestPath
$replacements = ConvertTo-ReplacementMap -Payload $payload
$text = Get-Content -LiteralPath $templatePath -Raw

foreach ($key in $replacements.Keys) {
    $text = $text.Replace($key, $replacements[$key])
}

if ($text -match '{{[^}]+}}') {
    throw "Template still contains unreplaced placeholders"
}

$null = [xml]$text
$outputDirectory = Split-Path -Parent $outputPath
if ($outputDirectory) {
    New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
}
Set-Content -LiteralPath $outputPath -Value $text -Encoding Unicode
[pscustomobject]@{
    Template = $templatePath
    Manifest = $manifestPath
    OutFile = $outputPath
}

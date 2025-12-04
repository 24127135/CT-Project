<#
Generate env.js for runtime injection (for `index.html` that reads `window.__ENV`).

This script reads environment variables and
writes `env.js` next to the project `index.html` (repo root).

Usage (PowerShell):
  # Option 1: Use system environment variables
  ./scripts/generate_env_js.ps1

  # Option 2: Load from frontend/.env (requires simple parsing)
  ./scripts/generate_env_js.ps1 -UseDotenv

#>

param(
    [switch]$UseDotenv
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$envFile = Join-Path $root "../frontend/.env"

function Read-Dotenv($path) {
    $map = @{}
    if (-Not (Test-Path $path)) { return $map }
    Get-Content $path | ForEach-Object {
        $line = $_.Trim()
        if ($line -eq '' -or $line.StartsWith('#')) { return }
        $parts = $line -split '=', 2
        if ($parts.Length -eq 2) {
            $map[$parts[0].Trim()] = $parts[1].Trim()
        }
    }
    return $map
}

$values = @{}
if ($UseDotenv) {
    $values = Read-Dotenv -path $envFile
} else {
    $values['SUPABASE_URL'] = [Environment]::GetEnvironmentVariable('SUPABASE_URL')
    $values['SUPABASE_ANON_KEY'] = [Environment]::GetEnvironmentVariable('SUPABASE_ANON_KEY')
    $values['MAPTILER_KEY'] = [Environment]::GetEnvironmentVariable('MAPTILER_KEY')
    $values['GEMINI_API_KEY'] = [Environment]::GetEnvironmentVariable('GEMINI_API_KEY')
}

$out = "window.__ENV = {`n"
$pairs = @()
$foreach = @()
foreach ($k in $values.Keys) {
    $v = $values[$k]
    if (-not $v) { $v = '' }
    # Escape double-quotes for safe JS string literal
    $escaped = $v -replace '"','\"'
    $pairs += "  $($k): `"$escaped`""
}
$out += ($pairs -join ",`n")
$out += "`n};`n"

$dest = Join-Path $root "../env.js"
Set-Content -Path $dest -Value $out -Encoding UTF8
Write-Host "Wrote: $dest"
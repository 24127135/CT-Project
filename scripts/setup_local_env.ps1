<#
Setup Local Environment

This script will create local `.env` files for backend and frontend from their `.env.example` files
only if those `.env` files do not already exist. It will NOT populate secrets — you must edit
the generated files and fill in real values locally.

Usage (PowerShell):
  ./scripts/setup_local_env.ps1
#>

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition


# Always create per-service .env from examples. Do NOT auto-copy from repo-level .env.
# This keeps the repo `.env` authoritative while allowing local service examples to exist.

if (-Not (Test-Path (Join-Path $root '../.env'))) {
    if (Test-Path (Join-Path $root '../.env.example')) {
        Copy-Item -Path (Join-Path $root '../.env.example') -Destination (Join-Path $root '../.env')
        Write-Host "Created repo .env from .env.example"
    } else {
        Write-Host "No .env.example found at repo root. Nothing created."
    }
} else {
    Write-Host "Repo .env already exists - no changes made."
}

Write-Host 'Done. Edit the repo `.env` and DO NOT commit real secrets.' -ForegroundColor Green
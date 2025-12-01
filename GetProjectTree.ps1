# File: GetProjectTree.ps1
<#
.SYNOPSIS
    Displays the directory tree of a project excluding .venv, cache folders, git folders, and .gitignore patterns.

.PARAMETER Path
    The root directory of the project. Defaults to the current directory.

.EXAMPLE
    ./GetProjectTree.ps1 -Path "C:\MyProject"
#>

param(
    [string]$Path = "."
)

# Normalize path
$FullPath = Resolve-Path $Path

# Read .gitignore patterns if exists
$gitignorePath = Join-Path $FullPath ".gitignore"
$gitignorePatterns = @()

if (Test-Path $gitignorePath) {
    $gitignorePatterns = Get-Content $gitignorePath | Where-Object {
        $_ -and ($_ -notmatch '^\s*#') # Ignore comments and empty lines
    }
}

# Add default exclusions
$excludedPatterns = @(".venv", "__pycache__", ".git")
$excludedPatterns += $gitignorePatterns

# Function to test exclusion
function Test-IsExcluded($path) {
    foreach ($pattern in $excludedPatterns) {
        if ($path -like "*$pattern*") {
            return $true
        }
    }
    return $false
}

Write-Host "Project Tree for: $FullPath`n" -ForegroundColor Cyan

function Show-Tree($directory, $indent = "") {
    $items = Get-ChildItem -LiteralPath $directory | Sort-Object Name
    foreach ($item in $items) {
        if (Test-IsExcluded $item.FullName) {
            continue
        }
        if ($item.PSIsContainer) {
            Write-Host "$indent|-- [DIR] $($item.Name)"
            Show-Tree $item.FullName "$indent|   "
        } else {
            Write-Host "$indent|-- $($item.Name)"
        }
    }
}

Show-Tree $FullPath

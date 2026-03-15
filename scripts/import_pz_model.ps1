<#
  ________________________________________________________________________
 / Copyright (c) 2026 Phobos A. D'thorga                                \
 |                                                                        |
 |           /\_/\                                                         |
 |         =/ o o \=    Phobos' PZ Modding                                |
 |          (  V  )     All rights reserved.                              |
 |     /\  / \   / \                                                      |
 |    /  \/   '-'   \   This source code is part of the Phobos            |
 |   /  /  \  ^  /\  \  mod suite for Project Zomboid (Build 42).         |
 |  (__/    \_/ \/  \__)                                                  |
 |     |   | |  | |     Unauthorised copying, modification, or            |
 |     |___|_|  |_|     distribution of this file is prohibited.          |
 |                                                                        |
 \________________________________________________________________________/

  import_pz_model.ps1
  Automates the Blender-to-PZ model import pipeline for PCP.

  Handles: FBX export (via Blender CLI), file placement, model definition
  generation, and item script updates.

  Usage:
    pwsh scripts/import_pz_model.ps1 `
        -BlendFile "D:\Models\acid_jar.blend" `
        -ModelName "PCP_SulphuricAcidJar" `
        -TextureFile "D:\Models\acid_jar.png" `
        -Items "SulphuricAcidJar" `
        -Scale 0.4

    # Dry run (preview changes without writing):
    pwsh scripts/import_pz_model.ps1 `
        -BlendFile "D:\Models\acid_jar.blend" `
        -ModelName "PCP_SulphuricAcidJar" `
        -DryRun

  See docs/3d-model-pipeline.md for full documentation.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$BlendFile,

    [Parameter(Mandatory = $true)]
    [string]$ModelName,

    [string]$TextureFile,

    [string[]]$Items,

    [ValidateSet("Static", "World", "Both")]
    [string]$ModelType = "Both",

    [float]$Scale = 0.4,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Configuration ─────────────────────────────────────────────────────────

$BLENDER_PATH = "C:\Program Files\Blender Foundation\Blender 5.0\blender.exe"
$REPO_ROOT = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$EXPORT_SCRIPT = Join-Path $PSScriptRoot "export_blender_model.py"

$MODELS_DIR = Join-Path $REPO_ROOT "common\media\models_X\PCP"
$TEXTURES_DIR = Join-Path $REPO_ROOT "common\media\textures\PCP"
$MODEL_DEF_FILE = Join-Path $REPO_ROOT "common\media\scripts\models_PCP.txt"
$ITEMS_DIR = Join-Path $REPO_ROOT "common\media\scripts\items"

# Copyright header for models_PCP.txt (PZ script file format)
$MODEL_FILE_HEADER = @"
/* ________________________________________________________________________
 / Copyright (c) 2026 Phobos A. D'thorga                                \
 |                                                                        |
 |           /\_/\                                                         |
 |         =/ o o \=    Phobos' PZ Modding                                |
 |          (  V  )     All rights reserved.                              |
 |     /\  / \   / \                                                      |
 |    /  \/   '-'   \   This source code is part of the Phobos            |
 |   /  /  \  ^  /\  \  mod suite for Project Zomboid (Build 42).         |
 |  (__/    \_/ \/  \__)                                                  |
 |     |   | |  | |     Unauthorised copying, modification, or            |
 |     |___|_|  |_|     distribution of this file is prohibited.          |
 |                                                                        |
 \________________________________________________________________________/
*/

module PhobosChemistryPathways
{
"@

$MODEL_FILE_FOOTER = "}`n"

# ─── Helper Functions ──────────────────────────────────────────────────────

function Write-Step {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor Cyan
}

function Write-Action {
    param([string]$Message)
    Write-Host "    $Message"
}

function Write-DryRun {
    param([string]$Message)
    Write-Host "    [DRY RUN] $Message" -ForegroundColor Yellow
}

function Write-Warn {
    param([string]$Message)
    Write-Host "    WARNING: $Message" -ForegroundColor DarkYellow
}

# ─── Validation ────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "PCP 3D Model Import Pipeline" -ForegroundColor Green
Write-Host "  Model:  $ModelName"
Write-Host "  Blend:  $BlendFile"
Write-Host "  Scale:  $Scale"
Write-Host "  Type:   $ModelType"
if ($DryRun) {
    Write-Host "  Mode:   DRY RUN (no files will be written)" -ForegroundColor Yellow
}
Write-Host ""

# Validate .blend file
if (-not (Test-Path $BlendFile)) {
    Write-Host "ERROR: Blend file not found: $BlendFile" -ForegroundColor Red
    exit 1
}

# Validate Blender installation
if (-not (Test-Path $BLENDER_PATH)) {
    Write-Host "ERROR: Blender not found at: $BLENDER_PATH" -ForegroundColor Red
    Write-Host "  Install Blender 5.0 or update `$BLENDER_PATH in this script."
    exit 1
}

# Validate export script
if (-not (Test-Path $EXPORT_SCRIPT)) {
    Write-Host "ERROR: Export script not found: $EXPORT_SCRIPT" -ForegroundColor Red
    exit 1
}

# Validate model name format
if ($ModelName -notmatch "^PCP_[A-Z][A-Za-z0-9]+$") {
    Write-Warn "Model name '$ModelName' doesn't follow PCP_<PascalCaseName> convention"
}

# Validate texture file if provided
if ($TextureFile -and -not (Test-Path $TextureFile)) {
    Write-Host "ERROR: Texture file not found: $TextureFile" -ForegroundColor Red
    exit 1
}

# ─── Step 1: Export FBX via Blender CLI ────────────────────────────────────

$fbxOutput = Join-Path $MODELS_DIR "$ModelName.fbx"

Write-Step "Step 1: Export FBX via Blender CLI"

if ($DryRun) {
    Write-DryRun "Would run: blender --background --python export_blender_model.py -- --input `"$BlendFile`" --output `"$fbxOutput`""
}
else {
    # Ensure models directory exists
    if (-not (Test-Path $MODELS_DIR)) {
        New-Item -ItemType Directory -Path $MODELS_DIR -Force | Out-Null
        Write-Action "Created directory: $MODELS_DIR"
    }

    Write-Action "Running Blender export..."

    $blenderArgs = @(
        "--background",
        "--python", $EXPORT_SCRIPT,
        "--",
        "--input", $BlendFile,
        "--output", $fbxOutput,
        "--scale", "1.0"
    )

    $process = Start-Process -FilePath $BLENDER_PATH -ArgumentList $blenderArgs `
        -NoNewWindow -Wait -PassThru -RedirectStandardOutput "$env:TEMP\pcp_blender_stdout.txt" `
        -RedirectStandardError "$env:TEMP\pcp_blender_stderr.txt"

    # Show Blender output
    if (Test-Path "$env:TEMP\pcp_blender_stdout.txt") {
        Get-Content "$env:TEMP\pcp_blender_stdout.txt" | ForEach-Object {
            Write-Host "    [Blender] $_" -ForegroundColor DarkGray
        }
    }

    if ($process.ExitCode -ne 0) {
        Write-Host "ERROR: Blender export failed (exit code $($process.ExitCode))" -ForegroundColor Red
        if (Test-Path "$env:TEMP\pcp_blender_stderr.txt") {
            Get-Content "$env:TEMP\pcp_blender_stderr.txt" | ForEach-Object {
                Write-Host "    [Blender] $_" -ForegroundColor Red
            }
        }
        exit 1
    }

    if (-not (Test-Path $fbxOutput)) {
        Write-Host "ERROR: FBX file was not created: $fbxOutput" -ForegroundColor Red
        exit 1
    }

    $fbxSize = (Get-Item $fbxOutput).Length
    Write-Action "Exported: $fbxOutput ($($fbxSize.ToString('N0')) bytes)"
}

Write-Host ""

# ─── Step 2: Copy Texture ─────────────────────────────────────────────────

if ($TextureFile) {
    Write-Step "Step 2: Copy texture"

    $texDest = Join-Path $TEXTURES_DIR "$ModelName.png"

    if ($DryRun) {
        Write-DryRun "Would copy: $TextureFile -> $texDest"
    }
    else {
        if (-not (Test-Path $TEXTURES_DIR)) {
            New-Item -ItemType Directory -Path $TEXTURES_DIR -Force | Out-Null
            Write-Action "Created directory: $TEXTURES_DIR"
        }

        Copy-Item -Path $TextureFile -Destination $texDest -Force
        Write-Action "Copied: $texDest"
    }
}
else {
    Write-Step "Step 2: No texture file provided (skipped)"
}

Write-Host ""

# ─── Step 3: Generate Model Definition ─────────────────────────────────────

Write-Step "Step 3: Generate model definition"

# Build the model block
$meshRef = "PCP/$ModelName"
$texRef = if ($TextureFile) { "PCP/$ModelName" } else { $null }

$modelBlock = "    model $ModelName`n    {`n"
$modelBlock += "        mesh = $meshRef,`n"
if ($texRef) {
    $modelBlock += "        texture = $texRef,`n"
}
$modelBlock += "        scale = $Scale,`n"
$modelBlock += "        attachment world`n"
$modelBlock += "        {`n"
$modelBlock += "            offset = 0.0 0.0 0.0,`n"
$modelBlock += "            rotate = 0.0 0.0 0.0,`n"
$modelBlock += "        }`n"
$modelBlock += "    }"

Write-Action "Model block:"
$modelBlock -split "`n" | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }

if ($DryRun) {
    Write-DryRun "Would write to: $MODEL_DEF_FILE"
}
else {
    if (-not (Test-Path $MODEL_DEF_FILE)) {
        # Create new file with header + this model + footer
        $content = $MODEL_FILE_HEADER + "`n" + $modelBlock + "`n" + $MODEL_FILE_FOOTER
        $scriptsDir = Split-Path $MODEL_DEF_FILE -Parent
        if (-not (Test-Path $scriptsDir)) {
            New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
        }
        [System.IO.File]::WriteAllText($MODEL_DEF_FILE, $content, [System.Text.UTF8Encoding]::new($false))
        Write-Action "Created: $MODEL_DEF_FILE"
    }
    else {
        # Read existing file, insert model block before the closing brace
        $existingContent = [System.IO.File]::ReadAllText($MODEL_DEF_FILE)

        # Check for duplicate model name
        if ($existingContent -match "model\s+$([regex]::Escape($ModelName))\b") {
            Write-Warn "Model '$ModelName' already exists in $MODEL_DEF_FILE — skipping"
        }
        else {
            # Insert before the final closing brace of the module block
            $lastBrace = $existingContent.LastIndexOf("}")
            if ($lastBrace -ge 0) {
                $before = $existingContent.Substring(0, $lastBrace)
                $after = $existingContent.Substring($lastBrace)
                $newContent = $before + "`n" + $modelBlock + "`n" + $after
                [System.IO.File]::WriteAllText($MODEL_DEF_FILE, $newContent, [System.Text.UTF8Encoding]::new($false))
                Write-Action "Appended to: $MODEL_DEF_FILE"
            }
            else {
                Write-Host "ERROR: Could not find closing brace in $MODEL_DEF_FILE" -ForegroundColor Red
                exit 1
            }
        }
    }
}

Write-Host ""

# ─── Step 4: Update Item Definitions ──────────────────────────────────────

if ($Items -and $Items.Count -gt 0) {
    Write-Step "Step 4: Update item definitions"

    foreach ($itemName in $Items) {
        Write-Action "Updating item: $itemName"

        # Find the item definition file
        $itemFiles = Get-ChildItem -Path $ITEMS_DIR -Filter "*.txt" -Recurse | Where-Object {
            (Get-Content $_.FullName -Raw) -match "item\s+$([regex]::Escape($itemName))\b"
        }

        if ($itemFiles.Count -eq 0) {
            Write-Warn "Item '$itemName' not found in any file under $ITEMS_DIR"
            continue
        }

        foreach ($itemFile in $itemFiles) {
            $content = [System.IO.File]::ReadAllText($itemFile.FullName)

            # Find the item block
            $itemPattern = "(item\s+$([regex]::Escape($itemName))\s*\{)"
            if ($content -notmatch $itemPattern) {
                Write-Warn "Could not parse item block for '$itemName' in $($itemFile.Name)"
                continue
            }

            $changes = @()

            # Add/update StaticModel
            if ($ModelType -eq "Static" -or $ModelType -eq "Both") {
                if ($content -match "(?m)(^\s*StaticModel\s*=\s*).*(,\s*$)") {
                    # Replace existing
                    $content = $content -replace "(?m)(^\s*StaticModel\s*=\s*).*?(,\s*$)", "`${1}$ModelName`${2}"
                    $changes += "StaticModel (updated)"
                }
                else {
                    # Find a good insertion point: after the item opening brace line
                    # Look for the first property line and insert before it
                    $content = $content -replace $itemPattern, "`$1`n        StaticModel = $ModelName,"
                    $changes += "StaticModel (added)"
                }
            }

            # Add/update WorldStaticModel
            if ($ModelType -eq "World" -or $ModelType -eq "Both") {
                if ($content -match "(?m)(^\s*WorldStaticModel\s*=\s*).*(,\s*$)") {
                    $content = $content -replace "(?m)(^\s*WorldStaticModel\s*=\s*).*?(,\s*$)", "`${1}$ModelName`${2}"
                    $changes += "WorldStaticModel (updated)"
                }
                else {
                    $content = $content -replace $itemPattern, "`$1`n        WorldStaticModel = $ModelName,"
                    $changes += "WorldStaticModel (added)"
                }
            }

            if ($DryRun) {
                Write-DryRun "Would update $($itemFile.Name): $($changes -join ', ')"
            }
            else {
                [System.IO.File]::WriteAllText($itemFile.FullName, $content, [System.Text.UTF8Encoding]::new($false))
                Write-Action "$($itemFile.Name): $($changes -join ', ')"
            }
        }
    }
}
else {
    Write-Step "Step 4: No items specified (skipped)"
}

Write-Host ""

# ─── Summary ──────────────────────────────────────────────────────────────

Write-Host "─── Summary ───────────────────────────────────────────────" -ForegroundColor Green
Write-Host ""

$summary = @()

if (-not $DryRun) {
    if (Test-Path $fbxOutput) {
        $summary += "  FBX:        $fbxOutput"
    }
    if ($TextureFile) {
        $texDest = Join-Path $TEXTURES_DIR "$ModelName.png"
        if (Test-Path $texDest) {
            $summary += "  Texture:    $texDest"
        }
    }
    $summary += "  Model def:  $MODEL_DEF_FILE"
    if ($Items) {
        $summary += "  Items:      $($Items -join ', ')"
    }
}
else {
    $summary += "  Dry run complete — no files were written."
}

$summary | ForEach-Object { Write-Host $_ }

Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Cyan
Write-Host "    1. Test in-game: spawn item and check model renders"
Write-Host "    2. Tune offset/rotate/scale in models_PCP.txt"
Write-Host "    3. Commit changes and verify CI"
Write-Host ""
Write-Host "Done." -ForegroundColor Green

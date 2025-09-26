# Sparrow PowerShell Script - Equivalente a sparrow.sh para Windows
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Query,
    
    [Parameter(Position=1)]
    [string]$FilePath = $null,
    
    [string]$Pipeline = "sparrow-parse",
    
    [string[]]$Options = @(),
    
    [int]$CropSize = $null,
    
    [switch]$Instruction,
    
    [switch]$Validation,
    
    [string[]]$PageType = @(),
    
    [string]$DebugDir = $null,
    
    [switch]$Debug
)

# Verificar versión de Python
$pythonVersion = python --version 2>&1
Write-Host "Detected Python version: $pythonVersion" -ForegroundColor Green

if (-not ($pythonVersion -like "*3.12.10*")) {
    Write-Error "Python version 3.12.10 is required. Current version is $pythonVersion. Aborting."
    exit 1
}

# Determinar script a ejecutar
$pythonScript = "engine.py"
if ($Query -eq "assistant") {
    $pythonScript = "assistant.py"
    # Shift arguments (remove first argument)
    $Query = $FilePath
    $FilePath = $Pipeline
    $Pipeline = if ($Options.Count -gt 0) { $Options[0] } else { "sparrow-parse" }
    $Options = $Options[1..($Options.Count-1)]
}

# Construir argumentos
$arguments = @($Query)

if ($FilePath) { 
    $arguments += "--file-path"
    $arguments += $FilePath 
}

$arguments += "--pipeline"
$arguments += $Pipeline

if ($Options.Count -gt 0) {
    foreach ($option in $Options) {
        $arguments += "--options"
        $arguments += $option
    }
}

if ($CropSize) { 
    $arguments += "--crop-size"
    $arguments += $CropSize 
}

if ($Instruction) { $arguments += "--instruction" }
if ($Validation) { $arguments += "--validation" }

if ($PageType.Count -gt 0) {
    foreach ($type in $PageType) {
        $arguments += "--page-type"
        $arguments += $type
    }
}

if ($DebugDir) { 
    $arguments += "--debug-dir"
    $arguments += $DebugDir 
}

if ($Debug) { $arguments += "--debug" }

# Ejecutar comando
Write-Host "Executing: python $pythonScript $($arguments -join ' ')" -ForegroundColor Cyan
& python $pythonScript @arguments

# Uso:
# .\sparrow.ps1 '{"field":"value"}' -Pipeline "sparrow-parse" -Options "ollama","qwen2.5vl:7b" -FilePath "document.pdf"
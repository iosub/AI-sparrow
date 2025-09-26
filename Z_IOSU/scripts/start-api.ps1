# Script para iniciar la API de Sparrow con entorno correcto
param(
    [int]$Port = 8002,
    [string]$Component = "sparrow-parse"
)

$rootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

switch ($Component) {
    "sparrow-parse" {
        $envPath = "$rootPath\sparrow-ml\llm\.env_sparrow_parse\Scripts\Activate.ps1"
        $workDir = "$rootPath\sparrow-ml\llm"
        Write-Host "[SPARROW-PARSE] Iniciando API en puerto $Port..." -ForegroundColor Green
    }
    "agents" {
        $envPath = "$rootPath\sparrow-ml\agents\.env_agents\Scripts\Activate.ps1"
        $workDir = "$rootPath\sparrow-ml\agents"
        Write-Host "[AGENTS] Iniciando API en puerto $Port..." -ForegroundColor Magenta
    }
    "ocr" {
        $envPath = "$rootPath\sparrow-data\ocr\.env_ocr\Scripts\Activate.ps1"
        $workDir = "$rootPath\sparrow-data\ocr"
        Write-Host "[OCR] Iniciando API en puerto $Port..." -ForegroundColor Yellow
    }
    "ui" {
        $envPath = "$rootPath\sparrow-ui\shell\.env_ui\Scripts\Activate.ps1"
        $workDir = "$rootPath\sparrow-ui\shell"
        Write-Host "[UI] Iniciando API en puerto $Port..." -ForegroundColor Cyan
    }
}

if (Test-Path $envPath) {
    Set-Location $workDir
    & $envPath
    Write-Host "[INFO] Entorno activado. Iniciando API..." -ForegroundColor Gray
    Write-Host "[INFO] Directorio: $(Get-Location)" -ForegroundColor Gray
    Write-Host "[INFO] Acceso: http://localhost:$Port/docs" -ForegroundColor Blue
    python api.py --port $Port
} else {
    Write-Error "[ERROR] No se encontró el entorno en: $envPath"
}

# Uso:
# .\start-api.ps1 -Port 8002 -Component "sparrow-parse"
# .\start-api.ps1 -Port 8001 -Component "agents"
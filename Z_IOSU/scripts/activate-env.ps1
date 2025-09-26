# Scripts de utilidad para activar entornos Sparrow
# Usar con: . .\activate-env.ps1 <nombre-entorno>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("sparrow-parse", "instructor", "ocr", "agents", "ui")]
    [string]$Environment
)

$rootPath = "C:\IA\ejemplos\AI-sparrow"

switch ($Environment) {
    "sparrow-parse" {
        $envPath = "$rootPath\sparrow-ml\llm\.env_sparrow_parse\Scripts\Activate.ps1"
        Write-Host "[SPARROW-PARSE] Activando entorno..." -ForegroundColor Green
        Set-Location "$rootPath\sparrow-ml\llm"
    }
    "instructor" {
        $envPath = "$rootPath\sparrow-ml\llm\.env_instructor\Scripts\Activate.ps1"
        Write-Host "[INSTRUCTOR] Activando entorno..." -ForegroundColor Blue
        Set-Location "$rootPath\sparrow-ml\llm"
    }
    "ocr" {
        $envPath = "$rootPath\sparrow-data\ocr\.env_ocr\Scripts\Activate.ps1"
        Write-Host "[OCR] Activando entorno..." -ForegroundColor Yellow
        Set-Location "$rootPath\sparrow-data\ocr"
    }
    "agents" {
        $envPath = "$rootPath\sparrow-ml\agents\.env_agents\Scripts\Activate.ps1"
        Write-Host "[AGENTS] Activando entorno..." -ForegroundColor Magenta
        Set-Location "$rootPath\sparrow-ml\agents"
    }
    "ui" {
        $envPath = "$rootPath\sparrow-ui\shell\.env_ui\Scripts\Activate.ps1"
        Write-Host "[UI] Activando entorno..." -ForegroundColor Cyan
        Set-Location "$rootPath\sparrow-ui\shell"
    }
}

if (Test-Path $envPath) {
    & $envPath
    Write-Host "[OK] Entorno $Environment activado correctamente" -ForegroundColor Green
    Write-Host "[INFO] Directorio actual: $(Get-Location)" -ForegroundColor Gray
} else {
    Write-Error "[ERROR] No se encontró el entorno en: $envPath"
}

# Uso:
# . .\Z_IOSU\scripts\activate-env.ps1 sparrow-parse
# . .\Z_IOSU\scripts\activate-env.ps1 instructor
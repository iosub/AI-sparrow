# Sparrow Multi-Service Starter Script
# Inicia todos los servicios de Sparrow en paralelo, cada uno en su entorno virtual

param(
    [switch]$StartAll,
    [switch]$StopAll,
    [switch]$Status,
    [string[]]$Services = @(),
    [switch]$ShowLogs
)

$rootPath = "C:\IA\ejemplos\AI-sparrow"
$logDir = "$rootPath\Z_IOSU\logs"

# Crear directorio de logs si no existe
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Definición de servicios
$serviceDefinitions = @{
    "api-main" = @{
        name = "Sparrow Main API"
        path = "$rootPath\sparrow-ml\llm"
        env = ".\.env_sparrow_parse\Scripts\Activate.ps1"
        command = "python api.py --port 8002"
        port = 8002
        logfile = "$logDir\api-main.log"
        color = "Green"
    }
    "api-agents" = @{
        name = "Sparrow Agents API"
        path = "$rootPath\sparrow-ml\agents"
        env = ".\.env_agents\Scripts\Activate.ps1"
        command = "python api.py --port 8001"
        port = 8001
        logfile = "$logDir\api-agents.log"
        color = "Blue"
    }
    "api-ocr" = @{
        name = "Sparrow OCR API"
        path = "$rootPath\sparrow-data\ocr"
        env = ".\.env_ocr\Scripts\Activate.ps1"
        command = "python api.py --port 8003"
        port = 8003
        logfile = "$logDir\api-ocr.log"
        color = "Yellow"
    }
    "ui-web" = @{
        name = "Sparrow Web UI"
        path = "$rootPath\sparrow-ui\shell"
        env = ".\.env_ui\Scripts\Activate.ps1"
        command = "python app.py"
        port = 7860
        logfile = "$logDir\ui-web.log"
        color = "Cyan"
    }
}

function Start-SparrowService {
    param($serviceKey, $serviceConfig)
    
    Write-Host "[START] Iniciando $($serviceConfig.name)..." -ForegroundColor $serviceConfig.color
    
    # Crear script temporal para ejecutar el servicio
    $scriptContent = @"
Set-Location '$($serviceConfig.path)'
& '$($serviceConfig.env)'
$($serviceConfig.command) 2>&1 | Tee-Object -FilePath '$($serviceConfig.logfile)'
"@
    
    $tempScript = "$env:TEMP\sparrow_$serviceKey.ps1"
    $scriptContent | Out-File -FilePath $tempScript -Encoding UTF8
    
    # Iniciar proceso en segundo plano
    $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $tempScript -PassThru -WindowStyle Hidden
    
    # Guardar PID para control posterior
    $process.Id | Out-File -FilePath "$logDir\$serviceKey.pid"
    
    Write-Host "[OK] $($serviceConfig.name) iniciado en puerto $($serviceConfig.port) (PID: $($process.Id))" -ForegroundColor $serviceConfig.color
    
    return $process
}

function Stop-SparrowService {
    param($serviceKey, $serviceConfig)
    
    $pidFile = "$logDir\$serviceKey.pid"
    
    if (Test-Path $pidFile) {
        $processId = Get-Content $pidFile
        try {
            Get-Process -Id $processId -ErrorAction Stop | Out-Null
            Stop-Process -Id $processId -Force
            Remove-Item $pidFile
            Write-Host "[STOP] $($serviceConfig.name) detenido (PID: $processId)" -ForegroundColor Red
        }
        catch {
            Write-Host "[INFO] $($serviceConfig.name) ya no está ejecutándose" -ForegroundColor Gray
            Remove-Item $pidFile -ErrorAction SilentlyContinue
        }
    }
    else {
        Write-Host "[INFO] No se encontró PID para $($serviceConfig.name)" -ForegroundColor Gray
    }
}

function Get-ServiceStatus {
    param($serviceKey, $serviceConfig)
    
    $pidFile = "$logDir\$serviceKey.pid"
    $status = "STOPPED"
    $processId = $null
    
    if (Test-Path $pidFile) {
        $processId = Get-Content $pidFile
        try {
            Get-Process -Id $processId -ErrorAction Stop | Out-Null
            $status = "RUNNING"
        }
        catch {
            $status = "STOPPED"
            Remove-Item $pidFile -ErrorAction SilentlyContinue
        }
    }
    
    $color = if ($status -eq "RUNNING") { "Green" } else { "Red" }
    
    Write-Host "[$status]" -ForegroundColor $color -NoNewline
    Write-Host " $($serviceConfig.name) " -NoNewline
    if ($processId) { Write-Host "(PID: $processId, Puerto: $($serviceConfig.port))" -ForegroundColor Gray }
    else { Write-Host "(Puerto: $($serviceConfig.port))" -ForegroundColor Gray }
}

function Show-ServiceLogs {
    param($serviceKey, $serviceConfig)
    
    $logFile = $serviceConfig.logfile
    if (Test-Path $logFile) {
        Write-Host "`n=== LOGS: $($serviceConfig.name) ===" -ForegroundColor $serviceConfig.color
        Get-Content $logFile -Tail 10
        Write-Host "=== FIN LOGS ===" -ForegroundColor $serviceConfig.color
    }
    else {
        Write-Host "No hay logs disponibles para $($serviceConfig.name)" -ForegroundColor Gray
    }
}

# Procesar argumentos
if ($StartAll) {
    Write-Host "🚀 Iniciando todos los servicios de Sparrow..." -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($serviceKey in $serviceDefinitions.Keys) {
        Start-SparrowService $serviceKey $serviceDefinitions[$serviceKey]
    }
    
    Write-Host ""
    Write-Host "✅ Todos los servicios iniciados!" -ForegroundColor Green
    Write-Host "🌐 URLs de acceso:" -ForegroundColor Cyan
    Write-Host "   - API Principal: http://localhost:8002/api/v1/sparrow-llm/docs" -ForegroundColor White
    Write-Host "   - API Agents: http://localhost:8001/api/v1/sparrow-agents/docs" -ForegroundColor White
    Write-Host "   - API OCR: http://localhost:8003/docs" -ForegroundColor White
    Write-Host "   - Web UI: http://localhost:7860" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 Para ver estado: .\start-sparrow.ps1 -Status" -ForegroundColor Yellow
    Write-Host "🛑 Para detener todo: .\start-sparrow.ps1 -StopAll" -ForegroundColor Yellow
}
elseif ($StopAll) {
    Write-Host "🛑 Deteniendo todos los servicios de Sparrow..." -ForegroundColor Red
    
    foreach ($serviceKey in $serviceDefinitions.Keys) {
        Stop-SparrowService $serviceKey $serviceDefinitions[$serviceKey]
    }
    
    Write-Host "✅ Todos los servicios detenidos!" -ForegroundColor Green
}
elseif ($Status) {
    Write-Host "📊 Estado de los servicios de Sparrow:" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($serviceKey in $serviceDefinitions.Keys) {
        Get-ServiceStatus $serviceKey $serviceDefinitions[$serviceKey]
    }
    
    Write-Host ""
}
elseif ($ShowLogs) {
    foreach ($serviceKey in $serviceDefinitions.Keys) {
        Show-ServiceLogs $serviceKey $serviceDefinitions[$serviceKey]
    }
}
elseif ($Services.Count -gt 0) {
    Write-Host "🔧 Iniciando servicios específicos..." -ForegroundColor Cyan
    
    foreach ($service in $Services) {
        if ($serviceDefinitions.ContainsKey($service)) {
            Start-SparrowService $service $serviceDefinitions[$service]
        }
        else {
            Write-Host "❌ Servicio '$service' no encontrado" -ForegroundColor Red
            Write-Host "   Servicios disponibles: $($serviceDefinitions.Keys -join ', ')" -ForegroundColor Gray
        }
    }
}
else {
    Write-Host "🐦 Sparrow Multi-Service Manager" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso:" -ForegroundColor White
    Write-Host "  .\start-sparrow.ps1 -StartAll              # Iniciar todos los servicios" -ForegroundColor Gray
    Write-Host "  .\start-sparrow.ps1 -StopAll               # Detener todos los servicios" -ForegroundColor Gray
    Write-Host "  .\start-sparrow.ps1 -Status                # Ver estado de servicios" -ForegroundColor Gray
    Write-Host "  .\start-sparrow.ps1 -Services api-main,ui-web # Iniciar servicios específicos" -ForegroundColor Gray
    Write-Host "  .\start-sparrow.ps1 -ShowLogs              # Mostrar logs de servicios" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Servicios disponibles:" -ForegroundColor White
    foreach ($serviceKey in $serviceDefinitions.Keys) {
        $config = $serviceDefinitions[$serviceKey]
        Write-Host "  - $serviceKey : $($config.name) (Puerto $($config.port))" -ForegroundColor Gray
    }
}

# Ejemplos de uso:
# .\start-sparrow.ps1 -StartAll
# .\start-sparrow.ps1 -Services "api-main","ui-web"
# .\start-sparrow.ps1 -Status
# .\start-sparrow.ps1 -StopAll
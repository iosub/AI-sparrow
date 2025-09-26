# Administrador de Servicios Sparrow Multi-Entorno
# Permite iniciar, detener y monitorear múltiples componentes simultáneamente

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "start-all", "stop-all")]
    [string]$Action,
    
    [Parameter()]
    [ValidateSet("sparrow-parse", "instructor", "agents", "ocr", "ui")]
    [string]$Service = $null,
    
    [switch]$Background
)

# Configuración de servicios
$rootPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$logPath = "$PSScriptRoot\..\logs"

$services = @{
    "sparrow-parse" = @{
        Port = 8002
        EnvPath = "$rootPath\sparrow-ml\llm\.env_sparrow_parse\Scripts\Activate.ps1"
        WorkDir = "$rootPath\sparrow-ml\llm"
        ApiFile = "api.py"
        Color = "Green"
        Description = "Vision LLM Processing API"
    }
    "instructor" = @{
        Port = 8003
        EnvPath = "$rootPath\sparrow-ml\llm\.env_instructor\Scripts\Activate.ps1"
        WorkDir = "$rootPath\sparrow-ml\llm"
        ApiFile = "api.py"
        Color = "Blue"
        Description = "LLM Function Calling API"
    }
    "agents" = @{
        Port = 8001
        EnvPath = "$rootPath\sparrow-ml\agents\.env_agents\Scripts\Activate.ps1"
        WorkDir = "$rootPath\sparrow-ml\agents"
        ApiFile = "api.py"
        Color = "Magenta"
        Description = "Workflow Orchestration API"
    }
    "ocr" = @{
        Port = 8004
        EnvPath = "$rootPath\sparrow-data\ocr\.env_ocr\Scripts\Activate.ps1"
        WorkDir = "$rootPath\sparrow-data\ocr"
        ApiFile = "api.py"
        Color = "Yellow"
        Description = "OCR Processing API"
    }
    "ui" = @{
        Port = 8005
        EnvPath = "$rootPath\sparrow-ui\shell\.env_ui\Scripts\Activate.ps1"
        WorkDir = "$rootPath\sparrow-ui\shell"
        ApiFile = "app.py"
        Color = "Cyan"
        Description = "Web Interface"
    }
}

function Write-ColoredOutput {
    param($Service, $Message)
    $color = $services[$Service].Color
    $port = $services[$Service].Port
    Write-Host "[$($Service.ToUpper()) - $port]" -ForegroundColor $color -NoNewline
    Write-Host " $Message"
}

function Start-SparrowService {
    param($ServiceName)
    
    if (-not $services.ContainsKey($ServiceName)) {
        Write-Error "Servicio desconocido: $ServiceName"
        return
    }
    
    $config = $services[$ServiceName]
    
    # Verificar si ya está ejecutándose
    $existingProcess = Get-Process -Name "python*" -ErrorAction SilentlyContinue | 
        Where-Object { $_.MainWindowTitle -like "*$($config.Port)*" }
    
    if ($existingProcess) {
        Write-ColoredOutput $ServiceName "Ya está ejecutándose (PID: $($existingProcess.Id))"
        return
    }
    
    # Verificar entorno
    if (-not (Test-Path $config.EnvPath)) {
        Write-Error "Entorno no encontrado: $($config.EnvPath)"
        return
    }
    
    # Verificar archivo API
    if (-not (Test-Path "$($config.WorkDir)\$($config.ApiFile)")) {
        Write-Error "API no encontrada: $($config.WorkDir)\$($config.ApiFile)"
        return
    }
    
    Write-ColoredOutput $ServiceName "Iniciando $($config.Description)..."
    
    # Crear comando para ejecutar
    $logFile = "$logPath\$ServiceName-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
    
    $scriptBlock = {
        param($envPath, $workDir, $apiFile, $port, $logFile)
        
        # Configurar variables de entorno para evitar conflictos de numpy/torch
        $env:OMP_NUM_THREADS="1"
        $env:MKL_NUM_THREADS="1"
        $env:NUMEXPR_NUM_THREADS="1"
        $env:OPENBLAS_NUM_THREADS="1"
        
        Set-Location $workDir
        & $envPath
        python $apiFile --port $port 2>&1 | Tee-Object -FilePath $logFile
    }
    
    if ($Background) {
        # Iniciar en background
        $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $config.EnvPath, $config.WorkDir, $config.ApiFile, $config.Port, $logFile
        Write-ColoredOutput $ServiceName "Iniciado en background (Job ID: $($job.Id))"
        Write-ColoredOutput $ServiceName "Log: $logFile"
        Write-ColoredOutput $ServiceName "URL: http://localhost:$($config.Port)/docs"
    } else {
        # Iniciar en foreground
        Write-ColoredOutput $ServiceName "Iniciando en foreground..."
        Write-ColoredOutput $ServiceName "URL: http://localhost:$($config.Port)/docs"
        & $scriptBlock $config.EnvPath $config.WorkDir $config.ApiFile $config.Port $logFile
    }
}

function Stop-SparrowService {
    param($ServiceName)
    
    if (-not $services.ContainsKey($ServiceName)) {
        Write-Error "Servicio desconocido: $ServiceName"
        return
    }
    
    $config = $services[$ServiceName]
    
    # Detener por puerto
    $processes = Get-NetTCPConnection -LocalPort $config.Port -ErrorAction SilentlyContinue
    if ($processes) {
        foreach ($proc in $processes) {
            $processId = $proc.OwningProcess
            Write-ColoredOutput $ServiceName "Deteniendo proceso PID: $processId"
            Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        }
    }
    
    # Detener jobs en background
    $jobs = Get-Job | Where-Object { $_.Name -like "*$ServiceName*" }
    if ($jobs) {
        $jobs | Stop-Job
        $jobs | Remove-Job
        Write-ColoredOutput $ServiceName "Jobs en background detenidos"
    }
}

function Get-ServiceStatus {
    param($ServiceName = $null)
    
    $servicesToCheck = if ($ServiceName) { @($ServiceName) } else { $services.Keys }
    
    Write-Host "`n=== Estado de Servicios Sparrow ===" -ForegroundColor White
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
    
    foreach ($svc in $servicesToCheck) {
        $config = $services[$svc]
        
        # Verificar puerto
        $portOpen = Test-NetConnection -ComputerName localhost -Port $config.Port -InformationLevel Quiet -WarningAction SilentlyContinue
        
        # Verificar jobs
        $jobs = Get-Job | Where-Object { $_.Name -like "*$svc*" }
        $jobStatus = if ($jobs) { "$($jobs.Count) jobs activos" } else { "Sin jobs" }
        
        $status = if ($portOpen) { "ACTIVO" } else { "INACTIVO" }
        $statusColor = if ($portOpen) { "Green" } else { "Red" }
        
        Write-Host "[$($svc.ToUpper())] " -ForegroundColor $config.Color -NoNewline
        Write-Host "$status " -ForegroundColor $statusColor -NoNewline
        Write-Host "- Puerto $($config.Port) - $jobStatus - $($config.Description)"
    }
}

function Show-ServiceLogs {
    param($ServiceName)
    
    if (-not $services.ContainsKey($ServiceName)) {
        Write-Error "Servicio desconocido: $ServiceName"
        return
    }
    
    $logFiles = Get-ChildItem "$logPath\$ServiceName-*.log" | Sort-Object LastWriteTime -Descending
    
    if (-not $logFiles) {
        Write-Warning "No se encontraron logs para $ServiceName"
        return
    }
    
    $latestLog = $logFiles[0]
    Write-Host "=== Últimos logs de $ServiceName ===" -ForegroundColor White
    Write-Host "Archivo: $($latestLog.FullName)`n" -ForegroundColor Gray
    
    Get-Content $latestLog.FullName -Tail 20
}

# Función principal
switch ($Action) {
    "start" {
        if (-not $Service) {
            Write-Error "Especifica un servicio: -Service <nombre>"
            return
        }
        Start-SparrowService $Service
    }
    
    "stop" {
        if (-not $Service) {
            Write-Error "Especifica un servicio: -Service <nombre>"
            return
        }
        Stop-SparrowService $Service
    }
    
    "restart" {
        if (-not $Service) {
            Write-Error "Especifica un servicio: -Service <nombre>"
            return
        }
        Write-Host "Reiniciando $Service..." -ForegroundColor Yellow
        Stop-SparrowService $Service
        Start-Sleep -Seconds 3
        Start-SparrowService $Service
    }
    
    "status" {
        Get-ServiceStatus $Service
    }
    
    "logs" {
        if (-not $Service) {
            Write-Error "Especifica un servicio: -Service <nombre>"
            return
        }
        Show-ServiceLogs $Service
    }
    
    "start-all" {
        Write-Host "=== Iniciando todos los servicios Sparrow ===" -ForegroundColor White
        foreach ($svc in $services.Keys) {
            Start-SparrowService $svc
            Start-Sleep -Seconds 2
        }
        Start-Sleep -Seconds 5
        Get-ServiceStatus
    }
    
    "stop-all" {
        Write-Host "=== Deteniendo todos los servicios Sparrow ===" -ForegroundColor White
        foreach ($svc in $services.Keys) {
            Stop-SparrowService $svc
        }
    }
}

<#
EJEMPLOS DE USO:

# Iniciar servicio específico en background
.\sparrow-services.ps1 start -Service sparrow-parse -Background

# Iniciar todos los servicios
.\sparrow-services.ps1 start-all -Background

# Ver estado de todos los servicios
.\sparrow-services.ps1 status

# Ver logs de un servicio
.\sparrow-services.ps1 logs -Service sparrow-parse

# Detener un servicio
.\sparrow-services.ps1 stop -Service sparrow-parse

# Detener todos los servicios
.\sparrow-services.ps1 stop-all

# Reiniciar un servicio
.\sparrow-services.ps1 restart -Service sparrow-parse
#>
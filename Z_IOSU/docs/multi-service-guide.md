# Guía de Uso - Sparrow Multi-Service

## 🚀 Inicio Rápido

### Iniciar todos los servicios
```powershell
.\Z_IOSU\scripts\start-sparrow.ps1 -StartAll
```

### Ver estado de servicios
```powershell
.\Z_IOSU\scripts\start-sparrow.ps1 -Status
```

### Detener todos los servicios
```powershell
.\Z_IOSU\scripts\start-sparrow.ps1 -StopAll
```

## 🔧 Uso Avanzado

### Iniciar servicios específicos
```powershell
# Solo API principal
.\Z_IOSU\scripts\start-sparrow.ps1 -Services "api-main"

# API + UI Web
.\Z_IOSU\scripts\start-sparrow.ps1 -Services "api-main","ui-web"
```

### Ver logs de servicios
```powershell
.\Z_IOSU\scripts\start-sparrow.ps1 -ShowLogs
```

## 📋 Servicios Disponibles

| Servicio | Descripción | Puerto | URL |
|----------|-------------|---------|-----|
| `api-main` | API Principal Sparrow | 8002 | http://localhost:8002/api/v1/sparrow-llm/docs |
| `api-agents` | API de Agents (Prefect) | 8001 | http://localhost:8001/api/v1/sparrow-agents/docs |
| `api-ocr` | API de OCR | 8003 | http://localhost:8003/docs |
| `ui-web` | Interfaz Web (Gradio) | 7860 | http://localhost:7860 |

## 🔍 Monitoreo

### Archivos de log
Los logs se guardan en `Z_IOSU\logs\`:
- `api-main.log` - Logs de la API principal
- `api-agents.log` - Logs de agents
- `api-ocr.log` - Logs de OCR  
- `ui-web.log` - Logs de la UI web

### Archivos PID
Los PIDs de procesos se guardan en `Z_IOSU\logs\`:
- `api-main.pid`
- `api-agents.pid`
- `api-ocr.pid`
- `ui-web.pid`

## 🚨 Troubleshooting

### Si un servicio no inicia
1. Verificar que el entorno virtual existe
2. Revisar logs: `.\Z_IOSU\scripts\start-sparrow.ps1 -ShowLogs`
3. Verificar que el puerto no esté ocupado: `netstat -an | findstr :8002`

### Si hay procesos zombie
```powershell
# Detener todos los servicios forzadamente
.\Z_IOSU\scripts\start-sparrow.ps1 -StopAll

# Limpiar archivos PID manualmente si es necesario
Remove-Item Z_IOSU\logs\*.pid
```

### Verificar puertos ocupados
```powershell
netstat -an | findstr ":8001 :8002 :8003 :7860"
```

## 📝 Flujo de Trabajo Recomendado

1. **Desarrollo básico**: Solo `api-main`
   ```powershell
   .\Z_IOSU\scripts\start-sparrow.ps1 -Services "api-main"
   ```

2. **Desarrollo completo**: API + UI
   ```powershell
   .\Z_IOSU\scripts\start-sparrow.ps1 -Services "api-main","ui-web"
   ```

3. **Testing completo**: Todos los servicios
   ```powershell
   .\Z_IOSU\scripts\start-sparrow.ps1 -StartAll
   ```

4. **Al finalizar**: Detener todo
   ```powershell
   .\Z_IOSU\scripts\start-sparrow.ps1 -StopAll
   ```
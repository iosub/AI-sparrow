# Comandos Rápidos de Sparrow - Referencia

## 🚀 Inicio Rápido del Sistema

### 1. Verificar y Preparar Ollama
```powershell
# Verificar estado de Ollama
ollama ps

# Cargar modelo si no está activo
ollama run qwen2.5vl:7b "hello"
```

### 2. Iniciar Servicios
```powershell
# Navegar al directorio del proyecto
cd C:\IA\ejemplos\AI-sparrow

# Iniciar backend (Vision LLM)
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service sparrow-parse -Background

# Iniciar interfaz web
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service ui -Background

# Verificar estado
.\Z_IOSU\scripts\sparrow-services.ps1 status
```

### 3. Acceso a Interfaces
```powershell
# Abrir interfaz web
start http://localhost:7861

# Abrir documentación API
start http://localhost:8002/docs
```

## 🔧 Gestión de Servicios

### Comandos de Control
```powershell
# Ver estado de todos los servicios
.\Z_IOSU\scripts\sparrow-services.ps1 status

# Iniciar servicio específico
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service [sparrow-parse|ui|instructor|agents|ocr] -Background

# Detener servicio específico  
.\Z_IOSU\scripts\sparrow-services.ps1 stop -Service [sparrow-parse|ui|instructor|agents|ocr]

# Detener todos los procesos Python (reset completo)
Get-Process -Name "python*" -ErrorAction SilentlyContinue | Stop-Process -Force
```

### Verificación de Puertos
```powershell
# Verificar puertos principales
netstat -an | Select-String "7861|8002"

# Verificar puerto específico
netstat -ano | findstr ":7861"
netstat -ano | findstr ":8002"
```

## 📋 Troubleshooting Rápido

### Error 500: ModuleNotFoundError mlx_vlm
```powershell
# 1. Verificar que imports lazy estén aplicados
# 2. Reinstalar sparrow-parse en modo editable
. .\Z_IOSU\scripts\activate-env.ps1 sparrow-parse
uv pip install -e sparrow-data/parse/

# 3. Reiniciar servicios
.\Z_IOSU\scripts\sparrow-services.ps1 stop -Service sparrow-parse
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service sparrow-parse -Background
```

### Error 418: Unsupported type
```powershell
# Convertir JSON Schema completo a formato Sparrow simple
# Ver: Z_IOSU/docs/query.md
```

### Proceso Zombi en Puerto
```powershell
# Encontrar proceso usando puerto específico
netstat -ano | findstr ":8002"

# Terminar proceso por PID
taskkill /F /PID [PID_NUMBER]

# O terminar todos los Python
Get-Process -Name "python*" | Stop-Process -Force
```

## 🔍 Logs y Diagnóstico

### Ubicaciones de Logs
```powershell
# Logs de servicios
Get-ChildItem Z_IOSU\logs\ -Name "*.log"

# Log más reciente del backend
Get-Content (Get-ChildItem Z_IOSU\logs\sparrow-parse-*.log | Sort-Object LastWriteTime | Select-Object -Last 1).FullName -Tail 20

# Log más reciente de UI
Get-Content (Get-ChildItem Z_IOSU\logs\ui-*.log | Sort-Object LastWriteTime | Select-Object -Last 1).FullName -Tail 20
```

### Tests Rápidos
```powershell
# Test API backend
curl http://localhost:8002/api/v1/sparrow-llm/docs -UseBasicParsing

# Test conexión UI
curl http://localhost:7861 -UseBasicParsing

# Test modelo Ollama
ollama run qwen2.5vl:7b "test message"
```

## ⚙️ Configuración de Entorno

### Activar Entorno Específico
```powershell
# Activar entorno sparrow-parse
. .\Z_IOSU\scripts\activate-env.ps1 sparrow-parse

# Activar entorno UI
. .\Z_IOSU\scripts\activate-env.ps1 ui

# Verificar paquetes instalados
uv pip list
```

### Variables de Entorno Críticas
```powershell
# Variables para prevenir conflictos numpy/torch (ya incluidas en scripts)
$env:OMP_NUM_THREADS="1"
$env:MKL_NUM_THREADS="1" 
$env:NUMEXPR_NUM_THREADS="1"
$env:OPENBLAS_NUM_THREADS="1"
```

## 📁 Estructura de Archivos Clave

```
C:\IA\ejemplos\AI-sparrow\
├── sparrow-ml\llm\
│   ├── config.properties          # Configuración backend
│   └── api.py                     # API principal (reload=False)
├── sparrow-ui\shell\
│   ├── config.properties          # Configuración UI (Ollama)
│   └── app.py                     # Aplicación Gradio
├── sparrow-data\parse\
│   └── sparrow_parse\vllm\
│       └── inference_factory.py   # Imports lazy (CRÍTICO)
└── Z_IOSU\
    ├── scripts\
    │   └── sparrow-services.ps1   # Script de gestión
    ├── docs\
    │   ├── configuracion-completa-sparrow.md
    │   └── query.md
    └── logs\                      # Logs de servicios
```

## 🎯 Queries de Ejemplo para Testing

### Query Simple
```json
{"invoice_number": "str", "total": "str"}
```

### Query Complejo (Funcionando)
```json
{
  "InvoiceDetails": {"InvoiceNumber": "str", "InvoiceDate": "str"},
  "Items": [{"Description": "str", "Quantity": 0, "UnitPrice": "str"}],
  "InvoiceTotals": {"GrandTotal": "str"}
}
```

### Wildcard
```
*
```

---

**Comandos actualizados**: 2025-09-26  
**Sistema**: Completamente funcional con Ollama
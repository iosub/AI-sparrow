# Guía de Servicios Multi-Entorno Sparrow

## 🚀 Inicio Rápido

### Iniciar todos los servicios
```powershell
.\Z_IOSU\scripts\sparrow-services.ps1 start-all -Background
```

### Ver estado de servicios
```powershell
.\Z_IOSU\scripts\sparrow-services.ps1 status
```

## 📋 Servicios Disponibles

| Servicio | Puerto | Descripción | Entorno |
|----------|--------|-------------|---------|
| `sparrow-parse` | 8002 | Vision LLM Processing | `.env_sparrow_parse` |
| `instructor` | 8003 | LLM Function Calling | `.env_instructor` |
| `agents` | 8001 | Workflow Orchestration | `.env_agents` |
| `ocr` | 8004 | OCR Processing | `.env_ocr` |
| `ui` | 8005 | Web Interface | `.env_ui` |

## 🛠️ Comandos Principales

### Servicios Individuales
```powershell
# Iniciar un servicio específico
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service sparrow-parse -Background

# Detener un servicio
.\Z_IOSU\scripts\sparrow-services.ps1 stop -Service sparrow-parse

# Reiniciar un servicio
.\Z_IOSU\scripts\sparrow-services.ps1 restart -Service sparrow-parse

# Ver logs de un servicio
.\Z_IOSU\scripts\sparrow-services.ps1 logs -Service sparrow-parse
```

### Todos los Servicios
```powershell
# Iniciar todos los servicios
.\Z_IOSU\scripts\sparrow-services.ps1 start-all -Background

# Detener todos los servicios
.\Z_IOSU\scripts\sparrow-services.ps1 stop-all

# Ver estado general
.\Z_IOSU\scripts\sparrow-services.ps1 status
```

## 🌐 URLs de Acceso

Una vez iniciados los servicios, estarán disponibles en:

- **Sparrow Parse API**: http://localhost:8002/docs
- **Instructor API**: http://localhost:8003/docs  
- **Agents API**: http://localhost:8001/docs
- **OCR API**: http://localhost:8004/docs
- **UI Interface**: http://localhost:8005

## 📁 Estructura de Logs

Los logs se guardan automáticamente en:
```
Z_IOSU/logs/
├── sparrow-parse-20250926-143020.log
├── instructor-20250926-143025.log
├── agents-20250926-143030.log
└── ...
```

## ⚡ Workflow Típico

### Para Desarrollo
```powershell
# 1. Iniciar solo lo que necesites
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service sparrow-parse -Background

# 2. Probar API
# Navegar a http://localhost:8002/docs

# 3. Ver logs en tiempo real
.\Z_IOSU\scripts\sparrow-services.ps1 logs -Service sparrow-parse
```

### Para Producción/Pruebas Completas
```powershell
# 1. Iniciar todo el stack
.\Z_IOSU\scripts\sparrow-services.ps1 start-all -Background

# 2. Verificar que todo esté activo
.\Z_IOSU\scripts\sparrow-services.ps1 status

# 3. Probar cada componente
# sparrow-parse: http://localhost:8002/docs
# agents: http://localhost:8001/docs
# ui: http://localhost:8005
```

## 🔧 Troubleshooting

### Ver estado detallado
```powershell
.\Z_IOSU\scripts\sparrow-services.ps1 status
```

### Ver logs de errores
```powershell
.\Z_IOSU\scripts\sparrow-services.ps1 logs -Service <nombre-servicio>
```

### Reiniciar servicio problemático
```powershell
.\Z_IOSU\scripts\sparrow-services.ps1 restart -Service <nombre-servicio>
```

### Limpiar y reiniciar todo
```powershell
.\Z_IOSU\scripts\sparrow-services.ps1 stop-all
Start-Sleep -Seconds 5
.\Z_IOSU\scripts\sparrow-services.ps1 start-all -Background
```

## 📝 Notas Importantes

1. **Entornos Virtuales**: Cada servicio usa su propio entorno virtual automáticamente
2. **Puertos**: Los puertos están preconfigurados para evitar conflictos
3. **Logs**: Se generan automáticamente con timestamps
4. **Background**: Usar `-Background` para ejecutar servicios sin bloquear terminal
5. **Ollama**: Asegúrate que Ollama esté ejecutándose para servicios que usan modelos locales
# Recordatorios de Setup - Proyecto Sparrow

## 🔧 Configuración de Desarrollo

### Backend Preferido
- **Ollama** para modelos locales
- Configurar en archivos config.properties: `ollama_base_url = http://127.0.0.1:11434/v1`

### Herramientas de Desarrollo
- **uv** para gestión de entornos virtuales y dependencias
- **PowerShell** como shell principal (evitar comandos bash)
- **Python 3.12.10** requerido por Sparrow

### Estructura del Proyecto
- **Z_IOSU/**: Directorio para archivos locales del proyecto
  - `notes/`: Notas e instrucciones
  - `configs/`: Configuraciones personalizadas
  - `scripts/`: Scripts de utilidad
  - `docs/`: Documentación local

## 🐍 Entornos Virtuales Creados

### sparrow-ml/llm/
- `.env_sparrow_parse` - Pipeline principal Vision LLM
- `.env_instructor` - LLM function calling

### sparrow-data/ocr/
- `.env_ocr` - Servicios OCR

### sparrow-ml/agents/
- `.env_agents` - Workflows con Prefect

### sparrow-ui/shell/
- `.env_ui` - Interfaz web

## 📋 Estado Actual

### ✅ Completado
- [x] Branch `feature/copilot-instructions` creado
- [x] Archivo `.github/copilot-instructions.md` generado
- [x] Entornos virtuales creados con `uv`
- [x] Dependencias de `.env_sparrow_parse` instaladas
- [x] Dependencias de `.env_instructor` instaladas
- [x] Dependencias de `.env_agents` instaladas (Prefect)
- [x] Dependencias de `.env_ocr` instaladas (PaddleOCR)
- [x] Dependencias de `.env_ui` instaladas (Gradio)
- [x] Estructura de carpeta Z_IOSU organizada
- [x] Script `activate-env.ps1` creado y funcionando
- [x] Configuración Ollama preparada

### ✅ Completado Recientemente  
- [x] Ollama verificado y funcionando (v0.12.3)
- [x] Modelos vision disponibles: qwen2.5vl:7b, qwen3:4b-instruct, mistral-small
- [x] Configuración Ollama aplicada a config.properties
- [x] Entorno sparrow-parse activado correctamente
- [x] API de Sparrow iniciada y funcionando en puerto 8002
- [x] Script sparrow.ps1 creado para Windows (equivalente a sparrow.sh)
- [x] Script start-api.ps1 para iniciar APIs fácilmente
- [x] Documento de prueba creado en Z_IOSU/docs/

### 🔄 Próximos Pasos
- [ ] Instalar poppler para procesamiento PDF completo
- [ ] Probar API con documento real (imagen/PDF)
- [ ] Configurar modelos vision específicos para Sparrow
- [ ] Validar extracción de datos estructurados
- [ ] Probar diferentes pipelines (parse vs instructor)

### ✨ Scripts Disponibles
- `Z_IOSU/scripts/activate-env.ps1` - Activar entornos virtuales
- `Z_IOSU/scripts/start-api.ps1` - Iniciar APIs individuales
- `Z_IOSU/scripts/sparrow.ps1` - CLI de Sparrow para Windows
- `Z_IOSU/scripts/sparrow-services.ps1` - **Administrador completo multi-entorno** ⭐

### 🌐 APIs Multi-Entorno Configuradas
- **Sparrow Parse**: `http://localhost:8002/docs` (Vision LLM)
- **Instructor**: `http://localhost:8003/docs` (Text LLM)  
- **Agents**: `http://localhost:8001/docs` (Workflows)
- **OCR**: `http://localhost:8004/docs` (Text Recognition)
- **UI**: `http://localhost:8005` (Web Interface)

### 🎯 **SISTEMA MULTI-ENTORNO COMPLETO** ✅

**Iniciar todo el stack:**
```powershell
.\Z_IOSU\scripts\sparrow-services.ps1 start-all -Background
```

**Ver estado:**
```powershell
.\Z_IOSU\scripts\sparrow-services.ps1 status
```

**Ver guía completa:** `Z_IOSU/docs/servicios-multi-entorno.md`

## 🎯 Próximos Pasos

1. Completar instalación de dependencias en todos los entornos
2. Configurar Ollama con modelos para Vision LLM
3. Crear configuraciones personalizadas en Z_IOSU/configs/
4. Probar extracción básica de documentos
5. Documentar workflow de desarrollo local

---

**Fecha**: 2025-09-26
**Autor**: Setup inicial con Copilot
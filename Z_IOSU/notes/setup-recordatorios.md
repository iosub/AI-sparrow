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

### 🔄 Pendiente
- [ ] Configurar Ollama y descargar modelos locales
- [ ] Instalar poppler para procesamiento PDF
- [ ] Probar pipeline básico con documento de ejemplo
- [ ] Configurar archivos de configuración personalizados
- [ ] Probar cada entorno individualmente

## 🎯 Próximos Pasos

1. Completar instalación de dependencias en todos los entornos
2. Configurar Ollama con modelos para Vision LLM
3. Crear configuraciones personalizadas en Z_IOSU/configs/
4. Probar extracción básica de documentos
5. Documentar workflow de desarrollo local

---

**Fecha**: 2025-09-26
**Autor**: Setup inicial con Copilot
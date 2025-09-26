# Configuración Completa de Sparrow - Guía de Funcionamiento

## 📋 Resumen del Sistema

**Sparrow** es un sistema multi-componente para procesamiento de documentos usando Vision Language Models (VLMs). Incluye:
- **sparrow-parse**: Backend de procesamiento con modelos VLM
- **sparrow-ui**: Interfaz web Gradio
- **sparrow-instructor**: LLM para funciones de texto
- **sparrow-agents**: Orquestación de workflows
- **sparrow-ocr**: Reconocimiento óptico de caracteres

## 🛠️ Configuración del Entorno

### 1. Requisitos Previos
- **Python 3.12.10** (requerido por sparrow.sh)
- **uv** (package manager preferido)
- **Ollama** (backend LLM local)
- **PowerShell** (shell para Windows)

### 2. Estructura de Entornos Virtuales
```
.env_sparrow_parse/    # Vision LLM processing
.env_instructor/       # Text-only LLM function calling  
.env_agents/          # Prefect workflow orchestration
.env_ocr/             # OCR services (PaddleOCR)
.env_ui/              # Gradio web interface
```

### 3. Creación de Entornos
```powershell
# Crear todos los entornos virtuales
uv venv .env_sparrow_parse --python 3.12.10
uv venv .env_instructor --python 3.12.10
uv venv .env_agents --python 3.12.10
uv venv .env_ocr --python 3.12.10
uv venv .env_ui --python 3.12.10

# Instalar dependencias en cada entorno
.\.env_sparrow_parse\Scripts\Activate.ps1; uv pip install -r sparrow-ml\llm\requirements_sparrow_parse.txt
.\.env_instructor\Scripts\Activate.ps1; uv pip install -r sparrow-ml\llm\requirements_instructor.txt
.\.env_agents\Scripts\Activate.ps1; uv pip install -r sparrow-ml\agents\requirements_sparrow_agents.txt
.\.env_ocr\Scripts\Activate.ps1; uv pip install paddlepaddle paddleocr fastapi uvicorn
.\.env_ui\Scripts\Activate.ps1; uv pip install -r sparrow-ui\shell\requirements.txt

# Instalar sparrow-parse en modo editable (CRÍTICO)
.\.env_sparrow_parse\Scripts\Activate.ps1; uv pip install -e sparrow-data/parse/
```

## 🔧 Configuración de Ollama

### 1. Modelos Requeridos
```powershell
# Instalar modelos necesarios
ollama pull qwen2.5vl:7b      # Modelo principal para Vision LLM
ollama pull qwen3:4b-instruct  # Modelo para text-only tasks
```

### 2. Verificación de Modelos
```powershell
ollama list  # Verificar modelos instalados
ollama ps    # Verificar modelos cargados
```

## ⚙️ Configuraciones Críticas

### 1. Configuración del Backend (sparrow-ml/llm/config.properties)
```properties
[settings]
llm_function = qwen2.5vl:7b
ollama_base_url = http://127.0.0.1:11434/v1
protected_access = false
use_database = false

[keys]
key1_value = local-dev-key-001
key1_usage_count = 0
key1_usage_limit = 1000
```

### 2. Configuración de la UI (sparrow-ui/shell/config.properties)
```properties
[settings]
backend_url = http://localhost:8002/api/v1/sparrow-llm/inference
backend_options_1 = ollama,qwen2.5vl:7b,Standard model (reliable & versatile)
backend_options_2 = ollama,qwen3:4b-instruct,Text-only model (for summaries)
version = 0.4.4
use_database = false
protected_access = false
```

### 3. Modificación Crítica: Imports Lazy en InferenceFactory

**PROBLEMA RESUELTO**: El archivo `sparrow-data/parse/sparrow_parse/vllm/inference_factory.py` necesita imports lazy para evitar errores de `mlx_vlm`.

**Código corregido**:
```python
class InferenceFactory:
    def __init__(self, config):
        self.config = config

    def get_inference_instance(self):
        if self.config["method"] == "huggingface":
            from sparrow_parse.vllm.huggingface_inference import HuggingFaceInference
            return HuggingFaceInference(hf_space=self.config["hf_space"], hf_token=self.config["hf_token"])
        elif self.config["method"] == "local_gpu":
            from sparrow_parse.vllm.local_gpu_inference import LocalGPUInference
            model = self._load_local_model()
            return LocalGPUInference(model=model, device=self.config.get("device", "cuda"))
        elif self.config["method"] == "mlx":
            from sparrow_parse.vllm.mlx_inference import MLXInference  # Solo se importa si se necesita
            return MLXInference(model_name=self.config["model_name"])
        elif self.config["method"] == "ollama":
            from sparrow_parse.vllm.ollama_inference import OllamaInference
            return OllamaInference(model_name=self.config["model_name"])
        else:
            raise ValueError(f"Unknown method: {self.config['method']}")
```

### 4. Deshabilitación de Hot Reload

**Modificar** `sparrow-ml/llm/api.py` línea 341:
```python
# CAMBIAR DE:
uvicorn.run("api:app", host="0.0.0.0", port=args.port, reload=True)
# A:
uvicorn.run("api:app", host="0.0.0.0", port=args.port, reload=False)
```

### 5. Variables de Entorno para Estabilidad

**Agregado automáticamente** en `Z_IOSU/scripts/sparrow-services.ps1`:
```powershell
# Configurar variables de entorno para evitar conflictos numpy/torch
$env:OMP_NUM_THREADS="1"
$env:MKL_NUM_THREADS="1"
$env:NUMEXPR_NUM_THREADS="1"
$env:OPENBLAS_NUM_THREADS="1"
```

## 🚀 Scripts de Gestión de Servicios

### 1. Script Principal: Z_IOSU/scripts/sparrow-services.ps1

```powershell
# Iniciar servicio específico
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service sparrow-parse -Background
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service ui -Background

# Verificar estado
.\Z_IOSU\scripts\sparrow-services.ps1 status

# Detener servicio
.\Z_IOSU\scripts\sparrow-services.ps1 stop -Service sparrow-parse
```

### 2. Puertos de Servicios
- **sparrow-parse**: 8002 (Backend Vision LLM)
- **sparrow-ui**: 7861 (Interfaz web)
- **sparrow-instructor**: 8003 (Text LLM)
- **sparrow-agents**: 8001 (Workflows)
- **sparrow-ocr**: 8004 (OCR)

## 📝 Formato de Query para Sparrow

### ❌ NO usar JSON Schema completo:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": { ... }
}
```

### ✅ Usar formato Sparrow simplificado:
```json
{
  "invoice_number": "str",
  "invoice_date": "str",
  "supplier_name": "str", 
  "customer_name": "str",
  "total_amount": "str",
  "items": [
    {
      "description": "str",
      "quantity": 0,
      "unit_price": "str",
      "total": "str"
    }
  ]
}
```

### Tipos soportados:
- `"str"` - String
- `0` - Number
- `"str or null"` - String opcional
- `[{...}]` - Array de objetos
- `"*"` - Wildcard (extraer todo)

## 🔄 Proceso de Inicio Completo

### 1. Preparación
```powershell
# 1. Verificar Ollama
ollama ps

# 2. Cargar modelo si no está activo
ollama run qwen2.5vl:7b "hello"
```

### 2. Iniciar Servicios
```powershell
# 3. Iniciar backend
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service sparrow-parse -Background

# 4. Iniciar UI
.\Z_IOSU\scripts\sparrow-services.ps1 start -Service ui -Background

# 5. Verificar estado
.\Z_IOSU\scripts\sparrow-services.ps1 status
```

### 3. Verificación
```powershell
# 6. Verificar puertos
netstat -an | Select-String "7861|8002"

# 7. Probar API
curl http://localhost:8002/api/v1/sparrow-llm/docs -UseBasicParsing
```

### 4. Acceso
- **Interfaz Web**: http://localhost:7861
- **API Backend**: http://localhost:8002/docs

## 🐛 Solución de Problemas Comunes

### Error 500 "ModuleNotFoundError: No module named 'mlx_vlm'"
**Solución**: Verificar que los imports lazy estén aplicados en `inference_factory.py` y reinstalar sparrow-parse en modo editable.

### Error 418 "Unsupported type"
**Solución**: Usar formato Sparrow simplificado, no JSON Schema completo.

### Servicio no inicia
**Solución**: Verificar que Ollama esté ejecutándose y que los modelos estén disponibles.

### Hot reload constante
**Solución**: Verificar que `reload=False` esté configurado en `api.py`.

## 📚 Recursos

- **Logs**: `Z_IOSU/logs/`
- **Configuraciones**: `Z_IOSU/configs/`
- **Scripts**: `Z_IOSU/scripts/`
- **Documentación**: `Z_IOSU/docs/`

---

**Fecha de creación**: 2025-09-26  
**Estado**: Funcionando completamente con Ollama + qwen2.5vl:7b
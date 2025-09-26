# Sparrow AI Copilot Instructions

## Project Overview
Sparrow is a multi-component document processing system using Vision Language Models (VLMs) for structured data extraction from invoices, forms, tables, and complex documents. The system follows a modular architecture with three main components.

## Architecture Components

### Core Components Structure
- **`sparrow-ml/llm/`**: Main API engine with FastAPI server (`api.py`) and CLI interface (`sparrow.sh`)
- **`sparrow-data/parse/`**: Vision LLM library (`sparrow-parse` package) for document parsing
- **`sparrow-ml/agents/`**: Workflow orchestration using Prefect for multi-step processing
- **`sparrow-data/ocr/`**: Text recognition preprocessing service
- **`sparrow-ui/`**: Web interface for interactive document processing

### Pipeline Pattern
All processing uses the Pipeline pattern defined in `sparrow-ml/llm/pipelines/interface.py`:
```python
class Pipeline(ABC):
    def run_pipeline(self, pipeline: str, query: str, file_path: str, 
                    options: List[str] = None, crop_size: int = None, 
                    instruction: bool = False, validation: bool = False,
                    page_type: List[str] = None, debug_dir: str = None, 
                    debug: bool = False, local: bool = True) -> Any:
```

Available pipelines: `sparrow-parse`, `sparrow-instructor`, `stocks`

## Development Conventions

### Configuration Management
- Use `config.properties` files for service configuration
- Environment variables in `.env` files (never commit these)
- Database settings support Oracle DB 23ai Free for analytics
- Protected access via API keys with usage limits

### Backend Inference Pattern
All backends follow the factory pattern in `sparrow_parse/vllm/inference_factory.py`:
- **Ollama**: Local models (`ollama`) - **PREFERRED for this setup**
- **MLX**: Apple Silicon optimized (`mlx`, requires `sparrow-parse[mlx]`)
- **HuggingFace**: Cloud GPU (`huggingface`)
- **Local GPU**: CUDA/AMD (`local_gpu`)

### CLI Interface Pattern
Primary CLI is `sparrow.sh` script that:
1. Validates Python 3.12.10 requirement
2. Routes to `engine.py` or `assistant.py` based on first argument
3. Passes arguments to pipeline processor

Example usage:
```bash
./sparrow.sh '[{"field":"str", "amount":0}]' --pipeline sparrow-parse --options mlx,model-name --file-path document.pdf
```

### API Endpoint Patterns
FastAPI services follow consistent patterns:
- `/api/v1/{service-name}/inference` for document processing
- `/api/v1/{service-name}/instruction-inference` for text-only processing
- OpenAPI docs at `/api/v1/{service-name}/docs`
- File uploads via `multipart/form-data`

### Error Handling Convention
Consistent HTTP status codes:
- `403`: API key issues or protected access violations
- `418`: Processing errors (unusual but intentional choice)
- `422`: Validation errors for form data

## Virtual Environment Strategy

**Critical**: Each component requires separate virtual environments:
- `.env_sparrow_parse`: For vision LLM processing (main pipeline)
- `.env_instructor`: For text-only LLM function calling
- `.env_ocr`: For OCR services (optional)

Always activate correct environment before working on component.

## Dependencies and Installation

### Platform-Specific Setup
- **This Setup**: Use **Ollama backend** with `uv pip install sparrow-parse`
- **Development Tools**: Use `uv` for virtual environments and `PowerShell` for shell commands
- **Project Assets**: Use `Z_IOSU/` directory for project-specific files and configurations
- **All platforms**: Require `poppler` for PDF processing

### Version Requirements
- Python 3.12.10 (enforced by `sparrow.sh`)
- Specific versions in requirements files (don't upgrade without testing)

## Data Processing Patterns

### Schema-Based Extraction
Always use JSON schema for structured extraction:
```python
schema = '[{"field_name": "str", "amount": 0, "optional_field": "str or null"}]'
```

### Multi-page PDF Handling
PDFs are automatically split into pages, processed individually, and results aggregated with page numbers.

### Debug Mode
Enable debug output with `--debug` and `--debug-dir` for troubleshooting image processing and model inference.

## Testing and Validation

### Local Testing Pattern
1. Use CLI before API integration: `./sparrow.sh schema --pipeline sparrow-parse --file-path test.pdf`
2. Test with different backends and model sizes
3. Validate JSON schema compliance in responses

### Agent Workflow Testing
Agents use Prefect for visual workflow monitoring. Test complex workflows in `sparrow-ml/agents/` before production deployment.

## Common Integration Patterns

When adding new features:
1. Implement Pipeline interface for new processing types
2. Add factory method registration in `interface.py`
3. Follow existing API endpoint patterns in FastAPI services
4. Add proper virtual environment requirements
5. Update CLI argument handling in `engine.py`

Always check existing similar implementations in the same component before creating new patterns.

## Project-Specific Setup Notes

### Development Environment
- **Package Manager**: Use `uv` for all Python environment and dependency management
- **Shell**: Use PowerShell commands (avoid bash-style commands)
- **Local Models**: Configure Ollama as the primary backend for local inference

### Project Structure
- **Assets Directory**: Use `Z_IOSU/` in project root for custom configurations, models, and project-specific files
- **Virtual Environments**: Created with `uv venv` and dependencies installed with `uv pip install`
- **Backend Configuration**: Default to Ollama settings in config files
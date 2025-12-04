# Telemetry Data Collection

This document describes the telemetry data collected by the application, how to enable/disable it, and the main modules responsible for collection.

## Overview

The application uses **OpenTelemetry** for observability and **Grafana Beyla** for zero-code instrumentation via eBPF. Telemetry data is sent to **Grafana Cloud** for storage, visualization, and analysis.

## Architecture

```
Application (FastAPI)
    ↓
Grafana Beyla (eBPF instrumentation)
    ↓
OpenTelemetry Protocol (OTLP)
    ↓
Grafana Cloud
```

**Note:** The application also includes manual OpenTelemetry instrumentation code in `backend/app/core/telemetry.py`, but currently **Grafana Beyla** handles all instrumentation automatically via eBPF, requiring no code changes.

## Collected Data

### 1. Traces

**What is collected:**
- HTTP request/response traces for all API endpoints
- Request method (GET, POST, PUT, DELETE, etc.)
- Request path (e.g., `/api/v1/health`)
- HTTP status codes (200, 404, 500, etc.)
- Request duration/latency
- Trace context propagation (trace IDs, span IDs)

**Example trace attributes:**
- `http.method`: "GET"
- `http.status_code`: 200
- `http.route`: "/api/v1/health"
- `http.target`: "/api/v1/health"
- `service.name`: "open_telemetry"
- `deployment.environment`: "dev"

**Collection method:**
- **Grafana Beyla** automatically captures HTTP traffic via eBPF
- No code changes required
- Captures all HTTP requests to the application

### 2. Metrics

**What is collected:**
- HTTP request rate (requests per second)
- Request duration (p50, p95, p99 percentiles)
- Error rate (4xx, 5xx responses)
- Active connections
- Request size and response size

**Example metrics:**
- `http_server_request_duration` - Request duration histogram
- `http_server_request_size` - Request size histogram
- `http_server_response_size` - Response size histogram
- `http_server_active_requests` - Active request count

**Collection method:**
- **Grafana Beyla** automatically generates metrics from captured HTTP traffic
- Metrics are exported to Grafana Cloud via OTLP

### 3. Logs

**What is collected:**
- Application logs with structured format
- Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- Timestamp
- Service context (service.name, service.namespace, deployment.environment)
- Trace correlation (trace_id, span_id when available)

**Example log attributes:**
- `severity`: "INFO"
- `message`: "Application started"
- `service.name`: "open_telemetry"
- `service.namespace`: "add-evaluation-tool"
- `deployment.environment`: "dev"
- `trace_id`: "abc123..." (when in trace context)

**Collection method:**
- **OpenTelemetry LoggingHandler** bridges Python's logging to OpenTelemetry
- Configured in `backend/app/core/telemetry.py`
- All logs from Python's logging module are automatically captured
- Logs are exported to Grafana Cloud via OTLP

**Structured logging setup:**
```python
# In backend/app/core/telemetry.py
from opentelemetry.sdk._logs import LoggingHandler

handler = LoggingHandler(
    level=logging.NOTSET, logger_provider=logger_provider
)
logging.getLogger().addHandler(handler)
```

## Enabling/Disabling Telemetry

### Default State

**Telemetry is DISABLED by default** for security and privacy reasons.

### Enable Telemetry

1. **Copy environment file:**
   ```bash
   cp defaults.env .env
   ```

2. **Edit `.env` file:**
   ```bash
   # Enable telemetry
   TELEMETRY_ENABLED=true
   TELEMETRY_TRACES_ENABLED=true
   TELEMETRY_METRICS_ENABLED=true
   TELEMETRY_LOGS_ENABLED=true
   
   # Configure Grafana Cloud endpoint
   TELEMETRY_OTLP_ENDPOINT=https://otlp-gateway-prod-eu-north-0.grafana.net/otlp
   TELEMETRY_OTLP_HEADERS=Authorization=Basic%20<your-base64-encoded-api-key>
   ```

3. **Get Grafana Cloud credentials:**
   - Sign up at https://grafana.com/auth/sign-up/create-user
   - Go to **Connections** → **Add new connection** → **OpenTelemetry**
   - Copy the OTLP endpoint
   - Create API token: **Administration** → **API Keys** → **New API Key**
     - Role: `MetricsPublisher`, `TracesPublisher`, `LogsPublisher`
   - Base64 encode: `echo -n "INSTANCE_ID:API_TOKEN" | base64`
   - Use format: `Authorization=Basic%20<base64-encoded>` (URL-encoded)

4. **Restart the application:**
   ```bash
   docker-compose restart backend beyla
   ```

### Disable Telemetry

1. **Edit `.env` file:**
   ```bash
   TELEMETRY_ENABLED=false
   TELEMETRY_TRACES_ENABLED=false
   TELEMETRY_METRICS_ENABLED=false
   TELEMETRY_LOGS_ENABLED=false
   ```

2. **Restart the application:**
   ```bash
   docker-compose restart backend beyla
   ```

### Individual Components

You can enable/disable individual telemetry components:

```bash
# Enable only traces
TELEMETRY_ENABLED=true
TELEMETRY_TRACES_ENABLED=true
TELEMETRY_METRICS_ENABLED=false
TELEMETRY_LOGS_ENABLED=false

# Enable only metrics
TELEMETRY_ENABLED=true
TELEMETRY_TRACES_ENABLED=false
TELEMETRY_METRICS_ENABLED=true
TELEMETRY_LOGS_ENABLED=false

# Enable only logs
TELEMETRY_ENABLED=true
TELEMETRY_TRACES_ENABLED=false
TELEMETRY_METRICS_ENABLED=false
TELEMETRY_LOGS_ENABLED=true
```

## Main Modules for Telemetry Collection

### 1. Grafana Beyla (`docker-compose.yml`)

**Purpose:** Zero-code instrumentation via eBPF

**Location:** `docker-compose.yml` (beyla service)

**Responsibilities:**
- Automatically instruments Python application via eBPF
- Captures HTTP traffic without code changes
- Generates traces and metrics
- Exports data to Grafana Cloud via OTLP

**Configuration:**
```yaml
beyla:
  image: grafana/beyla:latest
  pid: "service:backend"
  privileged: true
  environment:
    - BEYLA_EXECUTABLE_NAME=python
    - BEYLA_OPEN_PORT=8000
    - OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp-gateway-prod-eu-north-0.grafana.net/otlp
    - OTEL_EXPORTER_OTLP_HEADERS=Authorization=Basic%20...
    - OTEL_SERVICE_NAME=open_telemetry
    - OTEL_RESOURCE_ATTRIBUTES=deployment.environment=dev,service.namespace=add-evaluation-tool
```

### 2. OpenTelemetry Setup (`backend/app/core/telemetry.py`)

**Purpose:** Manual OpenTelemetry instrumentation and structured logging

**Location:** `backend/app/core/telemetry.py`

**Responsibilities:**
- Configures OpenTelemetry SDK (TracerProvider, MeterProvider, LoggerProvider)
- Sets up structured logging via `LoggingHandler`
- Configures OTLP exporters (HTTP protocol)
- Auto-instruments FastAPI, Requests, SQLAlchemy (when enabled)
- Exports traces, metrics, and logs to Grafana Cloud

**Key Functions:**
- `setup_telemetry(app, settings)` - Main setup function
- `get_tracer(name)` - Get tracer for manual instrumentation

**Structured Logging:**
```python
# LoggingHandler bridges Python logging to OpenTelemetry
handler = LoggingHandler(
    level=logging.NOTSET, logger_provider=logger_provider
)
logging.getLogger().addHandler(handler)
```

**Note:** Currently, **Grafana Beyla** handles all instrumentation automatically. The manual instrumentation code in `telemetry.py` is available as a fallback or for additional custom instrumentation.

### 3. Configuration (`backend/app/core/config.py`)

**Purpose:** Telemetry settings management

**Location:** `backend/app/core/config.py`

**Responsibilities:**
- Loads telemetry settings from environment variables
- Parses OTLP headers (supports JSON and URL-encoded formats)
- Provides default values (telemetry disabled by default)
- Validates configuration

**Key Settings:**
- `telemetry_enabled` - Master switch (default: `False`)
- `telemetry_traces_enabled` - Enable/disable traces (default: `False`)
- `telemetry_metrics_enabled` - Enable/disable metrics (default: `False`)
- `telemetry_logs_enabled` - Enable/disable logs (default: `False`)
- `telemetry_otlp_endpoint` - Grafana Cloud OTLP endpoint
- `telemetry_otlp_headers` - Authentication headers

### 4. Application Initialization (`backend/app/__init__.py`)

**Purpose:** Initialize telemetry on application startup

**Location:** `backend/app/__init__.py`

**Responsibilities:**
- Calls `setup_telemetry()` during FastAPI app creation
- Ensures telemetry is initialized before handling requests

## Data Flow

```
┌─────────────────┐
│  FastAPI App    │
│  (Port 8000)    │
└────────┬────────┘
         │
         │ HTTP requests
         ↓
┌─────────────────┐
│ Grafana Beyla   │
│ (eBPF capture)  │
└────────┬────────┘
         │
         │ OTLP (HTTP/Protobuf)
         ↓
┌─────────────────┐
│  Grafana Cloud  │
│  (OTLP Gateway) │
└─────────────────┘
```

## Verification

### Check if telemetry is enabled:

```bash
# Check environment variables
docker-compose exec backend env | grep TELEMETRY

# Check Beyla logs
docker-compose logs beyla | grep "submitting traces"

# Check backend logs
docker-compose logs backend | grep "OpenTelemetry"
```

### Test data collection:

```bash
# Send test requests
for i in {1..10}; do
  curl http://localhost:8000/api/v1/health
  sleep 1
done

# Verify traces are being sent
docker-compose logs beyla --tail 20 | grep "submitting traces"
```

### View data in Grafana Cloud:

1. Go to **Explore** → **Tempo**
2. Query: `{service.name="open_telemetry"}`
3. Set time range: **Last 30 minutes**
4. View traces, metrics, and logs

## Security Considerations

1. **Telemetry disabled by default** - No data is collected unless explicitly enabled
2. **Authentication required** - OTLP endpoint requires valid API token
3. **HTTPS only** - All communication with Grafana Cloud uses TLS
4. **No sensitive data** - Only HTTP metadata is collected (no request/response bodies)
5. **Environment variables** - Credentials stored in `.env` (gitignored)

## Troubleshooting

### Data not appearing in Grafana Cloud

1. **Check telemetry is enabled:**
   ```bash
   docker-compose exec backend env | grep TELEMETRY_ENABLED
   ```

2. **Check Beyla is running:**
   ```bash
   docker-compose ps beyla
   ```

3. **Check for errors:**
   ```bash
   docker-compose logs beyla | grep -i error
   ```

4. **Verify endpoint and token:**
   ```bash
   docker-compose exec beyla env | grep OTEL_EXPORTER_OTLP
   ```

5. **Wait for indexing** - First-time data indexing can take 5-10 minutes

### Structured logging not working

1. **Check LoggingHandler is added:**
   ```bash
   docker-compose logs backend | grep "OpenTelemetry structured logging enabled"
   ```

2. **Verify logs are being exported:**
   ```bash
   docker-compose logs backend | grep -i "log"
   ```

3. **Check OTLP endpoint for logs:**
   - Logs use the same endpoint as traces: `/otlp/v1/logs`

## References

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Grafana Beyla Documentation](https://github.com/grafana/beyla)
- [Grafana Cloud OpenTelemetry Setup](https://grafana.com/docs/grafana-cloud/connect-externally-hosted/send-data/otlp/send-data-otlp/)
- [OpenTelemetry Python SDK](https://opentelemetry.io/docs/instrumentation/python/)

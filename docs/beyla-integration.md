# Grafana Beyla Integration

This document describes the Grafana Beyla integration for automatic telemetry
collection.

## What is Beyla?

Beyla is an eBPF-based application auto-instrumentation tool that provides
automatic observability for your applications without requiring code changes. It
automatically captures:

- HTTP/HTTPS requests and responses
- gRPC calls
- Request latency and timing
- Error rates
- Distributed traces

## Configuration

Beyla is configured in `docker-compose.yml` with the following settings:

### Service Configuration

```yaml
beyla:
  image: grafana/beyla:latest
  pid: "service:backend"  # Attach to backend process
  privileged: true         # Required for eBPF
  environment:
    - BEYLA_EXECUTABLE_NAME=python
    - BEYLA_OPEN_PORT=8000
    - BEYLA_PRINT_TRACES=true
    - OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp-gateway-prod-eu-north-0.grafana.net/otlp
    - OTEL_EXPORTER_OTLP_HEADERS=Authorization=Basic <token>
    - OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
    - OTEL_SERVICE_NAME=architecture-evaluation-tool
```

### Environment Variables

- `BEYLA_EXECUTABLE_NAME`: Name of the process to instrument (python for FastAPI)
- `BEYLA_OPEN_PORT`: Port to monitor (8000 for our backend)
- `BEYLA_PRINT_TRACES`: Print traces to stdout for debugging
- `OTEL_EXPORTER_OTLP_ENDPOINT`: Grafana Cloud OTLP endpoint
- `OTEL_EXPORTER_OTLP_HEADERS`: Authentication header with base64-encoded token
- `OTEL_EXPORTER_OTLP_PROTOCOL`: Protocol to use (http/protobuf for Grafana Cloud)
- `OTEL_SERVICE_NAME`: Name of the service in traces

## What Data is Collected

Beyla automatically collects:

1. **HTTP Metrics**:

   - Request count
   - Response time (latency)
   - Status codes (2xx, 4xx, 5xx)
   - Request/response sizes

2. **Distributed Traces**:

   - Span for each HTTP request
   - Timing information
   - HTTP method, path, status code
   - Request and response headers (configurable)

3. **Resource Attributes**:

   - Service name
   - Service version
   - Deployment environment
   - Service namespace

## Advantages of Beyla

1. **Zero Code Changes**: No need to modify application code
2. **Language Agnostic**: Works with any language (Python, Go, Java, etc.)
3. **Low Overhead**: eBPF-based instrumentation is very efficient
4. **Automatic**: No manual instrumentation needed
5. **Complete Coverage**: Captures all HTTP traffic automatically

## Viewing Data in Grafana Cloud

### Traces (Tempo)

1. Open Grafana Cloud
2. Navigate to **Explore**
3. Select **Tempo** data source
4. Query: `{service.name="architecture-evaluation-tool"}`
5. You'll see all HTTP requests as traces

### Metrics (Prometheus)

1. Open Grafana Cloud
2. Navigate to **Explore**
3. Select **Prometheus** data source
4. Query examples:
   - `http_server_request_duration_seconds_bucket`
   - `http_server_request_count`
   - `rate(http_server_request_count[5m])`

## Troubleshooting

### Beyla not capturing traffic

1. Check Beyla logs: `docker-compose logs beyla`
2. Verify `BEYLA_OPEN_PORT` matches backend port
3. Ensure Beyla container has `privileged: true`
4. Verify `pid: "service:backend"` is correct

### No data in Grafana Cloud

1. Check OTLP endpoint is correct
2. Verify authentication token is valid
3. Check Beyla logs for export errors
4. Wait 1-2 minutes for data to appear

### Debugging

Enable debug logging by adding to Beyla environment:

```yaml
- BEYLA_LOG_LEVEL=DEBUG
```

View traces in console:

```bash
docker-compose logs beyla | grep "trace"
```

## Disabling Beyla

To disable Beyla:

1. Stop Beyla container:

   ```bash
   docker-compose stop beyla
   ```

2. Or remove from docker-compose.yml and restart:

   ```bash
   docker-compose down
   docker-compose up -d
   ```

## Performance Impact

Beyla uses eBPF which has minimal performance impact:

- CPU overhead: < 1%
- Memory overhead: ~50-100 MB
- No application code changes needed
- No additional libraries in application

## Further Reading

- [Beyla Documentation](https://grafana.com/docs/beyla/)
- [Beyla GitHub](https://github.com/grafana/beyla)
- [eBPF Introduction](https://ebpf.io/)

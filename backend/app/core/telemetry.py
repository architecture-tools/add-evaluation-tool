"""OpenTelemetry instrumentation and structured logging setup."""

import logging
from typing import Optional

from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry._logs import set_logger_provider
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import (
    OTLPMetricExporter,
)
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
    OTLPSpanExporter,
)
from opentelemetry.exporter.otlp.proto.http.trace_exporter import (
    OTLPSpanExporter as OTLPSpanExporterHTTP,
)
from opentelemetry.exporter.otlp.proto.http.metric_exporter import (
    OTLPMetricExporter as OTLPMetricExporterHTTP,
)
from opentelemetry.exporter.otlp.proto.http._log_exporter import (
    OTLPLogExporter as OTLPLogExporterHTTP,
)
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

from .config import Settings


def setup_telemetry(app: FastAPI, settings: Settings) -> None:
    """
    Setup OpenTelemetry instrumentation for the application.

    Configures tracing, metrics, and structured logging.
    Telemetry is disabled by default and can be enabled via environment variables.
    """
    if not settings.telemetry_enabled:
        logging.info("Telemetry is disabled")
        return

    # Create resource with service information
    resource = Resource.create(
        {
            "service.name": settings.telemetry_service_name,
            "service.version": settings.app_version,
            "service.namespace": settings.telemetry_service_namespace,
        }
    )

    # Setup tracing
    if settings.telemetry_traces_enabled:
        trace_provider = TracerProvider(resource=resource)
        trace.set_tracer_provider(trace_provider)

        if settings.telemetry_otlp_endpoint:
            headers = settings.telemetry_otlp_headers or {}
            # Use HTTP exporter for Grafana Cloud
            # Grafana Cloud endpoint format: https://otlp-gateway-prod-<region>.grafana.net/otlp
            # HTTP exporter automatically appends /v1/traces to the base endpoint
            # If endpoint contains /otlp, we need to use it as base (exporter adds /v1/traces -> /otlp/v1/traces)
            # But Grafana Cloud might expect just /otlp, so we use the endpoint as-is
            from urllib.parse import urlparse, urlunparse
            parsed = urlparse(settings.telemetry_otlp_endpoint)
            # Remove :443 port if present (default HTTPS port)
            if ":443" in parsed.netloc:
                netloc = parsed.netloc.replace(":443", "")
            else:
                netloc = parsed.netloc
            # Use the path as-is from the endpoint (should be /otlp for Grafana Cloud)
            # HTTP exporter will append /v1/traces -> /otlp/v1/traces
            path = parsed.path if parsed.path else "/otlp"
            http_endpoint = urlunparse((parsed.scheme, netloc, path, "", "", ""))
            
            logging.info(
                f"Setting up OTLP exporter: endpoint={settings.telemetry_otlp_endpoint}, "
                f"headers_keys={list(headers.keys()) if headers else 'none'}"
            )
            logging.info(f"HTTP endpoint will be: {http_endpoint} (exporter adds /v1/traces)")
            
            otlp_exporter = OTLPSpanExporterHTTP(
                endpoint=http_endpoint,
                headers=headers,
            )
            span_processor = BatchSpanProcessor(otlp_exporter)
            trace_provider.add_span_processor(span_processor)

        # Auto-instrument FastAPI
        FastAPIInstrumentor.instrument_app(app)

        # Auto-instrument HTTP requests
        RequestsInstrumentor().instrument()

        # Auto-instrument SQLAlchemy
        SQLAlchemyInstrumentor().instrument()

        logging.info("OpenTelemetry tracing enabled")

    # Setup metrics
    if settings.telemetry_metrics_enabled:
        if settings.telemetry_otlp_endpoint:
            from urllib.parse import urlparse, urlunparse
            parsed = urlparse(settings.telemetry_otlp_endpoint)
            if ":443" in parsed.netloc:
                netloc = parsed.netloc.replace(":443", "")
            else:
                netloc = parsed.netloc
            # HTTP exporter will append /v1/metrics automatically -> /otlp/v1/metrics
            path = parsed.path if parsed.path else "/otlp"
            http_endpoint = urlunparse((parsed.scheme, netloc, path, "", "", ""))
            
            metric_exporter = OTLPMetricExporterHTTP(
                endpoint=http_endpoint,
                headers=settings.telemetry_otlp_headers or {},
            )
            metric_reader = PeriodicExportingMetricReader(
                exporter=metric_exporter, export_interval_millis=60000
            )
            metrics_provider = MeterProvider(
                resource=resource, metric_readers=[metric_reader]
            )
            metrics.set_meter_provider(metrics_provider)
            logging.info("OpenTelemetry metrics enabled")

    # Setup structured logging
    if settings.telemetry_logs_enabled:
        logger_provider = LoggerProvider(resource=resource)
        set_logger_provider(logger_provider)

        if settings.telemetry_otlp_endpoint:
            from urllib.parse import urlparse, urlunparse
            parsed = urlparse(settings.telemetry_otlp_endpoint)
            if ":443" in parsed.netloc:
                netloc = parsed.netloc.replace(":443", "")
            else:
                netloc = parsed.netloc
            # HTTP exporter will append /v1/logs automatically -> /otlp/v1/logs
            path = parsed.path if parsed.path else "/otlp"
            http_endpoint = urlunparse((parsed.scheme, netloc, path, "", "", ""))
            
            log_exporter = OTLPLogExporterHTTP(
                endpoint=http_endpoint,
                headers=settings.telemetry_otlp_headers or {},
            )
            logger_provider.add_log_record_processor(
                BatchLogRecordProcessor(log_exporter)
            )

        # Configure root logger to use OpenTelemetry handler
        handler = LoggingHandler(
            level=logging.NOTSET, logger_provider=logger_provider
        )
        logging.getLogger().addHandler(handler)
        logging.getLogger().setLevel(logging.INFO)

        logging.info("OpenTelemetry structured logging enabled")


def get_tracer(name: Optional[str] = None):
    """Get a tracer instance for manual instrumentation."""
    if not trace.get_tracer_provider():
        return trace.NoOpTracer()
    return trace.get_tracer(name or __name__)


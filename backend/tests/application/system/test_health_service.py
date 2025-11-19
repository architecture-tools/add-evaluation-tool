from __future__ import annotations

from dataclasses import dataclass

from app.application.system.services import HealthService


@dataclass
class _FakeSettings:
    app_name: str = "Arch Eval"
    app_version: str = "0.9.0"


def test_health_service_uses_configuration(monkeypatch) -> None:
    # Arrange
    monkeypatch.setattr(
        "app.application.system.services.get_settings",
        lambda: _FakeSettings(),
    )

    # Act
    status = HealthService.get_health_status()

    # Assert
    assert status["status"] == "healthy"
    assert status["app"] == _FakeSettings.app_name
    assert status["version"] == _FakeSettings.app_version
    assert status["timestamp"].endswith("Z")


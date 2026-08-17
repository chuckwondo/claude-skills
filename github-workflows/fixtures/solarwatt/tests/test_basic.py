import pytest

from solarwatt import panel_output_watts


def test_panel_output() -> None:
    assert panel_output_watts(1000.0, 2.0, 0.2) == 400.0


def test_bad_efficiency() -> None:
    with pytest.raises(ValueError):
        panel_output_watts(1000.0, 2.0, 1.5)

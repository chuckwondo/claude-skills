"""Estimate rooftop solar panel output from irradiance data."""


def panel_output_watts(irradiance_w_m2: float, area_m2: float, efficiency: float) -> float:
    """Return instantaneous panel output in watts."""
    if not 0 < efficiency <= 1:
        raise ValueError("efficiency must be in (0, 1]")
    return irradiance_w_m2 * area_m2 * efficiency

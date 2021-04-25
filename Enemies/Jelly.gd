extends "res://Enemies/DrifterBase.gd"

func _ready() -> void:
    spin_rate = 0
    drift_rate_x = 50.0
    drift_rate_y = 50.0
    ._ready()

func dps() -> float:
    return 5.0

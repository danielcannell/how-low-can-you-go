extends "res://Enemies/DrifterBase.gd"

func _ready() -> void:
    spin_rate = 1
    drift_rate_x = 50.0
    drift_rate_y = 30.0
    mass = 5
    ._ready()

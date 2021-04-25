extends "res://Enemies/DrifterBase.gd"

onready var light = $Light2D

func _ready() -> void:
    spin_rate = 0
    drift_rate_x = 50.0
    drift_rate_y = 50.0
    ._ready()

func dps() -> float:
    return 5.0


func update_light() -> void:
    light.energy = (1 - Globals.color_scale) * 0.35


func _process(delta):
    if alive:
        update_light()

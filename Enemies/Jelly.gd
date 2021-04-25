extends "res://Enemies/DrifterBase.gd"

onready var light = $Light2D

var obj_scale: float = 1.0

func _ready() -> void:
    spin_rate = 0
    drift_rate_x = 50.0
    drift_rate_y = 50.0
    obj_scale = rand_range(0.9, 1.0)
    ._ready()

    # Pass in per instance state through the modulate uniform
    var phase := rand_range(0.0, 1.0)
    modulate = Color(phase, 0.0, 0.0, 1.0)

func dps() -> float:
    return 5.0


func update_light() -> void:
    light.energy = (1 - Globals.color_scale) * 0.83


func _process(delta):
    if alive:
        update_light()


func _integrate_forces(state):
    set_scale(Vector2(obj_scale, obj_scale))

extends "res://Enemies/Fish.gd"


onready var glow = $Glow

func _ready():
    ._ready()
    # Pass in per instance state through the modulate uniform
    var phase := rand_range(0.0, 1.0)
    glow.modulate = Color(phase, 0.0, 0.0, 1.0)


# Separate from on_dead to allow that to be overriden
func out_of_bounds() -> void:
    glow.visible = false
    .out_of_bounds()

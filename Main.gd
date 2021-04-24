extends Node2D


const Player = preload("res://Player/Player.tscn")


onready var camera := $Camera2D
onready var background := $Camera2D/Background

var fall_rate := 100.0


func _ready() -> void:
    var vp := camera.get_viewport()
    Globals.screen_height = vp.size.y
    spawn_player()


func spawn_player() -> void:
    var player := Player.instance()
    add_child(player)


func _process(delta: float) -> void:
    Globals.depth += delta * fall_rate
    camera.position.y = Globals.depth

    var color_scale := exp(-Globals.depth * 1e-4)
    background.color = color_from_hsl(0.64, 1.0 * color_scale, 0.85 * color_scale)


func color_from_hsl(hue: float, sat: float, light: float) -> Color:
    sat *= light if light < 0.5 else 1.0 - light
    return Color.from_hsv(hue, 2 * sat / (light + sat), light + sat)

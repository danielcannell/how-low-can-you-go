extends Node2D


const Player = preload("res://Player/Player.tscn")
const Harpoon = preload("res://Harpoon/Harpoon.tscn")


onready var camera := $Camera2D
onready var background := $Camera2D/Background
onready var depth_label := $GUI/DepthLabel

var fall_rate := 50.0
var prev_rounded_depth := 0.0


func _ready() -> void:
    var vp := camera.get_viewport()
    Globals.screen_height = vp.size.y
    Globals.screen_width = vp.size.x
    spawn_player()


func spawn_player() -> void:
    var player := Player.instance()
    var harpoon := Harpoon.instance()
    add_child(player)
    add_child(harpoon)
    player.set_harpoon(harpoon)
    harpoon.set_player(player)


func _process(delta: float) -> void:
    Globals.depth += delta * fall_rate
    camera.position.y = Globals.depth

    var color_scale := exp(-Globals.depth * 1e-4)
    background.color = color_from_hsl(0.64, 1.0 * color_scale, 0.85 * color_scale)

    var rounded_depth := 10 * round(Globals.depth / 320)
    if prev_rounded_depth != rounded_depth:
        depth_label.text = "Depth: " + str(rounded_depth) + " m"
        prev_rounded_depth = rounded_depth


func color_from_hsl(hue: float, sat: float, light: float) -> Color:
    sat *= light if light < 0.5 else 1.0 - light
    return Color.from_hsv(hue, 2 * sat / (light + sat), light + sat)

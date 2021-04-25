extends Node


const Player = preload("res://Player/Player.tscn")
const Harpoon = preload("res://Harpoon/Harpoon.tscn")


onready var camera := $Camera2D
onready var background := $Camera2D/Background
onready var depth_label := $UICanvas/DepthLabel
onready var canvas_modulate := $Camera2D/CanvasModulate
onready var game_over_ui := $UICanvas/GameOverUI
onready var restart_button := $UICanvas/GameOverUI/VBoxContainer/RestartButton

var fall_rate := 50.0
var prev_rounded_depth := 0.0


func _ready() -> void:
    Globals.depth = 0.0

    spawn_player()

    restart_button.connect("button_up", self, "restart_game")


func restart_game() -> void:
    get_tree().reload_current_scene()


func spawn_player() -> void:
    var player := Player.instance()
    var harpoon := Harpoon.instance()
    add_child(player)
    add_child(harpoon)
    player.set_harpoon(harpoon)
    harpoon.set_player(player)
    harpoon.connect("bool_splatter", self, "_on_blood_splatter")

    player.connect("died", self, "on_player_died")


func on_player_died():
    game_over_ui.visible = true


func depth_scale(depth: float) -> float:
    # Depth at which we reach 50% brightness
    var mid_point := 40.0 * fall_rate

    # Time scale for the change from light to dark
    var scale := 40.0 * fall_rate

    # Logistic function
    return 1.0 - 1.0 / (1.0 + exp(-(depth - mid_point) / scale))


func _process(delta: float) -> void:
    var vp := camera.get_viewport()
    Globals.screen_height = vp.size.y
    Globals.screen_width = vp.size.x

    # Bubbles at the bottom
    var bubbles: Particles2D = $Camera2D/Particles2D
    var shader: ParticlesMaterial = bubbles.process_material
    shader.emission_box_extents.x = vp.size.x
    bubbles.position = Vector2(0, vp.size.y / 2.0)

    Globals.depth += delta * fall_rate
    camera.position.y = Globals.depth

    Globals.color_scale = depth_scale(Globals.depth) / depth_scale(0.0)
    background.color = color_from_hsl(0.64, 0.4 + 0.6 * Globals.color_scale, 0.25 + (0.6 * Globals.color_scale))
    canvas_modulate.color = Color.from_hsv(0, 0, min(0.8, Globals.color_scale))

    var rounded_depth := 10 * round(Globals.depth / 320)
    if prev_rounded_depth != rounded_depth:
        depth_label.text = "Depth: " + str(rounded_depth) + " m"
        prev_rounded_depth = rounded_depth


func color_from_hsl(hue: float, sat: float, light: float) -> Color:
    sat *= light if light < 0.5 else 1.0 - light
    return Color.from_hsv(hue, 2 * sat / (light + sat), light + sat)


func _on_blood_splatter(cls, location, direction, params):
    var b = cls.instance()
    add_child(b)
    b.rotation = direction
    b.position = location
    b.set_params(params)
    b.run()

extends Node2D


const Player = preload("res://Player/Player.tscn")


onready var camera := $Camera2D

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

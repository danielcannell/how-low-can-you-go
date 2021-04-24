extends Node2D


const Player = preload("res://Player/Player.tscn")


onready var camera := $Camera2D


var depth := 0.0
var fall_rate := 100.0


func _ready() -> void:
    spawn_player()


func spawn_player() -> void:
    var player := Player.instance()
    add_child(player)


func _process(delta: float) -> void:
    depth += delta * fall_rate
    camera.position.y = depth

extends Node

var depth := 0.0
var screen_width := 0.0
var screen_height := 0.0
var player_position := Vector2.ZERO

func get_spawn_y() -> float:
    # Spawn new enemies 64 below base of screen
    return depth + (screen_height / 2) + 64

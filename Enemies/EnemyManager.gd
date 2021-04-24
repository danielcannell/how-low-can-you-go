extends Node


export (PackedScene) var Floater


var next_spawn_time := 0.0
const SPAWN_RATE := 0.5


func _ready() -> void:
    pass


func _process(delta: float) -> void:
    next_spawn_time -= delta

    if next_spawn_time < 0:
        next_spawn_time = SPAWN_RATE

        var enemy: Node2D = Floater.instance()
        enemy.position = Vector2(rand_range(50, 450), Globals.depth + 50)
        add_child(enemy)

extends Node


export (PackedScene) var Floater
export (PackedScene) var Fish
export (PackedScene) var Shark


var next_spawn_time := 0.0
const SPAWN_RATE := 0.5


onready var enemy_types = [
    [20, null],
    [100, Floater],
    [50, Fish],
    [2, Shark],
]
var _total_enemy_type_weight := 0  # cache


func _ready() -> void:
    for typ in enemy_types:
        _total_enemy_type_weight += typ[0]


func enemy_type_to_spawn() -> PackedScene:
    var which := randi() % _total_enemy_type_weight
    for typ in enemy_types:
        which -= typ[0]
        if which < 0:
            return typ[1]
    return null


func _process(delta: float) -> void:
    next_spawn_time -= delta

    if next_spawn_time < 0:
        next_spawn_time = SPAWN_RATE

        var to_spawn := enemy_type_to_spawn()
        if to_spawn != null:
            var enemy: Node2D = to_spawn.instance()
            enemy.position = Vector2(rand_range(-Globals.screen_width/2, Globals.screen_width/2), Globals.get_spawn_y())
            add_child(enemy)

extends Node


export (PackedScene) var Floater
export (PackedScene) var Fish


var next_spawn_time := 0.0
const SPAWN_RATE := 0.5


onready var enemy_types = [
    [100, Floater],
    [50, Fish],
]
var _total_enemy_type_weight := 0  # cache


func _ready() -> void:
    for typ in enemy_types:
        _total_enemy_type_weight += typ[0]


func enemy_type_to_spawn() -> PackedScene:
    var which := randi() % _total_enemy_type_weight
    print(which)
    for typ in enemy_types:
        which -= typ[0]
        if which < 0:
            print("choosing", typ[1])
            return typ[1]

    print("math whoops")
    return enemy_types[-1][1]


func _process(delta: float) -> void:
    next_spawn_time -= delta

    if next_spawn_time < 0:
        next_spawn_time = SPAWN_RATE

        var enemy: Node2D = enemy_type_to_spawn().instance()
        enemy.position = Vector2(rand_range(-Globals.screen_width/2, Globals.screen_width/2), Globals.get_spawn_y())
        add_child(enemy)

extends Node


export (PackedScene) var Floater
export (PackedScene) var Fish
export (PackedScene) var Shark
export (PackedScene) var Jelly
export (PackedScene) var Angler


var next_spawn_time := 0.0
const SPAWN_RATE := 0.5


onready var enemy_types = [
    [0.2, [
        [100, null],
        [20, Fish],
    ]],
    [0.1, [
        [100, null],
        [100, Jelly],
        [50, Fish],
    ]],
    [0.2, [
        [20, null],
        [100, Floater],
        [100, Jelly],
        [50, Fish],
        [2, Shark],
    ]],
    [0.2, [
        [20, null],
        [100, Floater],
        [100, Jelly],
        [50, Fish],
        [5, Shark],
    ]],
    [0.3, [
        [20, null],
        [100, Floater],
        [100, Jelly],
        [50, Fish],
        [10, Angler],
        [2, Shark],
    ]]
]


func _ready():
    var total_weight := 0.0
    for t in enemy_types:
        total_weight += t[0]
    for t in enemy_types:
        t[0] = t[0] / total_weight

    for t in enemy_types:
        var table = t[1]

        total_weight = 0.0
        for typ in table:
            total_weight += typ[0]

        for typ in table:
            typ[0] = typ[0] / total_weight


func enemy_type_to_spawn() -> PackedScene:
    var table_choice := 0.2 * randf() + 0.8 * (1.0 - Globals.color_scale)
    var enemy_choice := randf()

    for t in enemy_types:
        table_choice -= t[0]
        if table_choice < 0:
            var table = t[1]
            for typ in table:
                enemy_choice -= typ[0]
                if enemy_choice < 0.0:
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

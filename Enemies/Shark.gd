extends "res://Enemies/EnemyBase.gd"

const RETHINK_TIME := 1.0

onready var sprite = $Sprite

var rethink_time := 0.0
var move_to := Vector2.ZERO
const speed_y_up := 120.0
const speed_y_down := 20.0
const speed_x := 100.0


func _ready() -> void:
    set_max_hp(100.0)


func _physics_process(delta: float) -> void:
    rethink_time -= delta
    if rethink_time < 0:
        rethink_time = RETHINK_TIME
        move_to = Globals.player_position - self.position

    var move_vec := Vector2.ZERO
    var dpos := Globals.player_position - self.position
    sprite.flip_h = dpos.x > 0
    var speed_y = speed_y_down if dpos.y < 0 else speed_y_up
    if abs(dpos.y) < speed_y * delta:
        move_vec.y = dpos.y
    else:
        move_vec.y = speed_y * sign(dpos.y)

    if abs(dpos.x) < speed_x * delta:
        move_vec.x = dpos.x
    else:
        move_vec.x = speed_x * sign(dpos.x)

    move_and_collide(move_vec * delta)

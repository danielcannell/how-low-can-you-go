extends StaticBody2D


enum State { IDLE, FIRING, STUCK, RETREIVING }


onready var rope := $Rope


const MAX_RANGE := 500
const MIN_RANGE := 100
const SPEED := 1000
var velocity := Vector2()
var state: int = State.IDLE
var player = null


func set_player(p) -> void:
    player = p


func fire(pos: Vector2, vel: Vector2, angle: float) -> void:
    if state == State.IDLE:
        state = State.FIRING

        var dir := Vector2(1, 0).rotated(angle)
        velocity = vel + SPEED * dir
        position = pos + MIN_RANGE * dir
        rotation = angle
        visible = true


func rope_len() -> float:
    return (rope.points[0] - rope.points[1]).length()


func _ready() -> void:
    pass


func _physics_process(delta: float) -> void:
    match state:
        State.FIRING:
            if rope_len() >= MAX_RANGE:
                state = State.RETREIVING

        State.RETREIVING:
            velocity = 500 * (player.position - position).normalized()

            if rope_len() < MIN_RANGE:
                visible = false
                state = State.IDLE
                player.harpoon_retreived()

    if visible:
        rope.points[1] = get_global_transform().xform_inv(player.position)
        position += delta * velocity

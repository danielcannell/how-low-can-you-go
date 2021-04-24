extends "res://Enemies/EnemyBase.gd"

enum State {
    TURN,
    FORWARD,
    ZOMBIE,
}

onready var sprite = $Sprite

const TURN_SPEED := 20.0
const INITIAL_SPEED := 300.0
const MIN_SPEED := 150.0
const DRAG := 20.0

var current_state := -1

# TURN state
var turn_speed := 0.0

# FORWARD state
var forward_move := Vector2.ZERO
var speed := 0.0


# Override on_dead so that we don't get cleaned up automatically
func on_dead() -> void:
    alive = false


func get_splatter_params() -> Dictionary:
    return {"amount": 15}


func zombify() -> void:
    current_state = State.ZOMBIE


func _ready() -> void:
    set_max_hp(10.0)
    set_state(State.TURN)


func _physics_process(delta: float) -> void:
    sprite.flip_v = self.rotation_degrees < -90 or self.rotation_degrees > 90
    match current_state:
        State.TURN:
            var desired_angle: float = (self.position - Globals.player_position).angle()
            var angle := self.rotation

            var diff: float = Globals.normalise_angle(desired_angle - angle)
            if abs(diff) < turn_speed * delta:
                self.rotation = desired_angle
                set_state(State.FORWARD)
            else:
                rotate(sign(diff) * turn_speed * delta)

        State.FORWARD:
            var dist_to_target := forward_move.length()
            var move_vec := Vector2.ZERO
            if dist_to_target < speed * delta:
                move_vec = forward_move
                set_state(State.TURN)
            else:
                move_vec = forward_move.normalized() * speed * delta
            forward_move -= move_vec
            speed = max(MIN_SPEED, speed - (DRAG * delta))
            move_and_collide(move_vec)

        State.ZOMBIE:
            # Position controlled externally
            pass


func set_state(new_state: int) -> void:
    if new_state == current_state:
        return

    if new_state == State.FORWARD:
        forward_move = Globals.player_position - self.position
        speed = INITIAL_SPEED

    elif new_state == State.TURN:
        turn_speed = TURN_SPEED

    current_state = new_state

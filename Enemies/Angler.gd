extends "res://Enemies/EnemyBase.gd"



enum State {
    DRIFTING,
    ATTACK,
    ENDLESS_ATTACK,
    DEAD
}

const TURN_SPEED := 5.0
const INITIAL_SPEED := 50.0
const MIN_SPEED := 15.0
const DRAG := 30.0
const attack_dist: float = 150.0;
const attack_speed: float = 330.0;
const drift_speed: float = 25.0;
const attack_end_dist: float = 310.0;


var current_state := -1
# TURN state
var turn_speed := 0.0
# FORWARD state
var forward_move := Vector2.ZERO
var speed := 0.0

onready var sprite: Sprite = $Sprite
onready var lure := $Light2D
onready var leak := $BloodLeak

const speed_y_up := 120.0
const speed_y_down := 20.0
const speed_x := 100.0
const dead_frame = 2;

var lure_offset_from_sprite := Vector2.ZERO

func _ready() -> void:
    leak.emitting = false
    set_max_hp(19.0)
    lure_offset_from_sprite = lure.position - sprite.position

    _look_at(Globals.player_position)
    set_state(State.DRIFTING)

# between 0 and 1, with 0 being undamanged and 1 being dead
func set_damage_state(state: float) -> void:
    state = clamp(state, 0, 1)
    var frame = floor((1-state) * dead_frame)
    sprite.frame = frame
    if state > 0:
        leak.emitting = true


func on_dead() -> void:
    alive = false
    set_damage_state(1)
    sprite.flip_v = true
    lure.energy = 0
    rotation = 0
    set_state(State.DEAD)


func dps() -> float:
    return 10.0


func get_splatter_params() -> Dictionary:
    return {"amount": 70}


func damage(amount: float) -> void:
    .damage(amount)
    set_damage_state(hp / max_hp)
    if alive:
        set_state(State.ENDLESS_ATTACK)


func _look_at(point: Vector2) -> void:
    look_at(point)
    var flip := self.rotation_degrees < -90 or self.rotation_degrees > 90
    var flipint := -1 if flip else 1
    sprite.flip_v = flip
    lure.position = sprite.position + Vector2(lure_offset_from_sprite.x, lure_offset_from_sprite.y * flipint)


func _look_vec() -> Vector2:
    return Vector2(cos(rotation), sin(rotation))


func _look_angle(a: Vector2, b: Vector2) -> float:
    return acos(a.dot(b))


func _physics_process(delta: float) -> void:
    var player_vec: Vector2 = Globals.player_position - self.position;

    speed = max(MIN_SPEED, speed - (DRAG * delta))

    match current_state:
        State.DRIFTING:
            var move_vec = _look_vec() * speed * delta
            move_and_collide(move_vec)

            if player_vec.length() < attack_dist && _look_angle(player_vec.normalized(), _look_vec()) < deg2rad(60):
                set_state(State.ATTACK)

        State.ATTACK, State.ENDLESS_ATTACK:
            _look_at(Globals.player_position)
            var move_vec = _look_vec() * speed * delta
            move_and_collide(move_vec)

            if current_state == State.ATTACK:
                if player_vec.length() > attack_end_dist:
                    set_state(State.DRIFTING)

        State.DEAD:
            var move_vec = Vector2.UP * delta * speed
            move_and_collide(move_vec)



func set_state(new_state: int) -> void:
    if new_state == current_state:
        return

    match new_state:
        State.DRIFTING:
            lure.energy = 1;
            lure.range_height = 10;
            speed = drift_speed * 2

        State.ATTACK, State.ENDLESS_ATTACK:
            lure.energy = 2.5;
            lure.range_height = 30;
            speed = attack_speed

        State.DEAD:
            lure.energy = 1;
            lure.range_height = 10;
            speed = drift_speed

    current_state = new_state

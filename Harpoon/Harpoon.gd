extends Area2D

signal bool_splatter(cls, location, angle)


enum State { IDLE, FIRING, STUCK, RETREIVING }


onready var rope := $Rope

var BloodSplatter = preload("res://Effects/BloodSpatter.tscn")


const MAX_RANGE := 500
const MIN_RANGE := 50
const INITIAL_SPEED := 5000
const FIRING_DURATION := 0.5
const STUCK_DURATION := 0.5

var velocity := Vector2()
var state: int = State.IDLE
var player = null
var enemy = null
var duration := 0.0


func set_player(p) -> void:
    player = p


func fire(pos: Vector2, vel: Vector2, angle: float) -> void:
    if state == State.IDLE:
        state = State.FIRING
        duration = FIRING_DURATION

        var dir := Vector2(1, 0).rotated(angle)
        velocity = vel + INITIAL_SPEED * dir
        position = pos + MIN_RANGE * dir
        rotation = angle
        visible = true


func rope_len() -> float:
    return (rope.points[0] - rope.points[1]).length()


func _ready() -> void:
    pass


func _spawn_blood() -> void:
    emit_signal("bool_splatter", BloodSplatter, position, rotation)


func _physics_process(delta: float) -> void:
    duration -= delta

    # Our enemy could have died
    if enemy != null && !is_instance_valid(enemy):
        enemy = null

    match state:
        State.FIRING:
            velocity -= 8 * delta * (velocity - Vector2(0, 200))

            if duration < 0.0:
                state = State.RETREIVING

            var bodies := get_overlapping_bodies()

            for b in bodies:
                b.damage(10)
                _spawn_blood()
                if b.alive:
                    enemy = b
                    state = State.STUCK
                    duration = STUCK_DURATION

        State.STUCK:
            if enemy == null || duration < 0.0:
                enemy = null
                state = State.RETREIVING
            else:
                position = enemy.position

        State.RETREIVING:
            velocity = 500 * (player.position - position).normalized()

            var rotation_error = (position - player.position).angle() - rotation
            while rotation_error < -PI:
                rotation_error += 2 * PI
            while rotation_error > PI:
                rotation_error -= 2 * PI

            rotation += 5 * delta * rotation_error

            if rope_len() < MIN_RANGE:
                visible = false
                state = State.IDLE
                player.harpoon_retreived()

    if visible:
        rope.points[1] = get_global_transform().xform_inv(player.position)
        position += delta * velocity

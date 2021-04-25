extends RigidBody2D

var alive := true

# Separate from on_dead to allow that to be overriden
func out_of_bounds() -> void:
    queue_free()


var spin := 0.0
var drift := Vector2.ZERO
var spin_rate := 1.0
var drift_rate_x := 50.0
var drift_rate_y := 30.0
var kick_time_countdown := 0.3
var first_physics := true

func _ready() -> void:
    spin = (randf() - 0.5) * spin_rate
    drift = Vector2((randf() - 0.5) * drift_rate_x, (-randf()) * drift_rate_y)

func _physics_process(delta: float) -> void:
    if first_physics:
        kick_time_countdown -= delta
        if kick_time_countdown <= 0:
            first_physics = false
            apply_torque_impulse(spin * 1000 * mass)
            apply_central_impulse(drift)

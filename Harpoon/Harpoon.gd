extends StaticBody2D


enum State { IDLE, FIRING, STUCK, RETREIVING }


var velocity := Vector2()
var state: int = State.IDLE
var player = null


func set_player(p) -> void:
    player = p


func fire(pos: Vector2, vel: Vector2, angle: float) -> void:
    if state == State.IDLE:
        state = State.FIRING
        velocity = vel + Vector2(600, 0).rotated(angle)
        position = pos + velocity * 0.1
        rotation = angle
        visible = true


func _ready() -> void:
    pass


func _physics_process(delta: float) -> void:
    match state:
        State.FIRING:
            self.position += delta * velocity

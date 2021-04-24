extends KinematicBody2D


enum SwimState { SWIM_STATE_IDLE, SWIM_STATE_LEFT, SWIM_STATE_RIGHT };


onready var sprite := $Sprite


var velocity := Vector2(0, 100)
var swim_state: int = SwimState.SWIM_STATE_IDLE


func _ready() -> void:
    pass


func set_animation(a: Vector2) -> void:
    var new_swim_state = SwimState.SWIM_STATE_IDLE
    if a.x > 100:
        new_swim_state = SwimState.SWIM_STATE_RIGHT
    elif a.x < -100:
        new_swim_state = SwimState.SWIM_STATE_LEFT

    if new_swim_state != swim_state:
        swim_state = new_swim_state

        match swim_state:
            SwimState.SWIM_STATE_IDLE:
                sprite.set_animation("idle")
            SwimState.SWIM_STATE_LEFT:
                sprite.set_animation("swim")
                sprite.set_flip_h(false)
            SwimState.SWIM_STATE_RIGHT:
                sprite.set_animation("swim")
                sprite.set_flip_h(true)


func _physics_process(delta: float) -> void:

    var a := Vector2.ZERO

    if Input.is_action_pressed("up"):
        a.y -= 1000
    if Input.is_action_pressed("down"):
        a.y += 1000
    if Input.is_action_pressed("left"):
        a.x -= 1000
    if Input.is_action_pressed("right"):
        a.x += 1000

    # Get viewport rect in canvas coordinates
    var visible = get_viewport_transform().xform_inv(get_viewport_rect())
    var allowed = visible.grow(-100)

    if !allowed.has_point(position):
        var left_dist = position.x - allowed.position.x
        var right_dist = allowed.end.x - position.x
        var top_dist = position.y - allowed.position.y
        var bottom_dist = allowed.end.y - position.y

        if left_dist < 0:
            a.x += 10 * -left_dist
            if velocity.x < 0:
                a.x -= 5 * velocity.x

        if right_dist < 0:
            a.x -= 10 * -right_dist
            if velocity.x > 0:
                a.x -= 5 * velocity.x

        if top_dist < 0:
            a.y += 10 * -top_dist
            if velocity.y < 100:
                a.y -= 5 * (velocity.y - 100)

        if bottom_dist < 0:
            a.y -= 10 * -bottom_dist
            if velocity.y > 100:
                a.y -= 5 * (velocity.y - 100)

    set_animation(a)

    # Damping
    a -= velocity - Vector2(0, 200)

    velocity += delta * a
    move_and_slide(velocity)

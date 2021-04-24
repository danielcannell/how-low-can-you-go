extends KinematicBody2D


var speed := 100


func _ready() -> void:
    pass


func _physics_process(_delta: float) -> void:
    var dir := Vector2.ZERO

    if Input.is_action_pressed("up"):
        dir.y -= 1
    if Input.is_action_pressed("down"):
        dir.y += 1
    if Input.is_action_pressed("left"):
        dir.x -= 1
    if Input.is_action_pressed("right"):
        dir.x += 1

    move_and_slide(dir.normalized() * speed)

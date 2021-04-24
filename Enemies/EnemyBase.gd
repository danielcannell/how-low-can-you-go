extends KinematicBody2D


var hp := 100.0
var alive := true


func damage(amount: float) -> void:
    hp -= amount
    if hp <= 0:
        alive = false
        queue_free()


func _ready():
    pass

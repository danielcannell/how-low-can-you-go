extends KinematicBody2D


var hp: float = 100.0


func damage(amount: float) -> void:
    hp -= amount
    if hp < 0:
        queue_free()


func _ready():
    pass

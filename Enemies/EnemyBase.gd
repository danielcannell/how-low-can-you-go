extends KinematicBody2D


onready var healthbar_template := preload("res://Enemies/HealthBar.tscn")


var hp := 100.0
var max_hp := 100.0
var alive := true
var healthbar = null


func set_max_hp(max_: float) -> void:
    hp = max_
    max_hp = max_


func on_dead() -> void:
    alive = false
    queue_free()


# Separate from on_dead to allow that to be overriden
func out_of_bounds() -> void:
    alive = false
    queue_free()


func damage(amount: float) -> void:
    hp -= amount
    healthbar.set_percent(max(hp, 0) / max_hp)
    if hp <= 0:
        on_dead()

    # Show the health bar once we've been damaged, if we're still alive
    healthbar.visible = alive


func get_splatter_params() -> Dictionary:
    return {"amount": 30}


func _ready():
    healthbar = healthbar_template.instance()
    healthbar.position = Vector2(0, -10)
    healthbar.visible = false
    add_child(healthbar)


func _process(_delta: float) -> void:
    healthbar.rotation = -self.rotation

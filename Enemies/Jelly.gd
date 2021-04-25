extends "res://Enemies/EnemyBase.gd"

var spin := 0.0
var drift := Vector2.ZERO
const DRIFT_RATE_X := 50.0
const DRIFT_RATE_Y := 30.0

func _ready() -> void:
    drift = Vector2((randf() - 0.5) * DRIFT_RATE_X, (-randf()) * DRIFT_RATE_Y)


func _process(delta: float) -> void:
    drift = move_and_slide(drift)

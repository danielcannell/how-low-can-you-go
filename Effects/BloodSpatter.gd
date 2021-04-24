extends Particles2D


func run():
    emitting = true
    yield(get_tree().create_timer(2.0), "timeout")
    queue_free()


func set_params(params):
    amount = params['amount']

func _ready():
    pass

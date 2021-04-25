extends Particles2D

var running = false;

func run():
    emitting = true
    running = true

func set_params(params):
    amount = params['amount']


func _process(delta):
    if running and not emitting:
        queue_free()

extends Particles2D

var running = false;

func run():
    emitting = true
    running = true
    yield(get_tree().create_timer(4), "timeout")
    queue_free()

func set_params(params):
    amount = params['amount']

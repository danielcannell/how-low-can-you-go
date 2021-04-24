extends Area2D


func _ready():
    pass


func body_entered(body: Node):
    if body.has_method("out_of_bounds"):
        body.out_of_bounds()

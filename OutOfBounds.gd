extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func area_entered(area: Area2D):
    print("out of founds", area)
    if area.has_method("out_of_bounds_entered"):
        area.out_of_bounds_entered()

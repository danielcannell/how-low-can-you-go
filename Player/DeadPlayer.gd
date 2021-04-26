extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var namelbl: Label = $Label
var player_name = "Bob"

# Called when the node enters the scene tree for the first time.
func _ready():
    namelbl.text = player_name

func set_name(name):
    self.player_name = name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var dist = (position - Globals.player_position).length();
    var x = 600.0;
    if dist < x:
        namelbl.modulate.a = smoothstep(0, 1, 1 - (dist / x));
        namelbl.visible = true
    else:
        namelbl.visible = false
        
    if position.y < Globals.depth - 100 * 32:
        queue_free()


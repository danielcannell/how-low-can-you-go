extends Node2D

onready var red_bar := $RedBar
onready var green_bar := $GreenBar


func set_percent(percent: float) -> void:
    green_bar.rect_size.x = percent * red_bar.rect_size.x


func _ready() -> void:
    green_bar.rect_size = red_bar.rect_size

extends KinematicBody2D


onready var sprite = $Sprite

func _ready():
	pass
	
func MovePlayer(new_position):
	set_position(new_position)

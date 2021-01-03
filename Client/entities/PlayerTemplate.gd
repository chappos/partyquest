extends KinematicBody2D


onready var sprite = $Sprite
onready var ground_check = $GroundCheckCast

func _ready():
	sprite.play()
	
func MovePlayer(new_position, flip):
	if new_position == position:
		sprite.animation = "Idle"
	else:
		set_position(new_position)
		if ground_check.is_grounded():
			sprite.animation = "Move"
		else:
			sprite.animation = "Airborne"
	sprite.flip_h = flip

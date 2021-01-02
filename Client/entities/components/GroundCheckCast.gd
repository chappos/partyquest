extends Node2D

onready var timer = $Timer

var raycasts = []

func _ready():
	for child in get_children():
		if child is RayCast2D:
			raycasts.append(child)

func is_grounded() -> bool:
	var grounded = false
	for ray in raycasts:
		if ray.is_colliding():
			grounded = true
			break
	return grounded

func on_parent_jumped():
	for ray in raycasts:
		ray.enabled = false
	timer.start(0.1)

func _on_Timer_timeout():
	for ray in raycasts:
		ray.enabled = true

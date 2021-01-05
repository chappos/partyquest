extends KinematicBody2D
class_name Entity

export(float) var max_health = 50
export(float) var gravity = 2800.0
export(float) var terminal_velocity = 800
export(float) var knockback_drag = 10.0

onready var ground_check = $GroundCheck

signal dead
signal health_changed(new_health)

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var is_dead = false

var current_health = 1 setget _on_health_changed

func _ready():
	current_health = max_health

func _physics_process(delta):
	apply_knockback(delta)
	apply_gravity(delta)

func apply_knockback(delta):
	if knockback.length() <= 0:
		return
	# warning-ignore:return_value_discarded
	move_and_slide(knockback, Vector2.UP)
	knockback = knockback.move_toward(Vector2.ZERO, delta * knockback_drag)
	
func apply_gravity(delta):
	if is_on_floor() and ground_check.is_grounded():
		return
	var actual_grav = gravity
	if velocity.y < -100:
		actual_grav = gravity / 2
	velocity.y = min(velocity.y + (actual_grav * delta), terminal_velocity)
	
func _on_health_changed(new_health: float):
	if is_dead:
		return
	current_health = clamp(new_health, 0, max_health)
	if current_health > 0:
		emit_signal("health_changed", current_health)
	else:
		emit_signal("dead")

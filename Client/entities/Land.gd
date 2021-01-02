extends Node

var fsm: StateMachine


func enter(e):
	if not e.is_on_floor() and not e.ground_check.is_grounded():
		exit(e, "Airborne")

func exit(_e, next_state):
	fsm._change_to(next_state)

# Optional handler functions for game loop events
func process(_e, delta):
	# Add handler code here
	return delta

func physics_process(e, delta):
	e.apply_gravity(delta)
	e.apply_movement(true)
	if Input.is_action_pressed("jump"):
		e.handle_jump()
	else:
		exit(e, "Move")

func input(_e, event):
	return event

func unhandled_input(_e, event):
	return event

func unhandled_key_input(_e, event):
	return event

func notification(what, flag = false):
	return [what, flag]


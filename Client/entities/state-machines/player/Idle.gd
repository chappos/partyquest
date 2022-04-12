extends Node

var fsm: StateMachine

func enter(_e):
	pass
	
func exit(_e, next_state):
	fsm._change_to(next_state)
	
# Optional handler functions for game loop events
func process(_e, delta):
	# Add handler code here
	return delta
	
func physics_process(e, delta):
	if not e.is_on_floor() and not e.ground_check.is_grounded():
		exit(e, "Airborne")
		return
	if e.direction != 0:
		exit(e, "Move")
		return
	e.handle_jump()
	e.handle_sit()
	e.grounded_movement(delta)
	e.apply_gravity(delta)
	e.apply_movement(true)
	
func input(_e, event):
	return event

func unhandled_input(_e, event):
	return event

func unhandled_key_input(_e, event):
	return event

func notification(what, flag = false):
	return [what, flag]
	

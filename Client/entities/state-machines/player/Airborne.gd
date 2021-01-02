extends Node

var fsm: StateMachine

func enter(_e):
	pass

func exit(_e, next_state):
	fsm._change_to(next_state)
	
func process(_e, delta):
	return delta
	
func physics_process(e, delta):
	e.aerial_movement(delta)
	e.apply_movement(false)
	if e.is_on_floor() or e.ground_check.is_grounded():
		exit(e, "Land")
		return

func input(_e, event):
	return event

func unhandled_input(_e, event):
	return event

func unhandled_key_input(_e, event):
	return event

func notification(what, flag = false):
	return [what, flag]

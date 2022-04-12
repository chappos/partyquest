extends Node

var fsm: StateMachine

var chair: Chair

func enter(_e):
	render_chair(_e)

func render_chair(e):
	chair = Chair.new(e.position, e.sprite.flip_h)
	add_child(chair)
	
	if(e.sprite.flip_h):
		e.position = Vector2(e.position.x - chair.PlayerSitOffsetX, e.position.y + chair.PlayerSitOffsetY)
	else:
		e.position = Vector2(e.position.x + chair.PlayerSitOffsetX, e.position.y + chair.PlayerSitOffsetY)

func exit(_e, next_state):
	chair.queue_free()
	fsm._change_to(next_state)
	
# Optional handler functions for game loop events
func process(_e, delta):
	# Add handler code here
	return delta
	
func physics_process(e, delta):
	if e.direction != 0:
		exit(e, "Idle")
		return
		
	e.grounded_movement(delta)
	
func input(_e, event):
	return event

func unhandled_input(_e, event):
	return event

func unhandled_key_input(_e, event):
	return event

func notification(what, flag = false):
	return [what, flag]
	

extends Node

var fsm: StateMachine

var chair: Sprite

const PlayerSitOffsetX = 4
const PlayerSitOffsetY = -8

func enter(_e):
	render_chair(_e)

func render_chair(e):
	chair = Sprite.new()
	chair.texture = load("res://assets/sprites/entities/items/chairs/slacker.png")
	chair.scale = Vector2(2, 2)
	chair.z_index = e.z_index - 1
	chair.position = Vector2(e.position.x, e.position.y - 15)
	chair.flip_h = e.sprite.flip_h
	add_child(chair)
	
	if(chair.flip_h):
		e.position = Vector2(e.position.x - PlayerSitOffsetX, e.position.y + PlayerSitOffsetY)
	else:
		e.position = Vector2(e.position.x + PlayerSitOffsetX, e.position.y + PlayerSitOffsetY)

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
	

extends Entity
class_name Player

export(float) var acceleration = 2400
export(float) var air_accel = 600
export(float) var friction = 1200
export(float) var drag = 40
export(float) var max_speed = 220
export(float) var max_airspeed = 400
export(float) var jump_height = 640
export(float) var jump_cut_threshold = -440 

onready var ui = $CanvasLayer/PlayerUI
onready var state_machine = $MovementStateMachine
onready var sprite = $Sprite
onready var camera = $Camera2D
onready var chat_bubble = $ChatBubble

var angled_jump_horizontal_bonus = 180
var accepting_input = true
var has_jump = false
var direction = 1

func _ready():
	Global.player_node = self
	sprite.play()
	connect_ui()
	state_machine.connect("state_changed", self, "_on_state_changed")

# warning-ignore:unused_argument
func _physics_process(delta):
	DefineNetworkedState()

func DefineNetworkedState():
	var state = {"T": OS.get_system_time_msecs(), "P": get_global_position(), "A": sprite.flip_h}
	GameServer.SendPlayerState(state)

func grounded_movement(delta: float):
		var input_x = get_input_x()
		direction = 0
		if input_x != 0:
			if accepting_input:
				velocity = velocity.move_toward(Vector2(input_x * max_speed, velocity.y), acceleration * delta)
				handle_sprite_flip(input_x)
				direction = input_x
		else:
			velocity = velocity.move_toward(Vector2(0, velocity.y), friction * delta)
			
		
func aerial_movement(delta: float):
	var input_x = get_input_x()
	direction = 0
	if input_x != 0:
		if accepting_input:
			if max_speed >= abs(velocity.x) or (input_x > 0 and velocity.x < 0) or (input_x < 0 and velocity.x > 0):
				velocity = velocity.move_toward(Vector2(input_x * max_speed, velocity.y), air_accel * delta)
				handle_sprite_flip(input_x)
				direction = input_x
				
	if Input.is_action_just_released("jump") and accepting_input:
		jump_cut()
			
	velocity = velocity.move_toward(Vector2(0, velocity.y), drag * delta)
		
		
	
# warning-ignore:unused_argument
func apply_movement(snap_to_ground: bool = true):
	var snap_vector = Vector2.ZERO
	if snap_to_ground:
		snap_vector = get_floor_normal() * 20.0
	#move_and_slide_with_snap
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2.UP)
	
func handle_jump():
	if Input.is_action_pressed("jump") and accepting_input:
		if is_on_floor() and ground_check.is_grounded():
			ground_check.on_parent_jumped()
			
			#Handle angled jump
			var last_floor_normal = get_floor_normal()
			var jump_vel = Vector2.ZERO
			jump_vel.x = velocity.x + (angled_jump_horizontal_bonus * last_floor_normal.x)
			jump_vel.x = clamp(jump_vel.x, -max_airspeed, max_airspeed)
			jump_vel.y = -jump_height * -last_floor_normal.y
			velocity = jump_vel
			
			state_machine.exit_and_change_to("Jump")
		

func jump_cut():
	if velocity.y < jump_cut_threshold:
		velocity.y = jump_cut_threshold
	
func get_input_x():
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
func handle_sprite_flip(input_x):
	if velocity.x > 0 and input_x > 0:
		sprite.flip_h = false
	elif velocity.x < 0 and input_x < 0:
		sprite.flip_h = true

func _on_chat_focused():
	accepting_input = false
	
func _on_chat_unfocused():
	accepting_input = true

func connect_ui():
	ui.visible = true
	ui.connect("chat_focused", self, "_on_chat_focused")
	ui.connect("chat_unfocused", self, "_on_chat_unfocused")
	
func _on_state_changed(new_state):
	sprite.set_animation(new_state)


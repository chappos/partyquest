extends KinematicBody2D

onready var chat_bubble : PackedScene = preload("res://interface/ChatBubble.tscn")

onready var bubble_pos = $BubblePosition
onready var ground_check = $GroundCheckCast
onready var char_name = $Name

var sprite
var chair
var sitting = false

func _ready():
# warning-ignore:return_value_discarded
	GameServer.connect("new_chat_entry", self, "_on_new_chat_entry")
	for child in $Sprites.get_children():
		child.visible = false

func set_sprite(sprite_code):
	if sprite:
		sprite.stop()
		sprite.frame = 0
		sprite.visible = false
	#Set new sprite
	sprite = $Sprites.get_child(sprite_code)
	sprite.visible = true
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
	
func UpdatePlayer(new_position, flip, state):
	if state == "Sit":
		if !sitting:
			sitting = true
			sprite.animation = "Sit"
			sprite.flip_h = flip
			render_chair(flip)
	else:
		if sitting:
			sitting = false
			sprite.position = Vector2(sprite.position.x - chair.PlayerSitOffsetX, sprite.position.y - chair.PlayerSitOffsetY)
			chair.queue_free()
		MovePlayer(new_position, flip)
		
func render_chair(flip_h):
	chair = Chair.new(sprite.position, flip_h)
	add_child(chair)
	
	if(flip_h):
		sprite.position = Vector2(sprite.position.x - chair.PlayerSitOffsetX, sprite.position.y + chair.PlayerSitOffsetY)
	else:
		sprite.position = Vector2(sprite.position.x + chair.PlayerSitOffsetX, sprite.position.y + chair.PlayerSitOffsetY)
	
func _on_new_chat_entry(player_id, player_name, new_text):
	var chatter = str(player_id)
	if chatter != self.name:
		return
	var new_bubble = chat_bubble.instance()
	new_bubble.text = player_name + ": " + new_text
	if bubble_pos.get_child_count() > 0:
		bubble_pos.get_child(0).queue_free()
	bubble_pos.add_child(new_bubble)

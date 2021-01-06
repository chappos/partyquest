extends KinematicBody2D

onready var chat_bubble : PackedScene = preload("res://interface/ChatBubble.tscn")

onready var bubble_pos = $BubblePosition
onready var ground_check = $GroundCheckCast

var sprite
var sprite_code = 2

func _ready():
	sprite = $Sprites.get_child(sprite_code)
	sprite.visible = true
	sprite.play()
# warning-ignore:return_value_discarded
	GameServer.connect("new_chat_entry", self, "_on_new_chat_entry")

func set_sprite(sprite_code):
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

func _on_new_chat_entry(player_id, new_text):
	var chatter = str(player_id)
	if chatter != self.name:
		return
	var new_bubble = chat_bubble.instance()
	new_bubble.text = chatter + ": " + new_text
	if bubble_pos.get_child_count() > 0:
		bubble_pos.get_child(0).queue_free()
	bubble_pos.add_child(new_bubble)

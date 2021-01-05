extends Control

onready var latency_label = $VBoxContainer/LatencyLabel
onready var player_text = $VBoxContainer/PlayerChat/TextEdit
onready var chatlog = $VBoxContainer/HBoxContainer/RichTextLabel

onready var chat_bubble : PackedScene = preload("res://interface/ChatBubble.tscn")

signal chat_focused
signal chat_unfocused

#TODO: Make this the characters name
var my_name = "Me"

var max_chat_entries = 16
var player_text_can_release_focus = false # Used to manage double arrow out of chat

func _ready():
	chatlog.scroll_following = true
# warning-ignore:return_value_discarded
	GameServer.connect("latency_changed", self, "_on_latency_changed")
# warning-ignore:return_value_discarded
	GameServer.connect("new_chat_entry", self, "_on_new_chat_entry")

func _process(_delta):	
	if player_text.has_focus():
		if Input.is_action_just_pressed("ui_cancel"):
			player_text.release_focus()
		
		if Input.is_action_just_pressed("ui_accept"):
			if player_text.text == "":
				player_text.release_focus()
			else:
				var new_text = player_text.get_text()
				GameServer.SendChatEntry(new_text)
				player_text.clear()
				add_chat_entry(my_name + ": " + new_text)
				add_chat_bubble(my_name + ": " + new_text)
				chatlog.show()
				
		if Input.is_action_just_pressed("ui_left"):
			if player_text.caret_position == 0:
				if player_text_can_release_focus:
					player_text.release_focus()
					player_text_can_release_focus = false
				else:
					player_text_can_release_focus = true
			else:
				player_text_can_release_focus = false
		
		if Input.is_action_just_pressed("ui_right"):
			if player_text.caret_position == player_text.text.length():
				if player_text_can_release_focus:
					player_text.release_focus()
					player_text_can_release_focus = false
				else:
					player_text_can_release_focus = true
			else:
				player_text_can_release_focus = false
	else:
		if Input.is_action_just_pressed("chat_toggle"):
			if chatlog.visible:
				chatlog.hide()
			else:
				chatlog.show()
		
		if Input.is_action_just_pressed("ui_accept"):
			player_text.grab_focus()
	
	


func add_chat_bubble(new_text):
	var new_bubble = chat_bubble.instance()
	new_bubble.text = new_text
	if Global.player_node.chat_bubble.get_child_count() > 0:
		Global.player_node.chat_bubble.get_child(0).queue_free()
	Global.player_node.chat_bubble.add_child(new_bubble)

func add_chat_entry(new_chat_entry):
	chatlog.text += "\n" + new_chat_entry
	if chatlog.get_line_count() > max_chat_entries:
		chatlog.remove_line(0)

func _on_new_chat_entry(player_name, text):
	var new_chat_entry = str(player_name) + ": " + text
	add_chat_entry(new_chat_entry)

func _on_TextEdit_focus_entered():
	emit_signal("chat_focused")
	print("chat focused")

func _on_TextEdit_focus_exited():
	emit_signal("chat_unfocused")
	print("chat unfocused")
	
func _on_latency_changed(new_latency):
	latency_label.set_text("Latency: " + str(new_latency))

func _on_TextureButton_pressed():
	chatlog.hide()

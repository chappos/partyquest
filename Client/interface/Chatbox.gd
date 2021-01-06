extends Control

onready var player_text = $VBoxContainer/PlayerChat/TextEdit
onready var chatlog = $VBoxContainer/ChatLog/RichTextLabel

signal chat_focused
signal chat_unfocused

var my_name 

var max_chat_entries = 16

func _ready():
	chatlog.scroll_following = true
# warning-ignore:return_value_discarded
	GameServer.connect("new_chat_entry", self, "_on_new_chat_entry")
	my_name = Global.char_name

func _process(_delta):	
	if Input.is_action_just_pressed("ui_accept"):
		if player_text.has_focus():
			var new_text = player_text.get_text()
			GameServer.SendChatEntry(new_text)
			player_text.clear()
			add_chat_entry(my_name, new_text)
			
func add_chat_entry(player_name, new_text):
	var chatter: String = str(player_name)
	if Global.world_node:
		for child in Global.world_node.other_players.get_children():
			if child.name == str(player_name):
				chatter = child.char_name.get_text()
		
	chatlog.text += "\n" + chatter + ": " + new_text
	if chatlog.get_line_count() > max_chat_entries:
		chatlog.remove_line(0)

func _on_new_chat_entry(player_name, text):
	add_chat_entry(player_name, text)

func _on_TextEdit_focus_entered():
	emit_signal("chat_focused")
	print("chat focused")

func _on_TextEdit_focus_exited():
	emit_signal("chat_unfocused")
	print("chat unfocused")

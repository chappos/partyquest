extends Control

onready var select_screen = $NinePatchRect/SelectScreen
onready var create_screen = $NinePatchRect/CreateScreen
onready var create_name_text = $NinePatchRect/CreateScreen/HBoxContainer2/LineEdit
onready var create_confirm_button = $NinePatchRect/CreateScreen/HBoxContainer3/CreateConfirm
onready var create_back_button = $NinePatchRect/CreateScreen/HBoxContainer3/CreateBackButton

onready var character_choice_one = $NinePatchRect/CreateScreen/HBoxContainer/CreateSlot0Button/AnimatedSprite
onready var character_choice_two = $NinePatchRect/CreateScreen/HBoxContainer/CreateSlot1Button/AnimatedSprite
onready var character_choice_three = $NinePatchRect/CreateScreen/HBoxContainer/CreateSlot2Button/AnimatedSprite

onready var slot_zero = $NinePatchRect/SelectScreen/HBoxContainer4/SelectButtonSlot0
onready var slot_one = $NinePatchRect/SelectScreen/HBoxContainer4/SelectButtonSlot1
onready var slot_two = $NinePatchRect/SelectScreen/HBoxContainer4/SelectButtonSlot2

onready var select_slots = [slot_zero, slot_one, slot_two]
onready var create_sprites = [character_choice_one, character_choice_two, character_choice_three]
onready var sprite

var char_list = null
var selected_character = null
var create_selected_sprite = null
var select_index = 0
var unfocused_colour = Color(0.3, 0.3, 0.3, 1)
var focused_colour = Color(1, 1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
# warning-ignore:return_value_discarded
	GameServer.connect("char_list_received", self, "_on_char_list_received")
# warning-ignore:return_value_discarded
	GameServer.connect("char_create_returned", self, "_on_create_returned")
	GameServer.RequestCharacterList()
	clear_selected()
	

func change_selected(new_selected):
	if selected_character:
		selected_character.modulate = unfocused_colour
		selected_character.stop()
		selected_character.set_frame(0)
	selected_character = new_selected.get_child(1)
	selected_character.modulate = focused_colour
	selected_character.play()
	
func clear_selected():
	character_choice_one.modulate = unfocused_colour
	character_choice_two.modulate = unfocused_colour
	character_choice_three.modulate = unfocused_colour
	if selected_character:
		selected_character.stop()
		selected_character.set_frame(0)
		selected_character = null

func create_change_selected(new_selected):
	if create_selected_sprite:
		create_selected_sprite.modulate = unfocused_colour
		create_selected_sprite.stop()
		create_selected_sprite.set_frame(0)
	create_selected_sprite = new_selected
	create_selected_sprite.modulate = focused_colour
	create_selected_sprite.play()
	
func create_clear_selected():
	create_sprites[0].modulate = unfocused_colour
	create_sprites[1].modulate = unfocused_colour
	create_sprites[2].modulate = unfocused_colour
	if create_selected_sprite:
		create_selected_sprite.stop()
		create_selected_sprite.set_frame(0)
		create_selected_sprite = null

func clear_placeholders():
	for button in select_slots:
		if button.get_child_count() > 1:
			button.get_child(1).queue_free()

func _on_char_list_received(new_list):
	char_list = new_list
	var count = 0
	clear_placeholders()
	for key in char_list.keys():
		var new_anim = create_sprites[char_list[key].CharSprite].duplicate()
		select_slots[count].get_child(0).text = key
		select_slots[count].add_child(new_anim)
		count += 1
		

func _on_CreateSlot0Button_pressed():
	create_change_selected(character_choice_one)
	select_index = 0

func _on_CreateSlot1Button_pressed():
	create_change_selected(character_choice_two)
	select_index = 1

func _on_CreateSlot2Button_pressed():
	create_change_selected(character_choice_three)
	select_index = 2

func _on_ChangeToCreateButton_pressed():
	select_screen.hide()
	create_screen.show()
	clear_selected()

func _on_CreateBackButton_pressed():
	create_screen.hide()
	select_screen.show()
	create_clear_selected()
	GameServer.RequestCharacterList()

func _on_CreateConfirm_pressed():
	if create_name_text.text == "":
		print("Name cannot be blank")
		return
	if create_name_text.text.length() > 12:
		print("Name must not exceed 12 characters")
		return
	if create_selected_sprite == null:
		print("You must choose a character")
		return
	
	create_back_button.disabled = true
	create_confirm_button.disabled = true
	GameServer.RequestCreateCharacter(create_name_text.text, select_index)

func _on_create_returned(result):
	create_back_button.disabled = false
	create_confirm_button.disabled = false
	if result:
		_on_CreateBackButton_pressed()
	else:
		print("Unable to create new character")


func _on_SelectButtonSlot0_pressed():
	change_selected(select_slots[0])
	select_index = 0

func _on_SelectButtonSlot1_pressed():
	change_selected(select_slots[1])
	select_index = 1

func _on_SelectButtonSlot2_pressed():
	change_selected(select_slots[2])
	select_index = 2

func _on_PlayButton_pressed():
	if selected_character == null:
		print("You must select a character first")
		return
	var selected_name = selected_character.get_parent().get_child(0).text
	get_tree().change_scene("res://World.tscn")
	GameServer.ChooseCharacter(selected_name, char_list[selected_name].CharSprite)
	self.call_deferred("queue_free")
	

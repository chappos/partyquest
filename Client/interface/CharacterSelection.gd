extends Control

onready var select_screen = $NinePatchRect/SelectScreen
onready var create_screen = $NinePatchRect/CreateScreen

onready var character_choice_one = $NinePatchRect/CreateScreen/HBoxContainer/TextureButton/AnimatedSprite
onready var character_choice_two = $NinePatchRect/CreateScreen/HBoxContainer/TextureButton2/AnimatedSprite
onready var character_choice_three = $NinePatchRect/CreateScreen/HBoxContainer/TextureButton3/AnimatedSprite

var selected_character = null
var unfocused_colour = Color(0.3, 0.3, 0.3, 1)
var focused_colour = Color(1, 1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	character_choice_one.modulate = unfocused_colour
	character_choice_two.modulate = unfocused_colour
	character_choice_three.modulate = unfocused_colour


func change_selected(new_selected):
	if selected_character:
		selected_character.modulate = unfocused_colour
		selected_character.stop()
		selected_character.set_frame(0)
	selected_character = new_selected
	selected_character.modulate = focused_colour
	selected_character.play()

func _on_TextureButton_pressed():
	change_selected(character_choice_one)

func _on_TextureButton2_pressed():
	change_selected(character_choice_two)

func _on_TextureButton3_pressed():
	change_selected(character_choice_three)

func _on_ChangeToCreateButton_pressed():
	select_screen.hide()
	create_screen.show()

func _on_CreateBackButton_pressed():
	create_screen.hide()
	select_screen.show()

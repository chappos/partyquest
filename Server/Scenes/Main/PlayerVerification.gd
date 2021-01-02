extends Node

onready var player_container_scene = preload("res://Scenes/Instances/PlayerContainer.tscn")

var test_data = {
	"Stats": {
		"HP": 50,
		"STR": 4,
		"DEX": 4,
		"INT": 8,
		"LUK": 8
	}
}

func start(player_id):
	#Match token here
	
	CreatePlayerContainer(player_id)
	
func CreatePlayerContainer(player_id):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	var player_container = get_node("../" + str(player_id))
	FillPlayerContainer(player_container)
	
func FillPlayerContainer(player_container):
	player_container.player_stats = test_data # This data should come from the authentication server

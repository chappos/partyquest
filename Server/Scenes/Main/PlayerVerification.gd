extends Node

onready var main_interface = get_parent()
onready var player_container_scene = preload("res://Scenes/Instances/PlayerContainer.tscn")

var awaiting_verification = {}

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
	awaiting_verification[player_id] = {"Timestamp": OS.get_unix_time()}
	main_interface.FetchToken(player_id)
	
func Verify(player_id, token):
	var token_verification = false
	while OS.get_unix_time() - int(token.right(64)) <= 30:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			CreatePlayerContainer(player_id)
			awaiting_verification.erase(player_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			yield(get_tree().create_timer(3), "timeout")
			
	main_interface.ReturnTokenVerificationResults(player_id, token_verification)
	if token_verification == false:
		awaiting_verification.erase(player_id)
		main_interface.network.disconnect_peer(player_id)
	
func _on_VerificationExpiration_timeout():
	var current_time = OS.get_unix_time()
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= 10:
				awaiting_verification.erase(key)
				var connected_peers = Array(get_tree().get_network_connected_peers())
				if connected_peers.has(key):
					main_interface.ReturnTokenVerificationResults(key, false)
					main_interface.network.disconnect_peer(key)
	print("Awaiting verification:")
	print(awaiting_verification)

	
func CreatePlayerContainer(player_id):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	var player_container = get_node("../" + str(player_id))
	FillPlayerContainer(player_container)
	
func FillPlayerContainer(player_container):
	player_container.player_stats = test_data # This data should come from the authentication server

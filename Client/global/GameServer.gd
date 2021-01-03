extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
#var ip = "106.68.238.174"
var port = 1909
var token

signal login_succeeded
signal login_failed

signal spawn_player
signal despawn_player

signal world_state_updated

func _ready():
	pass
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print("Failed to connect to server")
	
func _OnConnectionSucceeded():
	print("Successfully connected to server")

remote func FetchToken():
	rpc_id(1, "ReturnToken", token)
	
remote func ReturnTokenVerificationResults(result):
	if result == true:
		emit_signal("login_succeeded")
	else:
		emit_signal("login_failed")
		
remote func SpawnNewPlayer(player_id, spawn_position):
	emit_signal("spawn_player", player_id, spawn_position)
	
remote func DespawnPlayer(player_id):
	emit_signal("despawn_player", player_id)
	
func SendPlayerState(player_state):
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)
	
remote func ReceiveWorldState(world_state):
	emit_signal("world_state_updated", world_state)

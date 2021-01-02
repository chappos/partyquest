extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

onready var player_verification_process = get_node("PlayerVerification")

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disonnected")
	
func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	player_verification_process.start(player_id)
	
func _Peer_Disonnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	get_node(str(player_id)).queue_free()

extends Node

onready var player_verification_process = get_node("PlayerVerification")

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var expected_tokens = []
var player_state_collection = {}

func _ready():
	StartServer()

func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	player_verification_process.start(player_id)
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
		player_state_collection.erase(player_id)
		rpc_id(0, "DespawnPlayer", player_id)

func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)
	print("Expected tokens:")
	print(expected_tokens)

func FetchToken(player_id):
	rpc_id(player_id, "FetchToken")
	
remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id, token)
	
func ReturnTokenVerificationResults(player_id, result):
	rpc_id(player_id, "ReturnTokenVerificationResults", result)

remote func RequestJoinWorld(char_name, char_sprite):
	var player_id = get_tree().get_rpc_sender_id()
	var result = false
	for child in get_children():
		if child.name == str(player_id):
			result = true
			child.player_name = char_name
			child.player_sprite = char_sprite
	rpc_id(0, "SpawnNewPlayer", player_id, Vector2.ZERO, char_name, char_sprite)
	rpc_id(player_id, "ReturnJoinGameWorldResults", result)

remote func RetreiveCharacterList(token):
	var player_id = get_tree().get_rpc_sender_id()
	HubConnection.RequestCharacterList(token, player_id)

func ReturnCharacterListResults(char_list, player_id):
	rpc_id(player_id, "ReturnCharacterList", char_list)

remote func CreateCharacterRequest(char_name, char_sprite, token):
	var player_id = get_tree().get_rpc_sender_id()
	var valid_request = true
	if char_name == "":
		valid_request = false
	if char_sprite > 2 or char_sprite < 0:
		valid_request = false
	
	if valid_request == false:
		ReturnCreateCharacterRequest(valid_request, player_id, 1)
	else:
		HubConnection.CreateCharacter(char_name, char_sprite, token, player_id)
		
remote func ReturnCreateCharacterRequest(result, player_id, message):
	rpc_id(player_id, "ReturnCreateCharacterResults", result, message)

remote func ReceiveChatEntry(text):
	var player_id = get_tree().get_rpc_sender_id()
	SendChatEntry(player_id, text)
	
func SendChatEntry(player_id, text):
	#Validate player text, determine which players receive it
	rpc_id(0, "ReturnChatEntry", player_id, text)

remote func ReceivePlayerState(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state
		
#TODO: Define who to send to based on maps/chunks
func SendWorldState(world_state):
	rpc_unreliable_id(0, "ReceiveWorldState", world_state)
	
remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)
	
remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency", client_time)

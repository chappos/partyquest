extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
#EC2 Authenticate Instance IP
#var ip = "172.31.9.0"
var port = 1912

onready var gameserver = get_node("/root/GameServer")

func _ready():
	ConnectToServer()
	
func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func ConnectToServer():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func RequestCharacterList(token, player_id):
	print("Requesting character list")
	rpc_id(1, "FetchPlayerCharacterList", token, player_id)
	
remote func CharacterListResults(char_list, player_id):
	print("Got character list")
	gameserver.ReturnCharacterListResults(char_list, player_id)

func CreateCharacter(char_name, char_sprite, token, player_id):
	print("Sending create character request")
	rpc_id(1, "CreateCharacter", char_name, char_sprite, token, player_id)
	
remote func CreateCharacterResults(result, player_id, message):
	print("Returning results of character create")
	gameserver.ReturnCreateCharacterRequest(result, player_id, message)

func _OnConnectionFailed():
	print("Failed to connect to Game Server Hub")

func _OnConnectionSucceeded():
	print("Successfully connected to the Game Server Hub")


remote func ReceiveLoginToken(token):
	gameserver.expected_tokens.append(token)

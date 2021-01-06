extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1912
var max_players = 100

var gameserverlist = {}
var current_players = {}

func _ready():
	StartServer()
	
func _process(_delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func StartServer():
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("GameServerHub started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

remote func FetchPlayerCharacterList(token, player_id):
	var server_id = get_tree().get_rpc_sender_id()
	var username
	var char_list = null
	if current_players.has(token):
		username = current_players[token].Username
		if PlayerData.PlayerIDs[username]:
			char_list = PlayerData.PlayerIDs[username].Characters
	
	rpc_id(server_id, "CharacterListResults", char_list, player_id)

#TODO: Remove hardcoding checks on sprite etc
remote func CreateCharacter(char_name, char_sprite, token, player_id):
	var server_id = get_tree().get_rpc_sender_id()
	var result = true
	var username 
	var message
	var new_char
	
	if current_players.has(token):
		username = current_players[token].Username
	else:
		result = false
	
	if PlayerData.PlayerIDs[username].Characters.size() > 3:
		result = false
		message = 4
	if result == true: # Extra check to sometimes avoid iterating here
		for user_key in PlayerData.PlayerIDs.keys():
			for player_char in PlayerData.PlayerIDs[user_key].Characters.keys():
				if player_char == char_name:
					result = false
					message = 3
					break
	if result == true:
		new_char = PlayerData.template_character.duplicate(true)
		new_char.CharSprite = char_sprite
		PlayerData.PlayerIDs[username].Characters[char_name] = new_char
		PlayerData.SavePlayerIDs()
		
	rpc_id(server_id, "CreateCharacterResults", result, player_id, message)

func _Peer_Connected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Connected")
	gameserverlist["GameServer1"] = gameserver_id
	print(gameserverlist)
	
func _Peer_Disconnected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Disconnected")
	
func DistributeLoginToken(token, gameserver):
	var gameserver_peer_id = gameserverlist[gameserver]
	rpc_id(gameserver_peer_id, "ReceiveLoginToken", token)

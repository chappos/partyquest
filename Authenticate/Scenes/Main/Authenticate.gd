extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
var max_servers = 5

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Server Started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disonnected")
	
func _Peer_Connected(gateway_id):
	print("Gateway " + str(gateway_id) + " Connected")
	
func _Peer_Disonnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disconnected")
	
remote func AuthenticatePlayer(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var hashed_password
	var token
	var result
	if not PlayerData.PlayerIDs.has(username):
		result = false
	else:
		var retrieved_salt = PlayerData.PlayerIDs[username].Salt
		hashed_password = GenerateHashedPassword(password, retrieved_salt)
		if not PlayerData.PlayerIDs[username].Password == hashed_password:
			result = false
		else:
			result = true
		
			randomize()
			var hashed = str(randi()).sha256_text()
			var timestamp = str(OS.get_unix_time())
			token = hashed + timestamp
		
			GameServers.current_players[token] = {"Username": username}
			#TODO: Replace hardcoded GameServer1 reference with loadbalance solution
			var gameserver = "GameServer1" 
			GameServers.DistributeLoginToken(token, gameserver)

	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)

remote func CreateAccount(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = GenerateSalt()
		var hashed_password = GenerateHashedPassword(password, salt)
		PlayerData.PlayerIDs[username] = {"Password": hashed_password, "Salt": salt, "Characters": {}}
		PlayerData.SavePlayerIDs()
		
	rpc_id(gateway_id, "CreateAccountResults", result, player_id, message)
	
	
#TODO: Remove hardcoding checks on sprite etc
remote func CreateCharacter(char_name, char_sprite, token, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result = true
	var username 
	var message
	var new_char
	
	if GameServers.current_players.has(token):
		username = GameServers.current_players[token].Username
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
		
	rpc_id(gateway_id, "CreateCharacterResults", result, player_id, message)
	
remote func FetchPlayerCharacterList(token, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var username
	var char_list = null
	if GameServers.current_players.has(token):
		username = GameServers.current_players[token].Username
		if PlayerData.PlayerIDs[username]:
			char_list = PlayerData.PlayerIDs[username].Characters
	
	rpc_id(gateway_id, "CharacterListResults", char_list, player_id)
		
	
func GenerateSalt():
	randomize()
	var salt = str(randi()).sha256_text()
	return salt

#TODO: Change hashing function to slow hash
func GenerateHashedPassword(password, salt):
	var hashed_password = password
	var rounds = pow(2, 18) #262144
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	return hashed_password

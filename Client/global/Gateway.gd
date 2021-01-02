extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1910

var username
var password

signal login_failed

func _ready():
	pass
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func ConnectToServer(_username, _password):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	username = _username
	password = _password
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print("Failed to connect to login server")
	emit_signal("login_failed")
	
func _OnConnectionSucceeded():
	print("Successfully connected to login server")
	RequestLogin()
	
func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password)
	username = ""
	password = ""
	
remote func ReturnLoginRequest(results, token):
	print("results received")
	if results == true:
		GameServer.token = token
		GameServer.ConnectToServer()
	else:
		print("Incorrect username or password")
		emit_signal("login_failed")
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")

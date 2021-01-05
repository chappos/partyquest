extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
#var ip = "ec2-13-211-145-62.ap-southeast-2.compute.amazonaws.com"
var port = 1910
var cert = load("res://resources/certificate/X509_Certificate.crt")

var username
var password
var new_account = false
var char_select = false

signal login_failed
signal account_create_succeeded
signal account_create_failed
signal char_create_returned(result)
signal char_list_received(char_list)

func _ready():
	pass
	
func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func ConnectToServer(_username, _password, _new_account):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false) #True for signed, false for self signed 
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
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
	if new_account == true:
		RequestCreateAccount()
	elif char_select == true:
		RequestCharacterList()
		char_select = false
	else:
		RequestLogin()

func RequestCharacterList():
	rpc_id(1, "RetreiveCharacterList", GameServer.token)
	
remote func ReturnCharacterList(char_list):
	emit_signal("char_list_received", char_list)

func RequestCreateCharacter(char_name, char_sprite):
	rpc_id(1, "CreateCharacterRequest", char_name, char_sprite, GameServer.token)
	
remote func ReturnCreateCharacterResults(result, _message):
	emit_signal("char_create_returned", result)

func RequestCreateAccount():
	print("Requesting new account")
	rpc_id(1, "CreateAccountRequest", username, password.sha256_text())
	username = ""
	password = ""
	
remote func ReturnCreateAccountRequest(results, message):
	if results == true:
		print("Account created, please proceed with login")
		emit_signal("account_create_succeeded")
	else:
		if message == 1:
			print("Couldn't create account, please try again")
		elif message == 2:
			print("Username already exists")
		emit_signal("account_create_failed")
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")

func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password.sha256_text())
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

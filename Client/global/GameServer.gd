extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
#var ip = "106.68.238.174"
var port = 1909

var token

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
		#handle login screen closing
		print("Token validated successfully")
	else:
		#reenable login button
		print("Login failed, please try again")

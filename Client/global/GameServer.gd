extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
#var ip = "106.68.238.174"
var port = 1909
var token

var client_clock : int = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

signal login_succeeded
signal login_failed
signal spawn_player
signal despawn_player
signal world_state_updated
signal latency_changed(new_latency)

func _ready():
	pass
	
func _physics_process(delta): # 0.01667
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print("Failed to connect to server")
	
func _OnConnectionSucceeded():
	print("Successfully connected to server")
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)

remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time / 2)
	client_clock = server_time + latency
	
func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())
	
remote func ReturnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		emit_signal("latency_changed", latency)
		latency_array.clear()

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

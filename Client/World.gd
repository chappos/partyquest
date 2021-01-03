extends Node2D

onready var player_spawn = preload("res://entities/PlayerTemplate.tscn")
onready var other_players = $OtherPlayers

var last_world_state = 0
var world_state_buffer = []
const interpolation_offset = 100

func _ready():
# warning-ignore:return_value_discarded
	GameServer.connect("spawn_player", self, "_on_spawn_player")
# warning-ignore:return_value_discarded
	GameServer.connect("despawn_player", self, "_on_despawn_player")
# warning-ignore:return_value_discarded
	GameServer.connect("world_state_updated", self, "_on_world_state_updated")
	
func _physics_process(_delta):
	var render_time = OS.get_system_time_msecs() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if other_players.has_node(str(player)):
					var new_pos = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					other_players.get_node(str(player)).MovePlayer(new_pos)
				else:
					_on_spawn_player(player, world_state_buffer[2][player]["P"])
		elif render_time > world_state_buffer[1].T: # No future world state available
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"] - 1.00)
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if other_players.has_node(str(player)):
					var pos_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_pos = world_state_buffer[1][player]["P"] + (pos_delta * extrapolation_factor)
					other_players.get_node(str(player)).MovePlayer(new_pos)

	
func _on_world_state_updated(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

func _on_spawn_player(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		return
	else:
		if not other_players.has_node(str(player_id)):
			var new_player = player_spawn.instance()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			other_players.add_child(new_player)
		
	
func _on_despawn_player(player_id):
	yield(get_tree().create_timer(0.2), "timeout")
	other_players.get_node(str(player_id)).queue_free()
	



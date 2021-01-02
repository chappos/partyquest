extends Node


var PlayerIDs

func _ready():
	var playerdata_file = File.new()
	playerdata_file.open("res://Data/playerdata.json", File.READ)
	var playerdata_json = JSON.parse(playerdata_file.get_as_text())
	playerdata_file.close()
	PlayerIDs = playerdata_json.result

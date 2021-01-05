extends Node


var PlayerIDs
var template_character = {"CharSprite":"0", "Level":"1", "EXP":"0"}

func _ready():
	var playerdata_file = File.new()
	playerdata_file.open("PlayerIDs.json", File.READ)
	var playerdata_json = JSON.parse(playerdata_file.get_as_text())
	playerdata_file.close()
	PlayerIDs = playerdata_json.result

func SavePlayerIDs():
	var save_file = File.new()
	save_file.open("PlayerIDs.json", File.WRITE)
	save_file.store_line(to_json(PlayerIDs))
	save_file.close()

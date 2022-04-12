extends Node2D

class_name Chair

const PlayerSitOffsetX = 4
const PlayerSitOffsetY = -8

var default_chair = preload("res://assets/sprites/entities/items/chairs/slacker.png")
var sprite: Sprite

func _init(player_pos, flip_h):
	self.position = Vector2(player_pos.x, player_pos.y - 15)
	create_sprite(flip_h)
	
func create_sprite(flip_h):
	sprite = Sprite.new()
	sprite.texture = default_chair
	sprite.flip_h = flip_h
	sprite.scale = Vector2(2, 2)
	sprite.z_index = -1
	
	add_child(sprite)

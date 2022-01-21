extends TextureButton



onready var _sprite = $sprite
# global.PLAYER.BLACK | global.PLAYER.WHITE
var player = 0 setget set_player, get_player


func get_player():
	return player


func set_player(value):
	player = value
	_sprite.frame = player


func set_highlight(should_highlight):
	if should_highlight:
		_sprite.modulate = Color("#33FF33")
	else:
		_sprite.modulate = Color("#FFFFFF")
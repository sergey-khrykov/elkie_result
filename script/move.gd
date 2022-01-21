extends Object

class_name Move

var from: Vector2
var to: Vector2
# should be either "step" or "jump"
var type: String

# move_type can be either "step" or "jump"
func _init(from_coords: Vector2, to_coords: Vector2, move_type: String):
	from = from_coords
	to = to_coords
	type = move_type

func reverse():
	return get_script().new(to, from, type)

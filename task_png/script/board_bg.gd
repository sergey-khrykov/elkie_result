extends Node2D

const _TINT_COLOR = Color("#f9b067")

var _cell_scene = preload("res://script/cell.tscn")

func _ready():
	# generate board background
	for row in range(global.BOARD_SIZE):
	 for column in range(global.BOARD_SIZE):
		 # init graphics
		 var tile_pos = Vector2(row * global.CELL_PIXELS, column * global.CELL_PIXELS)
		 var cell = _cell_scene.instance()
		 cell.rect_position = tile_pos
		 # tint every other cell
		 if (row % 2 == 0) == (column % 2 == 0):
			 cell.modulate = _TINT_COLOR
		 # add to the node tree
		 add_child(cell)
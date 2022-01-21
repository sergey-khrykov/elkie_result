extends Object

class_name BoardData


var _board_data = []
var checkers = {
	global.PLAYER.BLACK: [],
	global.PLAYER.WHITE: []
} setget , get_checkers


func _init(reversed = false):
	_board_data = []
	for y in range(global.BOARD_SIZE):
		_board_data.append([])
		for x in range(global.BOARD_SIZE):
			var cell_owner;
			if (x < global.CHECKER_ROWS && y < global.CHECKER_ROWS):
				# black checkers in the upper left corner 
				cell_owner = global.PLAYER.BLACK if !reversed else global.PLAYER.WHITE
			elif (x >= (global.BOARD_SIZE - global.CHECKER_ROWS) && y >= (global.BOARD_SIZE - global.CHECKER_ROWS)):
				# white checkers in the lower right corner
				cell_owner = global.PLAYER.WHITE if !reversed else global.PLAYER.BLACK
			else:
				cell_owner = global.PLAYER.EMPTY
			_board_data[y].append(cell_owner)
			if cell_owner != global.PLAYER.EMPTY:
				checkers[cell_owner].push_back(Vector2(x,y))


func get_cell(coordinates: Vector2):
	return _board_data[coordinates.y][coordinates.x]


func _set_cell(coordinates: Vector2, value: int):
	_board_data[coordinates.y][coordinates.x] = value

	
func get_checkers():
	return checkers


func apply_move(move):
	var player = get_cell(move.from)

	_set_cell(move.from, global.PLAYER.EMPTY)
	_set_cell(move.to, player)

	var checker_idx = checkers[player].find(move.from)
	checkers[player][checker_idx] = move.to
	return


# returns an array of possible moves: { from: Vector2, to: Vector2, type: "step" | "jump" }
func get_moves(from: Vector2, only_jumps: bool):
	var moves = []
	for y in [-1, 0, 1]:
		var y_check = from.y + y
		for x in [-1, 0, 1]:
			var x_check = from.x + x
			if !is_on_board(x_check, y_check):
				continue
			if _board_data[y_check][x_check] == global.PLAYER.EMPTY:
				if (!only_jumps):
					moves.push_back(Move.new(from, Vector2(x_check, y_check),"step"))
			else:
				# if the cell is occupied check if we can hop into the cell behind
				var y_check_jump = y_check + y
				var x_check_jump = x_check + x
				if !is_on_board(x_check_jump, y_check_jump):
					continue
				if _board_data[y_check_jump][x_check_jump] == global.PLAYER.EMPTY:
					moves.push_back(Move.new(from, Vector2(x_check_jump, y_check_jump), "jump"))
	return moves


func is_on_board(x, y):
	return (x >= 0 && x < global.BOARD_SIZE) && (y >= 0 && y < global.BOARD_SIZE)


func check_win(player):
	var rng = (
		range(global.CHECKER_ROWS) if player == global.PLAYER.WHITE
		else range(global.BOARD_SIZE - global.CHECKER_ROWS, global.BOARD_SIZE)
	)
	var score = 0
	for row in rng:
		for col in rng:
			if _board_data[col][row] == player:
				score += 1
	
	return score == global.CHECKER_ROWS * global.CHECKER_ROWS

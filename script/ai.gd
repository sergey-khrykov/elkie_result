extends Object

class_name AI



# global.PLAYER.BLACK | global.PLAYER.WHITE
var _player: int
var _goal_corner: Vector2
var _goal_cells: Array
var _current_goal: Vector2
# keep track of checkers that already reached their goals
var _ignored_checkers: Array
var _rng = RandomNumberGenerator.new()



# player_id: global.PLAYER.BLACK | global.PLAYER.WHITE
func _init(player_id: int, board_data: BoardData):
	_player = player_id
	_goal_corner = (
		Vector2(-1,-1) if _player == global.PLAYER.WHITE
		else Vector2(global.BOARD_SIZE, global.BOARD_SIZE)
	)
	# our goal cells are the starting positions of the opposite team
	_goal_cells = [] + board_data.checkers[global.get_opponent(_player)]
	_goal_cells.sort_custom(self, "_is_closer_to_goal_corner")
	_current_goal = _goal_cells.pop_front()
	_rng.randomize()


func _is_closer_to_goal_corner(a: Vector2, b: Vector2):
	return a.distance_to(_goal_corner) < b.distance_to(_goal_corner)


# `move_stack`: `Array` of `Move`s
func _get_score(move_stack: Array):
	# rate based on how much the move sequence gets you closer to the goal
	var start = move_stack[0].from
	var end = move_stack[-1].to
	return start.distance_to(_current_goal) - end.distance_to(_current_goal)


# mutates `best_move_stacks`
func _update_best_move_stacks(best_score, best_move_stacks, move_stack):
	var score = _get_score(move_stack)
	if score > best_score:
		best_score = score
		best_move_stacks.clear()
		best_move_stacks.append(move_stack)
	elif score == best_score:
		best_move_stacks.append(move_stack)
	return best_score


# determine best move stacks by going through jump moves recursively
# mutates `best_move_stacks`, returns updated `best_score`
# basically searches depth-first through the graph of possible jump moves
func _update_best_move_stacks_with_jumps(board_data, move_stack, best_score, best_move_stacks):
	best_score = _update_best_move_stacks(best_score, best_move_stacks, move_stack)

	var start_position = move_stack[-1].to
	for move in board_data.get_moves(start_position, true):
		# check if it was in any of the "from"s in the moves before
		var is_cyclic = false
		for prev_move in move_stack:
			if prev_move.from == move.to:
				is_cyclic = true
				break
		if is_cyclic:
			continue
		var new_move_stack = [] + move_stack
		new_move_stack.append(move)
		var new_best_score = _update_best_move_stacks_with_jumps(
			board_data, new_move_stack, best_score, best_move_stacks
		)
		if new_best_score > best_score:
			best_score = new_best_score
	return best_score

# returns an array of consecutive moves for one turn
func choose_moves(board_data: BoardData):
	var best_score = -INF
	var best_move_stacks = []

	var checkers = board_data.checkers[_player]

	# set next goal if we reached the current one
	while board_data.get_cell(_current_goal) == _player:
		_ignored_checkers.append(checkers.find(_current_goal))
		_current_goal = _goal_cells.pop_front()

	for i in range(checkers.size()):
		var checker = checkers[i]
		# don't move checkers that already reached the goal
		if _ignored_checkers.has(i):
			continue
		for move in board_data.get_moves(checker, false):
			var move_stack = [move]
			if move.type == "step":
				best_score = _update_best_move_stacks(best_score, best_move_stacks, move_stack)
			elif move.type == "jump":
				best_score = _update_best_move_stacks_with_jumps(
					board_data, move_stack, best_score, best_move_stacks
				)

	return best_move_stacks[_rng.randi_range(0, best_move_stacks.size() - 1)]

extends Control


# all 2d node scenes used (cell, checker and movement hint) are presumed
# to be scaled to conform to target cell size defined in global.CELL_PIXELS constant


const _PLAYED_BY_BOT = [global.PLAYER.WHITE]
# const _PLAYED_BY_BOT = [global.PLAYER.WHITE, global.PLAYER.BLACK]



onready var _checkers_view = $board/checkers_view
onready var _moves_view = $board/moves_view

onready var _gui_gameplay = $gui_gameplay
onready var _gui_ending = $gui_ending

# game state
var _bots: Dictionary
var _board_data: BoardData
var _current_player = global.PLAYER.BLACK
var _move_stack = []
var _turn_count = 1



func _ready():
	_checkers_view.connect("hovered_checker", self, "_on_checker_hover")
	_checkers_view.connect("unhovered_checker", self, "_on_checker_unhover")
	_checkers_view.connect("selected_checker", self, "_on_checker_select")
	_checkers_view.connect("clicked_selected_checker", self, "_on_checker_click_selected")
	_checkers_view.connect("finished_bot_turn", self, "_end_turn")

	_moves_view.connect("move", self, "_on_move")

	_gui_ending.connect("new_game", self, "_new_game")

	_new_game()



# HANDLE INPUT
func _on_checker_hover(was_selected):
	if _move_stack.size() > 0:
		if was_selected:
			_gui_gameplay.set_action_hint("end turn")
		else:
			_gui_gameplay.set_action_hint("restart turn")


func _on_checker_unhover():
	_gui_gameplay.set_action_hint(null)


func _on_checker_select(board_position):
	if _move_stack.size() > 0:
		# if we select another checker after making moves, undo current moves and hide move hints
		while _move_stack.size() > 0:
			var undo = _move_stack.pop_back().reverse()
			_board_data.apply_move(undo)
			_checkers_view.move_checker(undo)
		_gui_gameplay.set_action_hint(null)
	
	_moves_view.display(_board_data.get_moves(board_position, false))


func _on_checker_click_selected():
	if _move_stack.size() > 0:
		# if we made moves, clicking selected checker confirms and ends the turn
		_end_turn()
	

func _on_move(move: Move):
	var returned = (_move_stack.size() > 0) && (_move_stack[0].from == move.to)
	if returned:
		_move_stack = []
	else:
		_move_stack.push_back(move)

	_board_data.apply_move(move)
	_checkers_view.move_checker(move)

	var new_moves = []
	# check if we can make another jump move
	if move.type == "jump":
		new_moves = _board_data.get_moves(move.to, !returned)
	elif returned:
		new_moves = _board_data.get_moves(move.to, false)
	else:
		# or display a single move that lets you undo the current move
		new_moves = [ move.reverse() ]
	_moves_view.display(new_moves)



# GAME FLOW HELPERS
func _new_game():
	_board_data = BoardData.new()

	_bots = {}
	for player_id in _PLAYED_BY_BOT:
		_bots[player_id] = AI.new(player_id, _board_data)

	_turn_count = 1
	_current_player = global.PLAYER.BLACK
	_gui_ending.visible = false
	_gui_gameplay.visible = true
	_checkers_view.init_checkers(_board_data)
	_start_turn()


func _end_turn():
	_moves_view.display(null)
	_gui_gameplay.set_action_hint(null)
	_move_stack = []
	var did_win = _board_data.check_win(_current_player)
	if did_win:
		_checkers_view.set_interactive(global.PLAYER.EMPTY)
		_gui_gameplay.visible = false
		_gui_ending.visible = true
		_gui_ending.set_winner(_current_player)
	else:
		_current_player = global.get_opponent(_current_player)
		if _current_player == global.PLAYER.BLACK:
			_turn_count += 1
		_start_turn()


func _start_turn():
	_gui_gameplay.update_turn_status(_current_player, _turn_count)
	if _bots.has(_current_player):
		_checkers_view.set_interactive(global.PLAYER.EMPTY)
		_move_stack = _bots[_current_player].choose_moves(_board_data)
		for move in _move_stack:
			_board_data.apply_move(move)
		_checkers_view.play_bot_turn(_move_stack)
	else:
		_checkers_view.set_interactive(_current_player)


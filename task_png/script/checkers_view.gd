extends Control



signal hovered_checker(was_selected)
signal unhovered_checker()
signal selected_checker(board_position)
signal clicked_selected_checker()
signal finished_bot_turn()

const _BOT_WAIT_TIME = 0.5

var _checker_scene = preload("res://script/checker.tscn")

onready var _selection_circle = $selection_circle
onready var _tween = $tween

# dictionary with checkers, their coordinates on the grid are keys - xy: checker
var _checkers = {}
var _hovered_checker = null
var _selected_checker = null
var _currently_interactive = global.PLAYER.EMPTY



# choose which _checkers, if any, should be interactive
# possible values: global.PLAYER.BLACK, global.PLAYER.WHITE, global.PLAYER.EMPTY
func set_interactive(player_id):
	if player_id != _currently_interactive:
		_selection_circle.visible = false
		if _selected_checker:
			_selected_checker.set_highlight(false)
			_selected_checker = null
	_currently_interactive = player_id
	_update_hovered()


func init_checkers(board_data: BoardData):
	var reuse = !_checkers.empty()
	var old_checkers = _checkers.values()
	_checkers.clear()
	# add _checkers to the board and connect their signals

	for player_id in board_data.checkers.keys():
		for pos in board_data.checkers[player_id]:
			var checker
			if reuse:
				checker = old_checkers.pop_back()
			else:
				checker = _checker_scene.instance();
				add_child(checker)

				# connect mouse events
				checker.connect("mouse_entered", self, "_on_checker_hover", [checker])
				checker.connect("mouse_exited", self, "_on_checker_unhover", [checker])
				checker.connect("button_up", self, "_on_checker_clicked", [checker])

			_checkers["%s %s" % [pos.x, pos.y]] = checker
			checker.rect_position = Vector2(pos.x * global.CELL_PIXELS, pos.y * global.CELL_PIXELS)
			checker.player = player_id


func move_checker(move: Move):
	var key_from = "%s %s" % [move.from.x, move.from.y]
	var key_to = "%s %s" % [move.to.x, move.to.y]
	var checker = _checkers[key_from]
	_checkers.erase(key_from) # todo: maybe simplify, it should work correctly without erasing anything
	_checkers[key_to] = checker
	var target_position = Vector2(
		move.to.x * global.CELL_PIXELS,
		move.to.y * global.CELL_PIXELS
	);

	# display animated checker on top of others
	move_child(checker, get_child_count())

	_tween.interpolate_property(
		checker, "rect_position", checker.rect_position, target_position,
		1, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
	)
	_tween.start()

	yield(_tween, "tween_completed")

	_on_checker_hover(checker)


# move_stack: Array<Move>
func play_bot_turn(move_stack):
	# todo: make sure to check if player's checker is correctly circled
	#       if we still hover over it right after bot finishes it's turn
	for move in move_stack:
		yield(get_tree().create_timer(_BOT_WAIT_TIME), "timeout")
		move_checker(move)

	emit_signal("finished_bot_turn")


func _update_hovered():
	if _currently_interactive != global.PLAYER.EMPTY && !_checkers.empty():
		for checker in _checkers.values():
			if checker.is_hovered():
				_on_checker_hover(checker)
	

func _on_checker_hover(checker):
	if checker.player != _currently_interactive:
		return
	
	_selection_circle.visible = true
	_selection_circle.rect_position = checker.rect_position

	_hovered_checker = checker
	emit_signal("hovered_checker", _selected_checker == _hovered_checker)


func _on_checker_unhover(checker):
	_selection_circle.visible = false
	if _hovered_checker == checker:
		_hovered_checker = null
		emit_signal("unhovered_checker")


func _on_checker_clicked(checker):
	if checker.player != _currently_interactive:
		return

	if _selected_checker == checker:
		emit_signal("clicked_selected_checker")
	else:
		if _selected_checker:
			_selected_checker.set_highlight(false)
		checker.set_highlight(true)
		var board_position = Vector2(
			round(checker.rect_position.x / global.CELL_PIXELS),
			round(checker.rect_position.y / global.CELL_PIXELS)
		)
		_selected_checker = checker
		emit_signal("selected_checker", board_position)

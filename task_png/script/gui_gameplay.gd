extends ColorRect


onready var _turn_counter = $turn_counter
onready var _whos_turn_icon = $whos_turn
onready var _action_hint = $action_hint


func update_turn_status(whos_turn, turn_count):
	_whos_turn_icon.set_player(whos_turn)
	_turn_counter.text = "%s" % turn_count


func set_action_hint(message):
	_action_hint.display(message)


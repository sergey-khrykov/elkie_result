extends ColorRect


signal new_game()


onready var _who_won_icon = $whos_turn
onready var _restart_button = $restart_button


func _ready():
	_restart_button.connect("pressed", self, "on_restart_button_pressed")


func on_restart_button_pressed():
	emit_signal("new_game")


func set_winner(who_won):
	_who_won_icon.set_player(who_won)

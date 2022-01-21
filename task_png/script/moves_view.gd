extends Control


signal move(chosen_move)

var move_scene = preload("res://script/move_button.tscn")
var buttons = []


func _ready():
	self.visible = false
	for _i in range(8):
		var btn = move_scene.instance()
		add_child(btn)
		buttons.push_back(btn)
		btn.connect("button_up", self, "on_move_clicked", [btn])


func on_move_clicked(btn):
	if btn.move:
		emit_signal("move", btn.move)


# moves: Array of Move
func display(moves):
	var i = 0

	if moves:
		for move in moves:
			buttons[i].display(move)
			i += 1

	# make sure the rest is hidden
	while i < buttons.size():
		buttons[i].visible = false
		i += 1

	visible = true

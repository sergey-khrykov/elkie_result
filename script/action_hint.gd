extends Label


func _ready():
	visible = false

func display(message):
	if message:
		text = message
		visible = true
	else:
		visible = false

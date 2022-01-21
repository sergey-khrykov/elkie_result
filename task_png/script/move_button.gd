extends TextureButton


# requires animated sprite with 9 frames. frames 0-7 are direction icons that
# start from "right" at frame index 0 and increase counterclockwise.
# jump icon is at frame index 8
onready var _sprite = $sprite

var move: Move


func display(new_move: Move):
  move = new_move
  match move.type:
    "step":
      var dir = move.to - move.from
      # flip y to convert from screen to cartesian coordinates and get the correct angle
      dir.y = dir.y * -1
      _sprite.frame = _quantize_circle_to_8(dir.angle())
    "jump":
      _sprite.frame = 8
  rect_position = move.to * global.CELL_PIXELS
  visible = true 


# convert angle in radians to an integer from 0 to 7
func _quantize_circle_to_8(angle_rad):
  return round(fmod(angle_rad + (PI * 2), PI * 2) / (2 * PI) * 8)

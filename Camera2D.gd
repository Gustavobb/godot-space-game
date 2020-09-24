extends Camera2D

onready var level = get_parent().get_parent()
export var max_zoom = Vector2.ZERO
export var min_zoom = Vector2.ZERO

func _ready():
	limit_top = level.get_node("Limits/TopLeft").position.y
	limit_left = level.get_node("Limits/TopLeft").position.x
	limit_bottom = level.get_node("Limits/BottomRight").position.y
	limit_right = level.get_node("Limits/BottomRight").position.x

func change_zoom(z):
	if zoom + Vector2(z, z) >= max_zoom and zoom + Vector2(z, z) <= min_zoom:
		zoom = zoom + Vector2(z, z)

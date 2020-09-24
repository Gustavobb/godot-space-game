extends KinematicBody2D

export(int) var MAX_SPEED = 200
export(int) var FRICTION = 30

onready var particle = $Particles2D
onready var rocket_sound = $Rocket
onready var camera = $Camera2D
onready var shoot_ray = $ShootRay
onready var turn_tween = $Tween
signal input_changed

var velocity = Vector2.ZERO
var velocity_vec = Vector2.ZERO
var velocity_vec_cache = Vector2.LEFT
var input = 0
var input_cache
var _angle_add = 0

func _handle_input():
	input_cache = input
	input = Input.get_action_strength("ui_up")
	if input != input_cache: emit_signal("input_changed")

func _aim():
	shoot_ray.set_cast_to(Vector2(0, -(Vector2(320, 180) * camera.zoom)[1]))
	
func _apply_movement():
	velocity = move_and_slide(velocity)

func _apply_input_movement(delta):
	MAX_SPEED = 160 if input else 10
	var _from = Vector2(velocity_vec_cache.x, -velocity_vec_cache.y).normalized() * MAX_SPEED
	var _to = (FRICTION + 240 * input) * delta
	velocity = velocity.move_toward(_from, _to)
		
func _rotate_player(mouse_position):
	velocity_vec = Vector2(mouse_position.x - position.x, position.y - mouse_position.y)
	if input: velocity_vec_cache = velocity_vec
	
	_angle_add = rotation_degrees - atan2(velocity_vec.x, velocity_vec.y) * 180/PI
	if abs(_angle_add) > 180: _angle_add = wrapi(_angle_add - 360, -180, 180)
	
	if int(_angle_add):
		turn_tween.interpolate_property(self, 'rotation_degrees', rotation_degrees, rotation_degrees - _angle_add, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		turn_tween.start()
	
func _physics_process(delta):
	_handle_input()
	_rotate_player(get_global_mouse_position())
	_apply_input_movement(delta)
	_apply_movement()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP: camera.change_zoom(-0.01)
		elif event.button_index == BUTTON_WHEEL_DOWN: camera.change_zoom(0.01)
		
	if event.is_action_pressed("ui_select"): _aim()
	
func _on_Rocket_finished():
	if input: rocket_sound.play()

func _on_Player_input_changed():
	if input:
		particle.emitting = true
		rocket_sound.play()
	
	else:
		particle.emitting = false
		rocket_sound.stop()

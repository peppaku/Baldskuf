extends Node2D

@export var fly_time := 1.0
@onready var sprite = $Sprite2D

var _start_pos: Vector2
var _end_pos: Vector2
var _control: Vector2
var _progress := 0.0

func fly_from_to(start_pos: Vector2, end_pos: Vector2):
	_start_pos = start_pos
	_end_pos = end_pos
	position = _start_pos

	# Генерируем контрольную точку: середина между началом и концом + случайное смещение перпендикулярно
	var mid = (_start_pos + _end_pos) / 2
	var perp = (_end_pos - _start_pos).normalized().orthogonal()
	var curve_magnitude = randf_range(40, 80) * pow(-1,(randi()%2))
	_control = mid + perp * curve_magnitude

	_progress = 0.0
	show()

	var tween = get_tree().create_tween()
	tween.tween_property(self, "_progress", 1.0, fly_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "queue_free"))

func _process(delta):
	if _progress < 1.0:
		# Классическая квадратичная bezier-реализация
		var t = _progress
		var p0 = _start_pos
		var p1 = _control
		var p2 = _end_pos
		position = ((1-t)*(1-t))*p0 + 2*(1-t)*t*p1 + (t*t)*p2

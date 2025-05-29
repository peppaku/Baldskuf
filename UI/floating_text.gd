# FloatingText.gd
extends Node2D

@export var float_distance := 40        # на сколько пикселей поднимется текст
@export var lifetime := 3.2             # как долго текст будет видим
@onready var label = $Label

func show_text(text: String, color: Color = Color.WHITE):
	label.text = text
	label.modulate = color
	# Анимация вверх и затухание
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y - float_distance, lifetime)
	tween.tween_property(label, "modulate:a", 0.0, lifetime)
	tween.connect("finished", Callable(self, "queue_free"))

extends Control

@onready var label = $Label

func show_damage(amount: int, color: Color = Color.RED):
	label = $Label
	label.text = str(amount)
	label.modulate = color
	# Анимация: вверх и исчезнуть
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -40), 0.7)
	tween.tween_property(self, "modulate:a", 0, 0.7)
	tween.finished.connect(queue_free)

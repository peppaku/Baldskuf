extends Node2D

@onready var label = $Label



func floating_text(text: String, color: Color = Color.RED):
	label.text = text
	label.modulate = color
	
	await get_tree().process_frame
	
	var viewport_size = get_viewport_rect().size
	var popup_size = label.size
	
	var pos = get_viewport().get_mouse_position() + Vector2(0, -16)
	
		# Ограничиваем справа и снизу
	if pos.x + popup_size.x > viewport_size.x:
		pos.x = viewport_size.x - popup_size.x
	if pos.x  < 0:
		pos.x = 0
	if pos.y < 0:
		pos.y = 0
	if pos.y + popup_size.y > viewport_size.y:
		pos.y = viewport_size.y - popup_size.y
	
	
	position = pos
	var end_position = pos + Vector2(0, -48)

	# Анимация: вверх и исчезнуть
	var tween = create_tween()
	tween.tween_property(self, "position", end_position, 0.7)
	tween.tween_property(self, "modulate:a", 0, 0.7)
	tween.finished.connect(queue_free)
	

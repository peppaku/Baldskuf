extends CanvasLayer

@onready var btn = $ColorRect/Button
# Called when the node enters the scene tree for the first time.
func _ready():
	btn.pressed.connect(_on_btn_pressed)

func _on_btn_pressed():
	get_tree().reload_current_scene()

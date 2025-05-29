extends CanvasLayer


@onready var start_btn = $ColorRect/Button

func _ready():
	start_btn.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://main_scene.tscn")

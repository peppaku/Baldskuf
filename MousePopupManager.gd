extends Node2D

var popup_scene = preload("res://mouse_popup.tscn")
var popup_instance = null

func show_floating_text(text: String):
	popup_instance = popup_scene.instantiate()
	get_tree().current_scene.add_child(popup_instance)
	popup_instance.floating_text(text)

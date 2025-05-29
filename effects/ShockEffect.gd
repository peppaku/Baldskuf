# res://effects/ShockEffect.gd
extends "res://effects/StatusEffect.gd"

func on_apply(target):
	target.add_effect_overlay("res://effects/Pictures/shock.png", "shock")
	

func on_turn_start(target):
	if stacks > 0:
		print ("стаков шока: ", stacks)
		target.enemy_skip_turn = true  # Или как у тебя реализован пропуск хода
		stacks -= 1
		
		var msg = "⚡⚡⚡im in deep shock, i am SKIPING MY TURN⚡⚡⚡"
		target.show_floating_text_near_character(msg)
	if is_expired():
		on_remove(target)

func is_expired():
	return stacks <= 0

func on_remove(target):
	print ("stacks кончились и эффект должен удалиться: ", stacks)
	target.remove_effect_overlay("shock")

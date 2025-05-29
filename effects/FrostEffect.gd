# res://effects/FrostEffect.gd
extends "res://effects/StatusEffect.gd"

func on_apply(target):
	target.add_effect_overlay("res://effects/Pictures/frost.png", "frost")
	var msg = "❄️❄️❄️Oh, NO, im chill, my damage is sooo little❄️❄️❄️"
	target.show_floating_text_near_character(msg)


func on_attack(target, base_damage):
	return int(base_damage / 2) if stacks > 0 else base_damage

func on_turn_end(target):
	if stacks > 0:
		stacks -= 1
		print ("stacks", stacks)
	if is_expired():
		on_remove(target)

func is_expired():
	return stacks <= 0

func on_remove(target):
	print ("stacks кончились и эффект должен удалиться: ", stacks)
	target.remove_effect_overlay("frost")

# res://effects/ShieldEffect.gd
extends "res://effects/StatusEffect.gd"

@export var shield_points: int = 10

func on_apply(target):
	target.add_effect_overlay("res://effects/Pictures/shield.png", "shield")


func on_damage(target, amount):
	#print ("щит применился на ", target, "c таким щитом: ", shield_points)
	var absorbed = min(amount, shield_points)
	shield_points -= absorbed
	amount -= absorbed
	if shield_points <= 0:
		stacks = 0  # Пометить на удаление
	return amount

func on_turn_end(target): 
	pass
	
func on_turn_start(target):
	stacks -= 1
	if is_expired(): 
		on_remove(target)
		
func is_expired():
	return shield_points <= 0 or stacks <= 0

func on_remove(target):
	print ("stacks кончились и эффект должен удалиться: ", stacks)
	target.remove_effect_overlay("shield")
	

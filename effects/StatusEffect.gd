# res://effects/StatusEffect.gd
extends Resource

@export var name: String = ""
@export var stacks: int = 1  # Можно переопределять под тип эффекта

# Вызывается при применении эффекта к персонажу
func on_apply(target): 
	pass
	
# Вызывается при получении урона
func on_damage(target, amount): 
	return amount
	
# Вызывается при начале своего хода (например, для оглушения/шока)
func on_turn_start(target): 
	pass
	
# Вызывается при конце хода
func on_turn_end(target): 
	pass
	
# Модифицирует исходящий урон (например, для мороза)
func on_attack(target, base_damage):
	return base_damage
	
# Если true — эффект больше неактивен
func is_expired(): 
	return false

func on_remove(target):
	pass

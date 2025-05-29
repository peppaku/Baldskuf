# 📦 Ability.gd — ресурс для описания заклинаний/способностей
# Расположение: res://Abilities/Ability.gd

extends Resource
class_name Ability

@export var name: String = "Unnamed Ability"
@export var cost: int = 0             # Сколько AP требует
@export var gcd: int = 0              # Сколько добавляет к глобальному КД
@export var damage: int = 0           # Урон, если есть
@export var pierce: int = 0           # Пробитие (если есть)
@export var effect_description: String = ""
@export var is_offensive: bool = true
@export var affects_gcd: bool = true
@export var icon: Texture             # Для отображения в UI (опционально)
@export var sound: AudioStream        # Звук способности (если есть)
@export var undone_btn_dis: bool = true
@export var stacks: int = 0



# Расширение: можно позже добавить callable-эффект или кастуемую сцену
# 📡 Применить эффект способности к цели (например, врагу)
func cast(caster: Node, target: Node) -> void:
	var modificated_damage = damage
	if not is_offensive:
		target = caster
		
	if name == "Ice Spear":
		var frost_effect = preload("res://effects/FrostEffect.gd").new()
		frost_effect.stacks = stacks
		target.add_effect(frost_effect)
	if name == "Shock Curse":
		var frost_effect = preload("res://effects/ShockEffect.gd").new()
		frost_effect.stacks = stacks
		target.add_effect(frost_effect)
	if name == "Shield":
		var frost_effect = preload("res://effects/ShieldEffect.gd").new()
		frost_effect.stacks = stacks
		frost_effect.shield_points = damage
		target.add_effect(frost_effect)
		
		
	if target.has_method("take_damage") and is_offensive:
		for effect in caster.effects:
			modificated_damage = effect.on_attack(self, modificated_damage)
		target.take_damage(modificated_damage, pierce)
	# Здесь можно добавить специфические эффекты по имени или флагу
	# Например, замедление, баф, дебафф и т.п.
	
func get_effect_description() -> String:
	var desc = effect_description
	desc = desc.replace("@damage", str(damage))
	desc = desc.replace("@cost", str(cost))
	desc = desc.replace("@stacks", str(stacks))
	desc = desc.replace("@pierce", str(pierce))
	# Можно добавить любые новые параметры
	return desc

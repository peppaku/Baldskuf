extends Node2D

@export var max_hp = 30
@export var hp: int = 30
@export var max_ap = 5
@export var ap = 5

@export var global_cooldown = 0

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var spell_info_pos = $SpellInfoPosition

# 📌 Навыки (простая заглушка)
@export var abilities: Array[Ability] = [
	preload("res://player/Abilities/fireball.tres"),
	preload("res://player/Abilities/ice_spear.tres"),
	preload("res://player/Abilities/shock_curse.tres"),
]

# 📡 Сигналы для UI
signal stats_updated(hp, ap, global_cooldown)

func _ready():
	ap = 5
	
func update_stats():
	#emit_signal("stats_updated", hp, ap, global_cooldown)
	var ui = get_parent().get_node("BattleUI")
	if ui:
		ui.update_ui()
	
func spend_ap(amount: int) -> bool:
	if ap >= amount:
		ap -= amount
		TurnManager.on_ap_spent(amount)
		update_stats()
		return true
	return false
	
func gcd_change(amount: int):
	global_cooldown+=amount
	if global_cooldown<=0:
		global_cooldown=0

func reset_turn():
	for effect in effects:
		effect.on_turn_start(self)
	ap = max_ap
	update_stats()

func use_ability(index: int, target: Node) -> void:
	if index < 0 or index >= abilities.size():
		push_error("Неверный индекс способности")
		return
		
	var ab: Ability = abilities[index]

	if ap < ab.cost:
		print("Недостаточно ОД для", ab.name)
		var message = "Недостаточно ОД для " + ab.name
		MousePopup.show_floating_text(message)
		return
	if global_cooldown>0 and ab.affects_gcd:
		print("Перезарядка способностей")
		var message = "Перезарядка способностей"
		MousePopup.show_floating_text(message)
		return
	
	spend_ap(ab.cost)
	gcd_change(ab.gcd)
	ab.cast(self, target)
	anim.play("hit")

	var msg = "%s: -%d AP" % [ab.name, ab.cost]
	if ab.gcd > 0:
		msg += "\nGCD: %d AP" % ab.gcd

	show_floating_text_near_character(msg, Color.ORANGE)

	print("Использовано: ", ab.name)
	print("-", ab.effect_description)
	update_stats()

func take_damage(amount: int, pierce: int = 0):
	var popup = preload("res://damage_popup.tscn").instantiate()

	
	var modificated_damage = amount
	for effect in effects:
		modificated_damage = effect.on_damage(self, modificated_damage)
	
	popup.position = global_position + Vector2(0, -120)  # Над врагом
	popup.show_damage(modificated_damage)
	get_tree().current_scene.add_child(popup)
	
	hp -= modificated_damage
	
	update_stats()
	play_hit_animation()
	if hp<=0:
		print("smert")
		MousePopup.show_floating_text("Smert")
		get_tree().quit()
	if hp>max_hp:
		hp = max_hp
		

func play_hit_animation():
	var tween = create_tween()
	var sprite = $Sprite2D
	tween.tween_property(sprite, "modulate", Color(1, 0.2, 0.2), 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)

func show_floating_text_near_character(text: String, color: Color = Color.WHITE):
	var floating_text_scene = preload("res://UI/FloatingText.tscn")
	var floating_text = floating_text_scene.instantiate()
	get_parent().add_child(floating_text)
	floating_text.position = spell_info_pos.global_position # немного выше персонажа
	floating_text.show_text(text, color)







var effects: Array[Resource] = []

func add_effect(effect: Resource):
	# По желанию: если эффект уже есть — увеличь стаки/апдейти
	effects.append(effect)
	effect.on_apply(self)
	
func add_effect_overlay(texture_path: String, name: String, alpha := 0.7):
	if has_node(name):
		return
	var overlay = Sprite2D.new()
	
	overlay.texture = load(texture_path)
	overlay.modulate.a = alpha
	overlay.name = name
	overlay.position = Vector2.ZERO
	overlay.z_index = 100
	overlay.apply_scale(Vector2(0.2,0.2))
	add_child(overlay)
	

func remove_effect_overlay(name: String):
	if has_node(name):
		get_node(name).queue_free()

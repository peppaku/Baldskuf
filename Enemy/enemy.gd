extends Area2D


@export var texture: Texture
@onready var sprite := $Sprite2D
@onready var hp_bar := $HP_bar
@onready var hp_label := $HealthLabel
@onready var wait_hit_timer = $WaitBeforeHitTimer
@onready var anim = $Sprite2D/AnimationPlayer
@onready var spell_info_pos = $SpellInfoPosition


@export var enemy_type: EnemyType
var hp: int = 1
var max_hp: int = 1

@export var global_cooldown = 0
@export var max_ap = 2
@export var ap = 2

var enemy_skip_turn = false

signal enemy_selected(enemy)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("enemy_selected", self)



func update_hp_label():
	hp_label.text = "❤️%d / %d" % [hp, max_hp]

func _ready():
	connect("input_event", Callable(self, "_on_input_event"))
	sprite.texture = enemy_type.texture
	max_hp = enemy_type.max_hp
	hp = max_hp
	ap = enemy_type.maximum_ap
	update_hp_label()
	

	# и т.д.

func take_damage(amount: int, pierce: int = 0):
	var popup = preload("res://damage_popup.tscn").instantiate()
	popup.position = global_position + Vector2(0, -320)  # Над врагом
	popup.show_damage(amount)
	get_tree().current_scene.add_child(popup)

	var modificated_damage = amount
	for effect in effects:
		modificated_damage = effect.on_damage(self, modificated_damage)


	hp = max(hp - modificated_damage, 0)
	play_hit_animation()
	update_hp_label()
	
	if hp == 0:
		queue_free()
		if enemy_type.is_boss:
			var victory = preload("res://victory_screen.tscn").instantiate()
			get_tree().current_scene.add_child(victory)

func enemy_use_ability(index: int, target: Node):
	if index < 0 or index >= enemy_type.abilities.size():
		return
	var ab: Ability = enemy_type.abilities[index]
	if ap < ab.cost:
		return
	if global_cooldown>0 and ab.affects_gcd:
		var msg = "You are lucky now, i am cannot cast - i am on the cooldown"
		self.show_floating_text_near_character(msg)
		return
		
	anim.play("hit")
	spend_ap(ab.cost)
	if ab.affects_gcd and ab.gcd > 0:
		gcd_change(ab.gcd)
	ab.cast(self, target)


	if is_instance_valid(target.spell_info_pos):
		for i in ab.cost:
			ap_fly_effect_launch(self.spell_info_pos.global_position, target.spell_info_pos.global_position - Vector2 (-60,-120)) #Vector2 (-60,-90) - смещение в сторону с AP. Да говно, но иначе придется раздувать строчку, искать чилдренов и т.дю
	var msg = "%s: -%d AP" % [ab.name, ab.cost]
	if ab.gcd > 0:
		msg += "\nGCD: %d AP" % ab.gcd
	show_floating_text_near_character(msg)
	

func spend_ap(amount: int) -> bool:
	if ap >= amount:
		ap -= amount
		TurnManager.on_ap_spent(amount)
		return true
	return false

func gcd_change(amount: int):
	global_cooldown+=amount
	if global_cooldown<=0:
		global_cooldown=0

func reset_turn():
	for effect in effects:
		effect.on_turn_start(self)
	ap =  enemy_type.maximum_ap

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

func ap_fly_effect_launch(start_ui_position, target_ui_position):
	var ap_effect_scene = preload("res://UI/APFlyEffect.tscn")
	var effect = ap_effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.fly_from_to(start_ui_position, target_ui_position)
	
	
	
	
	
	
	
	
	
	
	
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
	add_child(overlay)

func remove_effect_overlay(name: String):
	if has_node(name):
		get_node(name).queue_free()

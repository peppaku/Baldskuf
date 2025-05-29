extends Control

@onready var hp_label = $PlayerStatusPanel/HP
@onready var ap_label = $PlayerStatusPanel/"Action Points"
@onready var gcd_label = $PlayerStatusPanel/"Global CD"

@onready var hp_bar = $PlayerStatusPanel/HP_Bar
@onready var ap_bar = $PlayerStatusPanel/AP_Bar
@onready var gcd_bar = $PlayerStatusPanel/GCD_Bar

@onready var ability_panel = $AbilityPanel
@onready var end_turn_button = $EndTurnButton

@onready var next_room_button = $"NextRoom"
@onready var battle_count_label = $"BattleCount"

var selected_enemy: Node = null

func _ready():
	pass

func initialize():
	end_turn_button.pressed.connect(_on_EndTurnButton_pressed)
	next_room_button.pressed.connect(_on_NextRoomButton_pressed)
	create_ability_buttons()
	update_ui()

func get_resized_icon(texture: Texture2D, size: Vector2) -> Texture2D:
	if not is_instance_valid(texture):
		return null
	var img = texture.get_image()
	img.resize(int(size.x), int(size.y), Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(img)

func create_ability_buttons():
	# Удалим старые (на всякий случай)
	for child in ability_panel.get_children():
		child.queue_free()
	var player = TurnManager.player_ref
	for i in player.abilities.size():
		var ability = player.abilities[i]
		var btn = Button.new()
		#btn.text = ability.name
		btn.icon = get_resized_icon(ability.icon, Vector2(64, 64))
		btn.set_tooltip_text(ability.get_effect_description())
		btn.disabled = not (TurnManager.turn_state == TurnManager.TurnState.PLAYER)
		btn.visible = not ability.undone_btn_dis
		btn.pressed.connect(func(): _on_ability_pressed(i))
		ability_panel.add_child(btn)
		var tooltip_text = ">>>%s<<<\nAP: %d | Damage: %d | GCD: %d\n%s" % [
		ability.name,
		ability.cost,
		ability.damage,
		ability.gcd,
		ability.get_effect_description()
		]
		btn.set_tooltip_text(tooltip_text)

func _on_ability_pressed(index: int):
	var player = TurnManager.player_ref
	var target = selected_enemy  # если никто не выбран - цель — первый враг
	if is_instance_valid(target):
		player.use_ability(index, target)
	else:
		MousePopup.show_floating_text("Select Target")
	update_ui()

func _on_EndTurnButton_pressed():
	TurnManager.end_turn()
	var battle_scene = get_parent()
	if not battle_scene.are_enemies_alive():
		_on_NextRoomButton_pressed()
	update_ui()


func update_ui():
	var player = TurnManager.player_ref
	var player_turn = (TurnManager.turn_state == TurnManager.TurnState.PLAYER)

	hp_label.text = "HP ❤️: %d" % player.hp
	ap_label.text = "AP 💎: %d" % player.ap
	gcd_label.text = "GCD ⏳: %d" % player.global_cooldown
#	_set_icons(hp_bar, "❤️", player.hp)
#	_set_icons(ap_bar, "💎", player.ap)
#	_set_icons(gcd_bar, "⏳", player.global_cooldown)
	for i in ability_panel.get_child_count():
		var btn = ability_panel.get_child(i)
		btn.disabled = not player_turn  # ← Блокируем, если не ход игрока!
	end_turn_button.disabled = not player_turn


func _set_icons(container: HBoxContainer, icon_text: String, count: int):
	for child in container.get_children():
		child.queue_free()
	for i in count:
		var label = Label.new()
		label.text = icon_text
		label.add_theme_font_size_override("font_size", 24)
		container.add_child(label)

var enemy_list: Array = []

func _on_enemy_selected(enemy):
	selected_enemy = enemy
	enemy_list = get_tree().get_nodes_in_group("Enemies")
	print(enemy_list)
	for e in enemy_list:
		e.get_node("Sprite2D").modulate = Color.WHITE
	# Подсветить
	print("выбрана цель")
	enemy.get_node("Sprite2D").modulate = Color(2,2,2,1) # Жёлтая подсветка
	update_ui()

func  _on_NextRoomButton_pressed():
	var battle_scene = get_parent()
	if battle_scene.are_enemies_alive():
		# Можно вывести оповещение: "Сначала уничтожь всех врагов!"
		print("Сначала убей всех врагов!")
		MousePopup.show_floating_text("Сначала убей всех врагов!")
		return
	if battle_scene.has_method("battle_begin"):
		battle_scene.battle_begin()

extends Node2D

@export var available_enemy_types: Array[EnemyType]   # массив сцен врагов
@export var enemy_scene: PackedScene = preload("res://Enemy/Enemy.tscn")

@onready var anchors := [
	$EnemyAnchor1,
	$EnemyAnchor2,
	$EnemyAnchor3,
]
@onready var enemies_root := $EnemiesRoot
@onready var battle_ui = $BattleUI
@onready var player = $Player
@onready var mouse_popup = $BattleUI/MousePopup


@onready var temp_battle_count: int = 0

func temp_battle_counter():
	temp_battle_count+=1
	battle_ui.battle_count_label.text = str(temp_battle_count)

func _ready():
	battle_begin()
	
func pick_random_items(a: Array, n: int) -> Array:
	var result: Array = []
	for i in n:
		result.append(a[randi() % a.size()])
	return result
	
func battle_begin():
	temp_battle_counter()
	
	var pool = available_enemy_types
	if temp_battle_count <= 2:
		
		pool = []
		
		for et in available_enemy_types:
			if not et.is_boss:  
				pool.append(et)
				print(pool)
	
	var enemy_count = randi_range(1, anchors.size())
	var selected_types := pick_random_items(pool, enemy_count)
	var enemy_instances: Array = []

	for enemy in enemies_root.get_children():
		enemy.queue_free()

	for i in enemy_count:
		var enemy = enemy_scene.instantiate()
		enemy.enemy_type = selected_types[i]
		enemy.position = anchors[i].global_position
		enemies_root.add_child(enemy)
		#enemy_instances.append(enemy)
		enemy.add_to_group("Enemies")
	enemy_instances = get_tree().get_nodes_in_group("Enemies")
	TurnManager.setup(player, enemy_instances)
	battle_ui.initialize();
	for enemy in enemy_instances:
		enemy.connect("enemy_selected", Callable(battle_ui, "_on_enemy_selected"))

func are_enemies_alive() -> bool:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.hp > 0:
			return true
	return false

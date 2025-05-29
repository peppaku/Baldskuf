extends Node

enum TurnState { PLAYER, ENEMIES }
var turn_state = TurnState.PLAYER

var player_ref: Node
var enemy_refs: Array

func start_turn():
	if turn_state == TurnState.PLAYER:
		player_ref.reset_turn() #функция которая обнуляет АП
	elif turn_state == TurnState.ENEMIES:
		if enemy_refs.size() == 0:
			print("а нет никого")
		for enemy in enemy_refs:
			if enemy and is_instance_valid(enemy):
				enemy.reset_turn()
				enemy.wait_hit_timer.start(1)
				await enemy.wait_hit_timer.timeout
				if not enemy.enemy_skip_turn:
					enemy_take_turn(enemy)
				player_ref.update_stats()
		end_turn()

func end_turn():
	if turn_state == TurnState.PLAYER:
		turn_state = TurnState.ENEMIES
		for effect in player_ref.effects:
			effect.on_turn_end(player_ref)
		# Убрать истёкшие эффекты
		player_ref.effects = player_ref.effects.filter(func(e): return not e.is_expired())
	elif turn_state == TurnState.ENEMIES:
		turn_state = TurnState.PLAYER
		for enemy in enemy_refs:
		#	print()
			if is_instance_valid(enemy):
		#		break
				if enemy.enemy_skip_turn:
					enemy.enemy_skip_turn = false
				for effect in enemy.effects:
					effect.on_turn_end(enemy)
			# Убрать истёкшие эффекты
				enemy.effects = enemy.effects.filter(func(e): return not e.is_expired())
	
	player_ref.update_stats()
	start_turn()
	
func enemy_take_turn(enemy):
	# Рандомная атака по игроку
	player_ref.update_stats()
	var abilities = enemy.enemy_type.abilities
	if abilities.size() > 0:
		var ability_index = randi() % abilities.size()
		enemy.enemy_use_ability(ability_index, player_ref)

func setup(player, enemies):
	player_ref = player
	enemy_refs = enemies
	start_turn()

func on_ap_spent(amount: int):
	for enemy in enemy_refs:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_cooldown > 0:
			enemy.global_cooldown = max(enemy.global_cooldown - amount, 0)
	if player_ref.global_cooldown > 0:
		player_ref.global_cooldown = max(player_ref.global_cooldown - amount, 0)
	player_ref.update_stats()

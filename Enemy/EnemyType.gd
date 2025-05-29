extends Resource
class_name EnemyType

@export var name: String
@export var texture: Texture
@export var max_hp: int = 10
@export var abilities: Array[Ability] = []
@export var is_boss: bool = false
@export var maximum_ap: int = 5

extends Control

var empty_hearts: TextureRect
var full_hearts: TextureRect
var player: CharacterBody2D
const heart_size: int = 16
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	var health_node: HealthComponent = player.get_node("Health")
	health_node.health_changed.connect(change_heart_amount)
	empty_hearts = $EmptyHearts
	full_hearts = $FullHearts
	empty_hearts.size.x = health_node.max_health * heart_size
	full_hearts.size.x = health_node.current_health * heart_size
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_heart_amount(current: int, max: int):
	empty_hearts.size.x = max * heart_size
	full_hearts.size.x = current * heart_size

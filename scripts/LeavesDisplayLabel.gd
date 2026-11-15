extends Label

var player: CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "0"
	player = get_tree().get_first_node_in_group("Player")
	player.get_node("Leaves").leaves_changed.connect(update_leaves)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_leaves(new_amount: int):
	text = str(new_amount)

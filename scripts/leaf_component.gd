extends Node

class_name LeafComponent

@export var initial_leaves: int = 0
@export var time_added: int = 5
signal leaves_changed(current: int)
var leaves: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	leaves = initial_leaves

func add_leaves(amount: int):
	leaves += amount
	leaves_changed.emit(leaves)
	
func remove_leaves(amount: int) -> bool:
	"""Returns True if operation succeeds, otherwise false."""
	if (leaves - amount) < 0:
		return false
	leaves -= amount
	leaves_changed.emit(leaves)
	return true

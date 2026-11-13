extends Node

class_name HealthCompoenent

@export var max_health: int = 5
var current_health: int

signal health_changed(current: int, max: int)
signal died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health

func take_damage(amount: int):
	current_health -= amount
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		die()

func die():
	current_health = 0
	died.emit()

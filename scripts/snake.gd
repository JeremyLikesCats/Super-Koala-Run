extends Area2D

@export var velocity = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += velocity * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "snake_left_barrier":
		velocity = abs(velocity)
	elif area.name == "snake_right_barrier":
		velocity = -abs(velocity)

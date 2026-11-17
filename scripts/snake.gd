extends Area2D

@export var velocity = 20
@export var knockback = Vector2(220, -200)
@export var damage = 1
@export var id = "snake"
@export var healthComponent: HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthComponent.died.connect(die)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += velocity * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "left_barrier":
		velocity = abs(velocity)
	elif area.name == "right_barrier":
		velocity = -abs(velocity)
	elif area.is_in_group("Enemy"):
		velocity = -velocity

func die():
	queue_free()
	

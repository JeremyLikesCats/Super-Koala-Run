extends Area2D

var SPEED = 100
var TIMEOUT_INTERVAL = 10.0
var timeout_time = 0.0

@export var knockback = Vector2(0, -200)
@export var damage = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeout_time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.y += SPEED * delta
	timeout_time += delta
	if timeout_time > TIMEOUT_INTERVAL:
		queue_free()

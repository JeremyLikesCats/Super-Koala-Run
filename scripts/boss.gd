extends Area2D

@export var player: CharacterBody2D

enum State {DIALOGUE, FIREBALL, LEAP}
var state: State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = State.DIALOGUE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.DIALOGUE:
			pass

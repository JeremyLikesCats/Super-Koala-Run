extends StaticBody2D

var cloud_disappear = false
@export var CloudSprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cloud_disappear:
		if CloudSprite.modulate.a > 0:
			CloudSprite.modulate.a -= delta
		
	else:
		if CloudSprite.modulate.a < 1:
			CloudSprite.modulate.a += delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		cloud_disappear = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		cloud_disappear = false

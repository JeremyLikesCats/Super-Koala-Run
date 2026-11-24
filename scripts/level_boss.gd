extends Node2D

var MAP_WIDTH: int

@export var meteor_scene: PackedScene
const METEOR_HEIGHT: int = -100

@export var door_node: Area2D

@export var boss_node: Area2D

@export var dialogue_node: Control
var dialogue_box: AnimationPlayer
var dialogue_label: Label
var dialogue_character: AnimationPlayer

@export var fade_away_player: AnimationPlayer

@export var boss_fight_initial_position_node: Node2D

enum State {INITIAL, DIALOGUE, STAGE_1, STAGE_2}
var state: State

var dialogue_stage: int = 0

var dialogues = [Dialogue.new("player", "What is this place??"), Dialogue.new("sedah", "Welcome to my dungeon of doom.", "box", false), Dialogue.new("sedah", "Prepare to meet your...", "box", false), Dialogue.new("sedah", "", "sedah_box_1", false)]


const METEOR_INTERVAL: float = 0.25
var meteor_timer: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_box = dialogue_node.get_node("Box/AnimationPlayer")
	dialogue_character = dialogue_node.get_node("Character/AnimationPlayer")
	dialogue_label = dialogue_node.get_node("Label")
	MAP_WIDTH = $TileMapLayer.get_used_rect().size.x * 16
	state = State.INITIAL
	door_node.get_node("Sprite").play("open")
	show_dialogue()
	show_dialogue_content(dialogues[dialogue_stage])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.INITIAL:
			dialogue_node.visible = false
		State.DIALOGUE:
			dialogue_node.visible = true
			if Input.is_action_just_pressed("dialogue_next"):
				dialogue_stage += 1
				if dialogue_stage >= len(dialogues):
					state = State.STAGE_1
					boss_node.start_fight()
					hide_dialogue()
				else:
					show_dialogue_content(dialogues[dialogue_stage])
		State.STAGE_1:
			match boss_node.state:
				boss_node.State.METEOR:
					meteor_timer += delta
					if meteor_timer >= METEOR_INTERVAL:
						var meteor_position = randi_range(0, MAP_WIDTH)
						for i in range(10):
							var meteor = meteor_scene.instantiate()
							add_child(meteor)
							meteor.global_position = Vector2(meteor_position, METEOR_HEIGHT)
						meteor_timer = 0

func show_dialogue_content(dialogue: Dialogue):
	dialogue_label.text = dialogue.text
	if dialogue.left_side == true:
		dialogue_character.play(dialogue.character_id + "_left")
		dialogue_box.play(dialogue.box_id + "_left")
	else:
		dialogue_character.play(dialogue.character_id + "_right")
		dialogue_box.play(dialogue.box_id + "_right")

func show_dialogue():
	dialogue_node.visible = true

func hide_dialogue():
	dialogue_node.visible = false


func _on_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.can_move = false
		body.velocity.x = 50
		
		door_node.get_node("Sprite").play("closing")
		fade_away_player.play("fade_to_black")
		
		await fade_away_player.animation_finished
		body.velocity.x = 10		
		
		body.get_node("Camera2D").limit_left = -64
		body.get_node("Camera2D").limit_right = 448
		body.position = boss_fight_initial_position_node.position
		body.can_move = true
		
		fade_away_player.play("fade_in")
		await fade_away_player.animation_finished
		state = State.DIALOGUE

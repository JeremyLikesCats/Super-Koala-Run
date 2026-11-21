extends Node2D

@export var dialogue_node: Control
var dialogue_box: AnimationPlayer
var dialogue_label: Label
var dialogue_character: AnimationPlayer

enum State {DIALOGUE, STAGE_1, STAGE_2}
var state: State

var dialogue_stage: int = 0

var dialogues = [Dialogue.new("player", "What is this place??"), Dialogue.new("sedah", "Welcome to my dungeon of doom.", "box", false), Dialogue.new("sedah", "Prepare to meet your...", "box", false), Dialogue.new("sedah", "", "sedah_box_1", false)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_box = dialogue_node.get_node("Box/AnimationPlayer")
	dialogue_character = dialogue_node.get_node("Character/AnimationPlayer")
	dialogue_label = dialogue_node.get_node("Label")
	
	state = State.DIALOGUE
	show_dialogue()
	show_dialogue_content(dialogues[dialogue_stage])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.DIALOGUE:
			if Input.is_action_just_pressed("dialogue_next"):
				dialogue_stage += 1
				if dialogue_stage >= len(dialogues):
					state = State.STAGE_1
					hide_dialogue()
				else:
					show_dialogue_content(dialogues[dialogue_stage])
			

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

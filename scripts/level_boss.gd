extends Node2D

@export var dialogue_node: Control
var dialogue_box: TextureRect
var dialogue_label: Label
var dialogue_character: TextureRect

enum State {DIALOGUE, STAGE_1, STAGE_2}
var state: State

var dialogue_stage: int = 0

var dialogues = [Dialogue.new("player", "What is this place??"), Dialogue.new("sedah", "Welcome to my dungeon of doom."), Dialogue.new("sedah", "Prepare to meet your...", "box", false), Dialogue.new("sedah", "", "sedah_box_1", false)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_box = dialogue_node.get_node("Box")
	dialogue_character = dialogue_node.get_node("Character")
	dialogue_label = dialogue_node.get_node("Label")
	
	state = State.DIALOGUE
	show_dialogue(dialogues[dialogue_stage])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.DIALOGUE:
			pass

func show_dialogue(dialogue: Dialogue):
	dialogue_character.texture = load("res://assets/GUI/Dialogue/Characters/" + dialogue.character_id + ".png")
	dialogue_label.text = dialogue.text
	dialogue_box.texture = load("res://assets/GUI/Dialogue/Boxes/" + dialogue.box_id + ".png")

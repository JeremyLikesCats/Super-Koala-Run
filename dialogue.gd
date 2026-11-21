extends Node
class_name Dialogue

var character_id: String
var text: String
var box_id: String

var left_side: bool

# CHARACTER IDS
## player
## sedah

# BOX IDS
## box
## sedah_box_1 for the DESTINY thing

func _init(character_id: String, text: String, box_id: String = "box", left_side: bool = true) -> void:
	self.character_id = character_id
	self.text = text
	self.box_id = box_id
	self.left_side = left_side

extends Control

class_name BeatEventVisual

@onready var visual := $TextureRect

var result_color : Dictionary[RuleSet.EventResult, Color] =  {
	RuleSet.EventResult.PERFECT : Color.GREEN,
	RuleSet.EventResult.GOOD : Color.DARK_GREEN,
	RuleSet.EventResult.MISSED : Color.RED
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func show_result(result : RuleSet.EventResult):
	modulate = result_color.get(result)

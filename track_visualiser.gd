@tool
extends Control



func _ready() -> void:
	set_process(!Engine.is_editor_hint())

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		init_nodes()
	
func init_nodes():
	
	pass

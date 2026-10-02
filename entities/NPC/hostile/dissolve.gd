extends MeshInstance3D

class_name Dissolvable

@export var time_to_dissolve : float = 1
var dissolve_progress : float = 0

var dissolve_started : bool = false

signal dissolve_finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if dissolve_started:
		dissolve_progress += delta * time_to_dissolve
		material_override.set_shader_parameter("t", dissolve_progress)
		
		if dissolve_progress >= time_to_dissolve:
			dissolve_started = false
			dissolve_finished.emit()

func dissolve(impact_pos : Vector3):
	material_override.set_shader_parameter("impact_position", impact_pos)
	dissolve_started = true

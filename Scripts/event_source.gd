extends Node

#TODO is this the best approach?

# an event source will send out BeatEvent(s) to be responded to by the player or world

var events : Dictionary[float, BeatEvent]

var status : RuleSet.WindowStatus

var is_overlapping : bool = false

@onready var mesh : MeshInstance3D = $Mesh

# the beats that are queued up
@export var beat_timings : Array[float]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh.get_active_material(0).albedo_color = Color.BLACK
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	if is_overlapping && events.is_empty():
		var offset : float = 0
		for timing in beat_timings:
			offset += timing
			queue_event(offset)
	
func process_beat_event(event : BeatEvent, result : RuleSet.EventResult):
	print("processing beat event, result: ",  RuleSet.EventResult.keys()[result])
	events.erase(event.beat)
	
	if events.is_empty():
		queue_free()
		set_process(false)
	
func process_status_update(event : BeatEvent, new_status: RuleSet.WindowStatus):
	var color := RuleSet.timing_feedback_color[new_status]
	mesh.get_active_material(0).albedo_color = color

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	is_overlapping = true

func _on_area_3d_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	is_overlapping = false
	
	
func queue_event(beat_offset : float):
	var event : BeatEvent = Conductor.add_event_to_track(beat_offset)
	if !event:
		return
	event.result.connect(process_beat_event)
	event.update.connect(process_status_update)
	events.get_or_add(event.beat, event)

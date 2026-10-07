extends Node

class_name EventSource

#TODO is this the best approach?

# an event source will send out BeatEvent(s) to be responded to by the player or world

var events : Dictionary[float, BeatEvent]

var status : RuleSet.WindowStatus

var is_active : bool = false

@export var mesh : MeshInstance3D

# the beats that are queued up
@export var beat_combo : BeatCombo
	
func process_beat_event(event : BeatEvent, result : RuleSet.EventResult):
	print("processing beat event, result: ",  RuleSet.EventResult.keys()[result])
	events.erase(event.beat)
	
func process_status_update(_event : BeatEvent, new_status: RuleSet.WindowStatus):
	var color := RuleSet.timing_feedback_color[new_status]
	var material := mesh.get_active_material(0)
	if material is StandardMaterial3D:
		material.albedo_color = color

func queue_events():
	for timing in beat_combo.timings.keys():
		var event : BeatEvent = Conductor.add_event_to_track(beat_combo.timings[timing], timing)
		if !event:
			#TODO: don't let this fail silently
			continue
		event.result.connect(process_beat_event)
		event.update.connect(process_status_update)
		events.get_or_add(event.beat, event)
	
	is_active = true

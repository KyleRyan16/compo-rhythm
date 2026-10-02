extends EventSource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Conductor._is_playing:
		queue_events()
	else: Conductor.song_started.connect(queue_events)
	
func process_beat_event(event : BeatEvent, result : RuleSet.EventResult):
	super(event, result)
	if events.is_empty():
		queue_free()

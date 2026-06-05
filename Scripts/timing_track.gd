extends Node

class_name TimingTrack

class BeatEvents :
	func UpdateStatus(new_status : RuleSet.WindowStatus):
		_status = new_status
		for event in events:
			event.update.emit(event, _status)
	var _status : RuleSet.WindowStatus = RuleSet.WindowStatus.CLOSED
	var events : Array[BeatEvent] = []

# all events that have been queued up [time][events]
var queued_events : Dictionary[float, BeatEvents]

# The timing track is an updatable list of ACTIVE beat events
func add_event(event: BeatEvent):
	queued_events.get_or_add(event.beat, BeatEvents.new())
	queued_events[event.beat].events.append(event)

func attempt_events(current_beat : float):
	for timestamp in queued_events:
		if queued_events[timestamp]._status != RuleSet.WindowStatus.OPEN:
			return
			
		var timing_result := get_timing_result(current_beat, timestamp)
		for beat_event in queued_events.get(timestamp).events:
			beat_event.result.emit(beat_event, timing_result)
			queued_events.erase(timestamp)

func process_beat(current_beat : float):
	for event_beat in queued_events:
		
		var time_diff_ms : float = get_time_diff_ms(current_beat, event_beat)
		var new_status := get_beat_status_from_ms(time_diff_ms)
		
		if queued_events[event_beat]._status == new_status:
			continue
		
		queued_events[event_beat].UpdateStatus(new_status)
		if (new_status == RuleSet.WindowStatus.CLOSED && time_diff_ms > 0):
			for event in queued_events[event_beat].events:
				event.result.emit(event, RuleSet.EventResult.MISSED)
				queued_events.erase(event_beat)
		

func get_timing_result(current_beat : float, event_beat : float) -> RuleSet.EventResult:
	var time_diff_ms : float = abs(get_time_diff_ms(current_beat, event_beat))
	print(time_diff_ms)
	for timing_window in RuleSet.timing_windows_ms:
		if time_diff_ms <= timing_window:
			return RuleSet.timing_windows_ms[timing_window]
			
	return RuleSet.EventResult.MAX

func get_beat_status(current_beat : float, event_beat : float) -> RuleSet.WindowStatus:
	var time_diff_ms : float = get_time_diff_ms(current_beat, event_beat)
	return get_beat_status_from_ms(time_diff_ms)

	
func get_beat_status_from_ms(time_diff_ms : float) -> RuleSet.WindowStatus:
	if abs(time_diff_ms) <= RuleSet.window_open_ms:
		return RuleSet.WindowStatus.OPEN
	
	# approaching is from one direction
	if time_diff_ms <= 0 && abs(time_diff_ms) <= RuleSet.window_approaching_ms:
		return RuleSet.WindowStatus.APPROACHING
		
	return RuleSet.WindowStatus.CLOSED
	
	
func get_time_diff_ms(current_beat : float, event_beat: float):
	return Conductor.get_beat_time(current_beat - event_beat) * 1000

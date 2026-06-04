extends RefCounted

class_name BeatEvent

signal result(event : BeatEvent, result : RuleSet.EventResult)
signal update(event : BeatEvent, status : RuleSet.WindowStatus)

# The when of this events validity, in practice it is this +- the timing window
var beat : float = -1

static func create(beat: float) -> BeatEvent:
	var instance : BeatEvent = BeatEvent.new()
	instance.beat = beat
	return instance

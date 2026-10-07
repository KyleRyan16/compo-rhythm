extends Resource

class_name BeatEvent

signal result(event : BeatEvent, result : RuleSet.EventResult)
signal update(event : BeatEvent, status : RuleSet.WindowStatus)

# The when of this events validity, in practice it is this +- the timing window
@export var beat : float = -1
var spec : BeatEventSpec = null

static func create(spec : BeatEventSpec, beat: float) -> BeatEvent:
	var instance : BeatEvent = BeatEvent.new()
	instance.beat = beat
	instance.spec = spec
	return instance
	
class event_spec:
	var is_vulnerable : bool = false

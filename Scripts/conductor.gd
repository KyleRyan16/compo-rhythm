extends AudioStreamPlayer

var bpm : float = 60
var beats_per_bar : int = 4

# Tracking the beat
var song_position_in_beats = 1
var sec_per_beat = 60.0 / bpm
var last_reported_beat = 0
var measure = 1

var current_beat_cached : float = 0

# System time state
var _song_time_begin: float = 0
var _song_time_system: float = 0

func _ready():
	_song_time_begin = (Time.get_ticks_usec() / 1000000.0)
	metronome.start()
	print("Current Beat: ", current_beat_cached)

func _process(delta: float) -> void:
	# Calculate the song time using the system clock at render rate. This
	# value is very stable, but can drift from the playing audio due to pausing,
	# stuttering, etc.
	_song_time_system = (Time.get_ticks_usec() / 1000000.0) - _song_time_begin
	_song_time_system *= pitch_scale
	
	var current_beat = floor(get_current_beat())
	if current_beat_cached != current_beat:
		current_beat_cached = current_beat
		print("Current Beat: ", current_beat_cached)
		
	process_track()

# Filtered time state
var _filter: OneEuroFilter
var _filtered_audio_system_delta: float = 0

# Determining how close to the beat an event is
var closest = 0
var time_off_beat = 0.0

@onready var timing_track : TimingTrack = $TimingTrack
@onready var metronome : Metronome = $Metronome


## Returns the duration of one beat (in seconds).
func get_beat_duration() -> float:
	return 60 / bpm
	
func get_current_beat() -> float:
	var song_time := _song_time_system + _filtered_audio_system_delta
	return song_time / get_beat_duration()
	
func get_beat_time(beat : float) -> float:
	return beat * get_beat_duration()

func add_event_to_track(next_beat_offset : float) -> BeatEvent:
	var event : BeatEvent = BeatEvent.create(ceil(get_current_beat()) + next_beat_offset)
	timing_track.add_event(event)
	return event
	
func attempt_events():
	timing_track.attempt_events(get_current_beat())
	
func process_track():
	timing_track.process_beat(get_current_beat())

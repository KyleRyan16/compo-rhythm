extends Node3D

#a place for some quick tests

var weak_ref : RefCounted = null
var strong_ref : RefCounted = null
var strong_ref2 : RefCounted = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	strong_ref = RefCounted.new()
	weak_ref = weakref(strong_ref2)

	weak_ref.get_ref()
	print(weak_ref.get_ref())

	strong_ref = null
	await get_tree().create_timer(0).timeout
	print(weak_ref.get_ref())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

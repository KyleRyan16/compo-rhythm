extends Node

class_name AimSolver

@onready var camera : Camera3D = $"../../../Camera3D"

class TrajectoryResult:
	var movements : Array[Vector3] 
	var bounces : int = 0
	static func Init(max_ricochets : int) -> TrajectoryResult:
		var result = TrajectoryResult.new()
		result.bounces = max_ricochets
		return result
	
	
func get_mouse_aim_position(from : Vector3) -> Vector3:
	
	var mouse_pos = get_viewport().get_mouse_position()
	
	var mouse_from := camera.project_ray_origin(mouse_pos)
	var mouse_dir := camera.project_ray_normal(mouse_pos)
	var length_from_mouse = (from.y - mouse_from.y) / mouse_dir.y
	
	return mouse_from + mouse_dir * length_from_mouse

static func find_blocking(entity : Node3D, from : Vector3, to : Vector3, debug_draw : bool = false) -> Vector3:
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude.append(entity)
	query.collision_mask = 1 << 1
	
	
	
	var space_state = entity.get_world_3d().direct_space_state
	
	var result := space_state.intersect_ray(query)
	
	if !result || !result.collider:
		if debug_draw: DebugDraw3D.draw_arrow(from, to, Color.YELLOW, 0.25, true)
		return to
	if debug_draw: DebugDraw3D.draw_arrow(from, result.position, Color.YELLOW, 0.25, true)
	return result.position


static func simulate_trajectory(entity : Node3D, from : Vector3, direction : Vector3, distance : float, trajectory_result : TrajectoryResult):
	
	var current_position = from
	
	var space_state = entity.get_world_3d().direct_space_state

	while distance > 0 && trajectory_result.bounces >= 0:
		
		var end = current_position + direction * distance
		var query = PhysicsRayQueryParameters3D.create(current_position, end)
		query.exclude.append(entity)
		query.collision_mask = 1 << 1
		
		var result := space_state.intersect_ray(query)
		
		if !result || !result.collider:
			trajectory_result.movements.append(direction * distance)
			return trajectory_result.movements
		
		var distance_moved : float = (result.position - current_position).length()
		trajectory_result.movements.append(direction * distance_moved)
		
		direction = direction.bounce(result.normal)
		
		distance -= distance_moved
		current_position = result.position
		
		trajectory_result.bounces -= 1

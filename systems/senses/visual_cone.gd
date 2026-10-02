extends MeshInstance3D

class_name VisualCone

@export var subdivisions : int = 12

@export var debug_visualize_vertices : bool = false

func get_point_position(radius : float, angle_rad : float) -> Vector3:
	return Vector3(
		radius * sin(angle_rad),
		0,
		radius * -cos(angle_rad)
	)
	
func update_vision_field(fov: float, radius: float):
	
	var local_vertices : Array[Vector3]
	var step : float = deg_to_rad(fov / subdivisions)
	var rad : float = deg_to_rad(-fov / 2)

	for i in range(subdivisions + 1):
		var global_pos := global_position
	
		var vertex = get_point_position(radius, rad)
		var global_vertex : Vector3 = vertex.rotated(global_transform.basis.y, global_transform.basis.get_euler().y) + global_pos

		var center := Vector3.ZERO
		var global_center : Vector3 = center.rotated(global_transform.basis.y, global_transform.basis.get_euler().y) + global_pos
	
		vertex = (AimSolver.find_blocking(self, global_center, global_vertex) - global_pos).rotated(global_transform.basis.y, -global_transform.basis.get_euler().y)
		local_vertices.append(vertex)
		
		rad += step
		
	if (debug_visualize_vertices):
		for vertex in local_vertices:
			DebugDraw3D.draw_sphere(vertex.rotated(global_transform.basis.y, global_transform.basis.get_euler().y) + global_position, 0.1, Color.AQUAMARINE, 0.01)

	var shader_mat := material_override as ShaderMaterial
	shader_mat.set_shader_parameter("vertex_count", subdivisions + 1)
	shader_mat.set_shader_parameter("vertices", local_vertices)
	

func construct_vision_field(fov: float, radius: float):
	
	var surface := SurfaceTool.new()
	var step : float = deg_to_rad(fov / subdivisions)
	var rad : float = deg_to_rad(-fov / 2)
	
	var previous = get_point_position(radius, rad)
	var center := Vector3.ZERO
	var previous_uv : Vector2 = Vector2(0, previous.length() / radius)
	
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(subdivisions):
		rad += step
		var current : Vector3 = get_point_position(radius, rad)
		
		surface.set_uv(Vector2(0.5, 0))
		surface.add_vertex(center)
		surface.set_uv(previous_uv)
		surface.add_vertex(previous)
		
		previous_uv = Vector2(float(i) / (subdivisions -1), current.length() / radius)
		surface.set_uv(previous_uv)
		surface.add_vertex(current)
		previous = current
		
	mesh = surface.commit()
	
	var shader_mat := material_override as ShaderMaterial
	shader_mat.set_shader_parameter("fov", fov)
	update_vision_field(fov, radius)

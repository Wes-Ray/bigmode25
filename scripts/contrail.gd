extends GPUParticles3D


func brake() -> void:
	process_material.gravity = Vector3(0, 1, 0)
	amount_ratio = 0.5


func throttle() -> void:
	process_material.gravity = Vector3(0, 2, 0)
	draw_pass_1.surface_get_material(0).albedo_color = (Color(0.49, 0.99, 1.0, 1.0))
	amount_ratio = 1.


func boost() -> void:
	process_material.gravity = Vector3(0, 2, 0)
	draw_pass_1.surface_get_material(0).albedo_color = (Color.RED)
	amount_ratio = 1.


	

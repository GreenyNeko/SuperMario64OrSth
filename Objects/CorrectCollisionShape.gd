extends CollisionShape3D

func _enter_tree() -> void:
	var currScale = global_transform.basis.get_scale()
	print(currScale)
	if not shape is BoxShape3D:
		return
	var finalShape = BoxShape3D.new()
	print(shape.size)
	finalShape.size = shape.size * currScale
	shape = finalShape
	print(shape.size)

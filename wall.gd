@tool
extends Node3D

@export var wall_size: Vector3 = Vector3(2, 3, 0.2) :
	set(value):
		wall_size = value
		set_wall_size

func set_wall_size(value: Vector3) -> void:
	wall_size = value
	_update_wall()

func _update_wall():
	var mesh_instance: MeshInstance3D = $MeshInstance3D
	var collision_shape: CollisionShape3D = $StaticBody3D/CollisionShape3D

	if mesh_instance.mesh is BoxMesh:
		mesh_instance.mesh.size = wall_size

	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = wall_size

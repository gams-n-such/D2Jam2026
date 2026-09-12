@tool
class_name PgStone
extends StaticBody3D

@onready var mesh: MeshInstance3D = %Mesh

@export var surface: PgSurfaceResource

func _ready() -> void:
	if surface:
		mesh.set_surface_override_material(0, surface.material)
		physics_material_override = surface.phys_material

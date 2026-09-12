class_name PGCharacter
extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var stick_floor_ray_cast: RayCast3D = %StickFloorRayCast
@onready var pcam: PhantomCamera3D = %PhantomCamera3D

var _mouse_input : Vector2 = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Game.open_pause_menu()
	elif event.is_action_pressed("jump"):
		if stick_floor_ray_cast.is_colliding():
			var impulse := global_basis * Vector3.UP * jump_impulse
			apply_impulse(impulse, stick_floor_ray_cast.global_position - global_position)
			print(jump_impulse)
	if event is InputEventMouseMotion:
		var move := (event as InputEventMouseMotion).relative
		#_mouse_input += move.relative
		if move.length_squared() > 0.01:
			var impulse := global_basis * Vector3.UP * move.x * turn_sensitivity * -1.0
			apply_torque_impulse(impulse)
			var pcam_rotation_degrees: Vector3
			pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
			pcam_rotation_degrees.x -= move.y * turn_sensitivity
			pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, -80.0, 85.0)
			pcam_rotation_degrees.y -= move.x * turn_sensitivity
			pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, 0.0, 360.0)
			pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

@export var jump_impulse : float = 10.0
@export var rotation_input_force : float = 25.0
@export var turn_sensitivity : float = 0.05

func _physics_process(delta: float) -> void:
	var input_dir := JamUtils.get_move_input_dir_2d()
	if input_dir.length_squared() > 0.01:
		var input_torque := Vector3(input_dir.y, 0.0, -input_dir.x) * rotation_input_force
		input_torque = global_basis * input_torque
		print(input_dir, input_torque)
		apply_torque(input_torque)

#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#pass

func _on_stick_end_body_entered(body: Node) -> void:
	pass # Replace with function body.

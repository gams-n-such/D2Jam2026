class_name PGCharacter
extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Game.open_pause_menu()

@export var rotation_input_force : float = 15.0

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

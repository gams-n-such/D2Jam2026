class_name PGCharacter
extends RigidBody3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Game.player = self
	_show_hud()

func _exit_tree() -> void:
	_hide_hud()


func _process(delta: float) -> void:
	_process_camera(delta)
	var jump_pressed := Input.is_action_pressed("jump")
	if jump_pressed:
		start_jump_charging()
		_process_jump_charging(delta)
	else:
		jump()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Game.open_pause_menu()
		return
	if event is InputEventMouseMotion:
		var move := (event as InputEventMouseMotion).relative
		add_camera_input(move * mouse_camera_sensitivity)

@export var rotation_input_force : float = 30.0
@export var turn_force : float = 100.0

@export var camera_based_rotation : bool = true

func _physics_process(delta: float) -> void:
	var input_dir := JamUtils.get_move_input_dir_2d()
	var turn_input := Input.get_axis("turn_right", "turn_left")
	if input_dir.length_squared() > 0.01 or turn_input != 0.0:
		var input_torque := Vector3.ZERO
		if camera_based_rotation:
			input_torque = Vector3(input_dir.y, turn_input, -input_dir.x) * rotation_input_force
			input_torque = camera.global_basis * input_torque
		else:
			input_torque = Vector3(input_dir.y, 0.0, -input_dir.x) * rotation_input_force + Vector3.UP * turn_force * turn_input
			input_torque = global_basis * input_torque
		apply_torque(input_torque)

#region Camera

@onready var pcam: PhantomCamera3D = %PhantomCamera3D

@export var mouse_camera_sensitivity : float = 0.05
@export var gamepad_camera_sensitivity : float = 1.0
@onready var camera: Camera3D = %Camera

func _process_camera(delta: float) -> void:
	var camera_input := JamUtils.get_camera_input_dir()
	# See _unhandled_input for mouse camera
	add_camera_input(camera_input * gamepad_camera_sensitivity * delta)

func add_camera_input(input : Vector2) -> void:
	if input.length_squared() > 0.01:
		#var impulse := global_basis * Vector3.UP * move.x * turn_sensitivity * -1.0
		#apply_torque_impulse(impulse)
		var pcam_rotation_degrees: Vector3
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.x += input.y * -1.0
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, -80.0, 85.0)
		pcam_rotation_degrees.y += input.x * -1.0
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, 0.0, 360.0)
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)

#endregion

#region Jumoing

@onready var stick_floor_shape_cast: ShapeCast3D = %StickFloorShapeCast

@export var max_jump_impulse : float = 15.0
@export var jump_charge_time : float = 2.0
@export var jump_charge_curve : Curve
var _jump_charging : bool = false
## 0 to 1
var _jump_charge : float = 0.0
var jump_charge : float:
	get:
		return jump_charge_curve.sample(_jump_charge)

func start_jump_charging() -> void:
	if _jump_charging:
		return
	_jump_charge = 0.0
	_jump_charging = true

func _process_jump_charging(delta: float) -> void:
	if not _jump_charging or _jump_charge >= 1.0:
		return
	_jump_charge = clampf(_jump_charge + (delta / jump_charge_time), 0.0, 1.0)

func jump() -> void:
	if not _jump_charging:
		return
	if stick_floor_shape_cast.is_colliding():
		var jump_impulse := jump_charge * max_jump_impulse
		var impulse := global_basis * Vector3.UP * jump_impulse
		apply_impulse(impulse, stick_floor_shape_cast.global_position - global_position)
	_jump_charge = 0.0
	_jump_charging = false

#endregion

#region HUD

@export var hud_scene : PackedScene

func _show_hud() -> void:
	if hud_scene:
		var hud := hud_scene.instantiate() as Control
		Game.canvas_manager.set_layer_content(JamUtils.layer_ui_hud, hud)

func _hide_hud() -> void:
	Game.canvas_manager.clear_layer(JamUtils.layer_ui_hud)

#endregion

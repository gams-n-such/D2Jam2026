extends Control


@onready var charge_progress: TextureProgressBar = $ChargeProgress
var player : PGCharacter:
	get:
		return Game.player

@export var interp_speed : float = 2.0

func _process(delta: float) -> void:
	charge_progress.value = move_toward(charge_progress.value, player.jump_charge, interp_speed * delta)

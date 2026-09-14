extends Node3D



func _on_player_trigger_cube_body_entered(body: Node3D) -> void:
	Game.win()

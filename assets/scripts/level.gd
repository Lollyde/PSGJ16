extends Node2D


# Called when the node enters the scene tree for the first time.
func get_spawn() -> Vector2:
	return $spawn.global_position

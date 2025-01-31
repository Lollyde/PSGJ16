extends Area2D

var damage := 30

@onready var game_manager: Node = %GameManager

func _on_body_entered(body: Node2D) -> void:
	$AnimationPlayer.play("pickup")
	game_manager.pickup_enemy(damage)
	pass # Replace with function body.

func destroy():
	self.queue_free()

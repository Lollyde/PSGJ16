extends Area2D

@export var joy_amount := 50
@onready var game_manager: Node = %GameManager

func _on_body_entered(body: Node2D) -> void:
	print("joy_big")
	$AnimationPlayer.play("pickup")
	game_manager.pickup_joy(joy_amount)

func destroy():
	self.queue_free()

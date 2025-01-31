extends Area2D

var joy_amount := 10

func _on_body_entered(body: Node2D) -> void:
	$AnimationPlayer.play("pickup")
	body.get_manager().pickup_joy(joy_amount)

func destroy():
	self.queue_free()

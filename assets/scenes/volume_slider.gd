extends HSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_drag_ended(value_changed: bool) -> void:
	
	pass # Replace with function body.


func _on_value_changed(value: float) -> void:
	var adj = (value * 0.78) - 72
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), adj)
	pass # Replace with function body.

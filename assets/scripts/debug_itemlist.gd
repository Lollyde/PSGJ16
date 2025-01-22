extends ItemList

var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# WALKING, CRUTCHES, ROLLATOR, MANUAL_WHEELCHAIR, POWER_WHEELCHAIR
	self.auto_height = true
	add_item("WALKING", null, true)
	add_item("CRUTCHES", null, true)
	add_item("ROLLATOR", null, true)
	add_item("MANUAL_WHEELCHAIR", null, true)
	add_item("POWER_WHEELCHAIR", null, true)
	ensure_current_is_visible()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func change_movement_mode(index: int) -> void:
	get_node("../../Player/CharacterBody2D")._debug_change_mode(index)
	pass

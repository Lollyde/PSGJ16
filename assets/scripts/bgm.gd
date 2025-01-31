extends Node
@onready var title: AudioStreamPlayer2D = $Title
@onready var ambience: AudioStreamPlayer2D = $Ambience



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func play_title():
	ambience.stop()
	title.stop()
	title.play()
	
func play_ambient():
	ambience.stop()
	title.stop()
	ambience.play()

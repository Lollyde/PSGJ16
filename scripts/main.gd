extends Node

@export var mob_scene : PackedScene
var score

func _ready():
	pass

func _on_tchaff_hit() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()

func newGame():
	score = 0
	$tchaff.start($StartPos.position)
	$StartTimer.start()

func _on_mob_timer_timeout() -> void:
	pass # Replace with function body.


func _on_score_timer_timeout() -> void:
	score += 1


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()
	

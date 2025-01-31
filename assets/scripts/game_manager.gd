extends Node

@export var max_joy = 100.0
@export var max_spoons = 180.0

var joy = 0.0
var spoons = 180.0

@onready var hud: CanvasLayer = $"../HUD"

func _ready():
	hud.set_max_energy(max_spoons)
	hud.set_max_happy(max_joy)
	hud.set_energy(max_spoons)
	hud.set_happy(0)

func _on_spoons_timeout() -> void:
	spoons -= 1
	hud.set_energy(spoons)
	pass # Replace with function body.

func pickup_joy(val: int):
	joy += val
	hud.set_happy(joy)

func pickup_enemy(val: int):
	spoons -= val
	hud.set_energy(spoons)

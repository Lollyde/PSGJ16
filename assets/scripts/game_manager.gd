extends Node

@export var max_joy = 100.0
@export var max_spoons = 180.0

@onready var player: CharacterBody2D = %player

@onready var level_1: Node2D = $"../Level1"
@onready var level_2: Node2D = $"../Level2"
@onready var level_3: Node2D = $"../Level3"
@onready var level_4: Node2D = $"../Level4"
@onready var level_5: Node2D = $"../Level5"

var current_level = 1


var joy = 0.0
var spoons = 0.0

@onready var hud: CanvasLayer = $"../HUD"

func _ready():
	spoons = max_spoons
	print("max_spoons " + str(max_spoons))
	hud.set_max_energy(max_spoons)
	hud.set_max_happy(max_joy)
	hud.set_energy(max_spoons)
	hud.set_happy(0)
	player.global_position = level_1.get_spawn()
	level_1.visible = true
	level_2.set_process(false)
	level_3.set_process(false)
	level_4.set_process(false)
	level_5.set_process(false)
	
	
func loadlevel():
	spoons = max_spoons
	joy = 0
	level_1.set_process(false)
	level_2.set_process(false)
	level_3.set_process(false)
	level_4.set_process(false)
	level_5.set_process(false)
	level_1.visible = false
	level_2.visible = false
	level_3.visible = false
	level_4.visible = false
	level_5.visible = false
	player.change_mode(current_level)
	match current_level:
		1:
			level_1.visible = true
			level_1.set_process(true)
			player.global_position = level_1.get_spawn()
		2:
			level_2.visible = true
			level_2.set_process(true)
			player.global_position = level_2.get_spawn()
		3:
			level_3.visible = true
			level_3.set_process(true)
			player.global_position = level_3.get_spawn()
		4:
			level_4.visible = true
			level_4.set_process(true)
			player.global_position = level_4.get_spawn()
		5:
			level_5.visible = true
			level_5.set_process(true)
			player.global_position = level_5.get_spawn()

func _on_spoons_timeout() -> void:
	spoons -= 1
	print(spoons)
	hud.set_energy(spoons)
	if spoons == 0:
		loadlevel()
	pass # Replace with function body.

func pickup_joy(val: int):
	joy += val
	hud.set_happy(joy)
	if joy == max_joy:
		current_level += 1
		loadlevel()

func pickup_enemy(val: int):
	spoons -= val
	hud.set_energy(spoons)

func change_level(level: int):
	pass

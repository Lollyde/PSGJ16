extends Node

@export var hit_damage : int = 30

var happy_points : int = 100
var energy_points : int = 180

signal happy_update(happy_points:int)
signal energy_update(energy_points:int)

# every second, passively lose 1 energy 
# and check bar statuses

func _physics_process(_delta: float) -> void:
	passive_deplete()
	if happy_points >= 100:
		level_up()
	elif energy_points <= 0:
		reset_happy_bar()
	
func passive_deplete():
	energy_points -= 1
	energy_update.emit(energy_points)

# taking damage deals takes a chunk of energy, losing time

func take_damage():
	energy_points -= hit_damage

func collect_small_joy():
	pass
	happy_update.emit(happy_points)

func collect_big_joy():
	pass
	happy_update.emit(happy_points)
	
func level_up():
	pass
	
func reset_happy_bar():
	pass

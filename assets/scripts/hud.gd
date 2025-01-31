extends CanvasLayer
@onready var energy_bar: ProgressBar = $Bars/ProgressBars/energy_bar
@onready var happy_bar: ProgressBar = $Bars/ProgressBars/happy_bar
@onready var current_keys: Label = $Bars/InfoBar/current_keys
@onready var current_level: Label = $Bars/InfoBar/Panel/current_level

func set_energy(val: int):
	energy_bar.value = val
	
func set_max_energy(val: int):
	energy_bar.max_value = val

func set_happy(val: int):
	happy_bar.value = val
	
func set_max_happy(val: int):
	happy_bar.max_value = val

func set_keys(val: String):
	current_keys.text = val
	
func set_level(val: String):
	current_level.text = val

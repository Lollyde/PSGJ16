extends Panel

func update_happy_bar():
	$Bars/ProgressBars/happy_bar.set_value_no_signal(happy_points)
	
	
func update_energy_bar():
	$Bars/ProgressBars/energy_bar.set_value_no_signal(energy_points)

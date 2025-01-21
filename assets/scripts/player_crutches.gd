extends CharacterBody2D


@export var turn_degrees := 15
@export var offset_amount := 20

func _physics_process(delta: float) -> void:
	# basic idea: 
	# rotate the player a certain amount around a point offset from the center
	# depending on which button is pressed
	
	# im sure theres a better way to do this, but heres the plan:
	# move the character offset_amount to the right/left compared to self.rotation
	# rotate by turn_degrees amount
	# move back by offset_amount 
	
	self.velocity = Vector2.ZERO
	if Input.is_action_just_pressed("move_o"):
		self.move_left()
		self.rotation_degrees -= turn_degrees
		self.move_right()
	elif Input.is_action_just_pressed("move_q"):
		self.move_right()
		self.rotation_degrees += turn_degrees
		self.move_left()
	elif Input.is_action_just_pressed("move_l"):
		self.move_left()
		self.rotation_degrees += turn_degrees
		self.move_right()
	elif Input.is_action_just_pressed("move_a"):
		self.move_right()
		self.rotation_degrees -= turn_degrees
		self.move_left()
	move_and_slide()
	
func move_left():
	var left_vec = Vector2(-1, 0).rotated(self.rotation) * offset_amount
	self.translate(left_vec)
	
func move_right():
	var right_vec = Vector2(1, 0).rotated(self.rotation) * offset_amount
	self.translate(right_vec)

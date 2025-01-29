extends CharacterBody2D


@export var walking_speed := 400

@export var crutches_turn_degrees := 15
@export var crutches_offset_amount := 20
@export var rollator_speed := 200
@export var rollator_turn := 45
@export var manual_wheelchair_speed := 800
@export var manual_wheelchair_turn_degrees := 10
@export var manual_wheelchair_offset_amount := 20
@export var power_wheelchair_speed := 300
@export var power_wheelchair_turn = 90

enum move_state {WALKING, CRUTCHES, ROLLATOR, MANUAL_WHEELCHAIR, POWER_WHEELCHAIR}

var current_mode: move_state = move_state.WALKING

func _debug_change_mode(index: int):
	current_mode = index as move_state

func _physics_process(delta: float) -> void:
	match current_mode:
		move_state.WALKING:
			walking_movement(delta)
		move_state.CRUTCHES:
			crutches_movement(delta)
		move_state.ROLLATOR:
			rollator_movement(delta)
		move_state.MANUAL_WHEELCHAIR:
			self.rotate(PI / -2) #workaround, dont change
			manual_wheelchair_movement(delta)
			self.rotate(PI / 2) #workaround, dont change
		move_state.POWER_WHEELCHAIR:
			power_wheelchair_movement(delta)
			pass
	move_and_slide()

func walking_movement(delta: float):
	var vel = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		vel.x += 1
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
	if Input.is_action_pressed("move_down"):
		vel.y += 1
	if Input.is_action_pressed("move_up"):
		vel.y -= 1

	if vel.length() > 0:
		vel = vel.normalized() * walking_speed
		self.rotation = vel.rotated(PI/2).angle()
	
	position += vel * delta

func crutches_movement(_delta: float): 
	# basic idea: 
	# rotate the player a certain amount around a point offset from the center
	# depending on which button is pressed
	# im sure theres a better way to do this, but heres the plan:
	# move the character offset_amount to the right/left compared to self.rotation
	# rotate by turn_degrees amount
	# move back by offset_amount 
	
	self.velocity = Vector2.ZERO
	if Input.is_action_just_pressed("crutch_right_forward"):
		rotate_with_offset(-crutches_turn_degrees, false, crutches_offset_amount)
	elif Input.is_action_just_pressed("crutch_left_forward"):
		rotate_with_offset(crutches_turn_degrees, true, crutches_offset_amount)
	elif Input.is_action_just_pressed("crutch_right_backward"):
		rotate_with_offset(crutches_turn_degrees, false, crutches_offset_amount)
	elif Input.is_action_just_pressed("crutch_left_backward"):
		rotate_with_offset(-crutches_turn_degrees, true, crutches_offset_amount)

func rollator_movement(delta: float):
	
	var vel = Vector2.ZERO
	var rot = 0
	if Input.is_action_pressed("rollator_left_push"):
		if Input.is_action_pressed("rollator_right_push"):
			vel.y -= 1
		elif Input.is_action_pressed("rollator_right_pull"):
			rot += rollator_turn
	elif Input.is_action_pressed("rollator_left_pull"):
		if Input.is_action_pressed("rollator_right_pull"):
			vel.y += 1
		elif Input.is_action_pressed("rollator_right_push"):
			rot -= rollator_turn
			
	if rot != 0:
		self.rotation_degrees += rot * delta
	if vel.length() > 0:
		vel = vel.rotated(self.rotation).normalized() * rollator_speed
	
	position += vel * delta

func manual_wheelchair_movement(_delta: float):
	#self.velocity = Vector2.ZERO
	# gotta have an input for *both* sides!!
	if Input.is_action_just_pressed("wheelchair_left_forward"):
		if Input.is_action_pressed("wheelchair_right_forward"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * manual_wheelchair_speed
			pass
		elif Input.is_action_pressed("wheelchair_right_backward"):
			rotate_with_offset(manual_wheelchair_turn_degrees, true, manual_wheelchair_offset_amount)
			pass
	elif Input.is_action_just_pressed("wheelchair_left_backward"):
		if Input.is_action_pressed("wheelchair_right_forward"):
			rotate_with_offset(-manual_wheelchair_turn_degrees, true, manual_wheelchair_offset_amount)
			pass
		elif Input.is_action_pressed("wheelchair_right_backward"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * manual_wheelchair_speed * -1
			pass
	elif Input.is_action_just_pressed("wheelchair_right_forward"):
		if Input.is_action_pressed("wheelchair_left_forward"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * manual_wheelchair_speed
			pass
		elif Input.is_action_pressed("wheelchair_left_backward"):
			rotate_with_offset(-manual_wheelchair_turn_degrees, false, manual_wheelchair_offset_amount)
			pass
	elif Input.is_action_just_pressed("wheelchair_right_backward"):
		if Input.is_action_pressed("wheelchair_left_forward"):
			rotate_with_offset(manual_wheelchair_turn_degrees, false, manual_wheelchair_offset_amount)
			pass
		elif Input.is_action_pressed("wheelchair_left_backward"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * manual_wheelchair_speed * -1
			pass
	
	self.velocity *= 0.8
	if self.velocity.length() < 30:
		self.velocity = Vector2.ZERO

func power_wheelchair_movement(delta: float):
	# essentially fancy wasd tank controls
	var vel = Vector2.ZERO # exclusively for forward/backward
	var rot = 0
	if Input.is_action_pressed("pwr_forward"):
		vel.y -= 1
		if Input.is_action_pressed("pwr_forward_right"):
			rot += power_wheelchair_turn
		elif Input.is_action_pressed("pwr_forward_left"):
			rot -= power_wheelchair_turn
	elif Input.is_action_pressed("pwr_back"):
		vel.y += 1
		if Input.is_action_pressed("pwr_back_right"):
			rot -= power_wheelchair_turn
		elif Input.is_action_pressed("pwr_back_left"):
			rot += power_wheelchair_turn
	elif Input.is_action_pressed("pwr_rotate_left"):
		rot -= power_wheelchair_turn
	elif Input.is_action_pressed("pwr_rotate_right"):
		rot += power_wheelchair_turn
	
	# handle rotation changes before velocity changes
	if rot != 0:
		self.rotation_degrees += rot * delta
		
	vel = vel.rotated(self.rotation)
	
	if vel.length() > 0:
		# normalization not needed because the movement vector can only ever be of 1 or 0 length
		vel *= power_wheelchair_speed
		
	position += vel * delta

func rotate_with_offset(turn_degrees: float, offset_right: bool, offset: float):
	if offset_right:
		self.move_right(offset)
		self.rotation_degrees += turn_degrees
		self.move_left(offset)
	else:
		self.move_left(offset)
		self.rotation_degrees += turn_degrees
		self.move_right(offset)

func move_left(offset_amount: float):
	var left_vec = Vector2(-1, 0).rotated(self.rotation) * offset_amount
	self.translate(left_vec)
	
func move_right(offset_amount: float):
	var right_vec = Vector2(1, 0).rotated(self.rotation) * offset_amount
	self.translate(right_vec)

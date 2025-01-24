extends CharacterBody2D


@export var walking_speed := 400
@export var crutches_turn_degrees := 15
@export var crutches_offset_amount := 20
@export var rollator_speed := 300
@export var rollator_turn_degrees := 15
@export var rollator_offset_amount := 20

enum move_state {WALKING, CRUTCHES, ROLLATOR, MANUAL_WHEELCHAIR, POWER_WHEELCHAIR}

var current_mode: move_state = move_state.WALKING

func _debug_change_mode(index: int):
	current_mode = index

func _physics_process(delta: float) -> void:
	match current_mode:
		move_state.WALKING:
			walking_movement(delta)
		move_state.CRUTCHES:
			crutches_movement(delta)
		move_state.ROLLATOR:
			self.rotate(PI / -2) #workaround, dont change
			rollator_movement(delta)
			self.rotate(PI / 2) #workaround, dont change
		move_state.MANUAL_WHEELCHAIR:
			pass
		move_state.POWER_WHEELCHAIR:
			pass
	move_and_slide()

func walking_movement(delta: float):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * walking_speed
		self.rotation = velocity.rotated(PI/2).angle()
	
	position += velocity * delta

func crutches_movement(_delta: float): 
	# basic idea: 
	# rotate the player a certain amount around a point offset from the center
	# depending on which button is pressed
	# im sure theres a better way to do this, but heres the plan:
	# move the character offset_amount to the right/left compared to self.rotation
	# rotate by turn_degrees amount
	# move back by offset_amount 
	
	self.velocity = Vector2.ZERO
	if Input.is_action_just_pressed("move_o"):
		rotate_with_offset(-crutches_turn_degrees, false, crutches_offset_amount)
	elif Input.is_action_just_pressed("move_q"):
		rotate_with_offset(crutches_turn_degrees, true, crutches_offset_amount)
	elif Input.is_action_just_pressed("move_l"):
		rotate_with_offset(crutches_turn_degrees, false, crutches_offset_amount)
	elif Input.is_action_just_pressed("move_a"):
		rotate_with_offset(-crutches_turn_degrees, true, crutches_offset_amount)

func rollator_movement(_delta: float):
	#self.velocity = Vector2.ZERO
	# gotta have an input for *both* sides!!
	if Input.is_action_just_pressed("move_q"):
		if Input.is_action_pressed("move_o"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * rollator_speed
			pass
		elif Input.is_action_pressed("move_l"):
			rotate_with_offset(rollator_turn_degrees, true, rollator_offset_amount)
			pass
	elif Input.is_action_just_pressed("move_a"):
		if Input.is_action_pressed("move_o"):
			rotate_with_offset(-rollator_turn_degrees, true, rollator_offset_amount)
			pass
		elif Input.is_action_pressed("move_l"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * rollator_speed * -1
			pass
	elif Input.is_action_just_pressed("move_o"):
		if Input.is_action_pressed("move_q"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * rollator_speed
			pass
		elif Input.is_action_pressed("move_a"):
			rotate_with_offset(-rollator_turn_degrees, false, rollator_offset_amount)
			pass
	elif Input.is_action_just_pressed("move_l"):
		if Input.is_action_pressed("move_q"):
			rotate_with_offset(rollator_turn_degrees, false, rollator_offset_amount)
			pass
		elif Input.is_action_pressed("move_a"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * rollator_speed * -1
			pass
	
	self.velocity *= 0.8
	if self.velocity.length() < 30:
		self.velocity = Vector2.ZERO

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

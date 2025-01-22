extends CharacterBody2D


@export var turn_degrees := 15
@export var offset_amount := 20
@export var speed := 400

enum move_state {WALKING, CRUTCHES, ROLLATOR, MANUAL_WHEELCHAIR, POWER_WHEELCHAIR}

var current_mode: move_state = move_state.WALKING

func _physics_process(delta: float) -> void:
	
	match current_mode:
		move_state.WALKING:
			walking_movement(delta)
		move_state.CRUTCHES:
			crutches_movement(delta)
		move_state.ROLLATOR:
			pass
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
		velocity = velocity.normalized() * speed
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

func move_left():
	var left_vec = Vector2(-1, 0).rotated(self.rotation) * offset_amount
	self.translate(left_vec)
	
func move_right():
	var right_vec = Vector2(1, 0).rotated(self.rotation) * offset_amount
	self.translate(right_vec)

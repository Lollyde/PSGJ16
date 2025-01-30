extends CharacterBody2D

@export var walking_speed := 400
@export var crutches_turn_degrees := 15
@export var crutches_offset_amount := 20
@export var rollator_speed := 200
@export var rollator_turn := 45
@export var manual_wheelchair_speed := 400
@export var manual_speed_multiplier := 0.0
@export var manual_wheelchair_turn_degrees := 10
@export var manual_wheelchair_turn_request := 0.0
@export var manual_wheelchair_offset_amount := 20
@export var power_wheelchair_speed := 300
@export var power_wheelchair_turn := 90

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

enum move_state {WALKING, CRUTCHES, ROLLATOR, MANUAL_WHEELCHAIR, POWER_WHEELCHAIR}

var current_mode: move_state = move_state.WALKING
var last_manual_speed_multiplier := 0.0

func _debug_change_mode(index: int):
	current_mode = index as move_state
	print("switching to state: " + str(index as move_state))

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
		play_or_continue_animation("anim_walking_moving")
	else:
		play_or_continue_animation("anim_walking_idle")
	
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
			
			
	# handle animations seperately:
	if rot == 0 && vel.length() == 0:
		# no input
		play_or_continue_animation("anim_rollator_idle")
	elif rot != 0 && vel.length() == 0:
		# turn only
		if rot > 0:
			play_or_continue_animation("anim_rollator_turn_right")
		else:
			play_or_continue_animation("anim_rollator_turn_left")
	elif vel.length() > 0:
		# moving
		if vel.y < 0:
			play_or_continue_animation("anim_rollator_forward")
		else:
			play_or_continue_animation("anim_rollator_backward")
	
	
	if rot != 0:
		self.rotation_degrees += rot * delta
	if vel.length() > 0:
		vel = vel.rotated(self.rotation).normalized() * rollator_speed
	
	position += vel * delta

func reset_manual():
	sprite.play("anim_manual_idle")

func manual_wheelchair_movement(delta: float):
	# rewrite time!
	var req_forward = Input.is_action_pressed("wheelchair_left_forward") && Input.is_action_pressed("wheelchair_right_forward")
	var req_backward = Input.is_action_pressed("wheelchair_left_backward") && Input.is_action_pressed("wheelchair_right_backward")
	var req_turnright = Input.is_action_pressed("wheelchair_left_forward") && Input.is_action_pressed("wheelchair_right_backward")
	var req_turnleft = Input.is_action_pressed("wheelchair_left_backward") && Input.is_action_pressed("wheelchair_right_forward")
	var newInput = Input.is_action_just_pressed("wheelchair_left_forward") ||  Input.is_action_just_pressed("wheelchair_right_forward") || Input.is_action_just_pressed("wheelchair_left_backward") || Input.is_action_just_pressed("wheelchair_right_backward")
	
	if newInput:
		if req_forward:
			print("manual_forward")
			$AnimationPlayer.stop()
			$AnimationPlayer.play_with_capture("manual_forward")
		elif req_backward:
			print("manual_backward")
			$AnimationPlayer.stop()
			$AnimationPlayer.play_with_capture("manual_backward")
		elif req_turnright:
			print("manual_right")
			$AnimationPlayer.stop()
			$AnimationPlayer.play_with_capture("manual_right")
		elif req_turnleft:
			print("manual_left")
			$AnimationPlayer.stop()
			$AnimationPlayer.play_with_capture("manual_left")
	else:
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("manual_idle")
	self.rotation_degrees += manual_wheelchair_turn_request * delta * manual_wheelchair_turn_degrees
	self.position += Vector2.RIGHT.rotated(self.rotation).normalized() * delta * manual_speed_multiplier * manual_wheelchair_speed
		
	#if manual_speed_multiplier != 0:
		# print("requested speed multiplier: " + str(manual_speed_curve.sample(manual_speed_progress)))
	return
	
	#self.velocity = Vector2.ZERO
	# gotta have an input for *both* sides!!
	var rot = 0 # tracking for animation purposes
	var vel = 0 # tracking for animation purposes
	if Input.is_action_just_pressed("wheelchair_left_forward"):
		if Input.is_action_pressed("wheelchair_right_forward"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * manual_wheelchair_speed
			vel = 1
		elif Input.is_action_pressed("wheelchair_right_backward"):
			rotate_with_offset(manual_wheelchair_turn_degrees, true, manual_wheelchair_offset_amount)
			rot = 1
	elif Input.is_action_just_pressed("wheelchair_left_backward"):
		if Input.is_action_pressed("wheelchair_right_forward"):
			rotate_with_offset(-manual_wheelchair_turn_degrees, true, manual_wheelchair_offset_amount)
			rot = 1
		elif Input.is_action_pressed("wheelchair_right_backward"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * manual_wheelchair_speed * -1
			vel = -1
	elif Input.is_action_just_pressed("wheelchair_right_forward"):
		if Input.is_action_pressed("wheelchair_left_forward"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * manual_wheelchair_speed
			vel = 1
		elif Input.is_action_pressed("wheelchair_left_backward"):
			rotate_with_offset(-manual_wheelchair_turn_degrees, false, manual_wheelchair_offset_amount)
			rot = -1
	elif Input.is_action_just_pressed("wheelchair_right_backward"):
		if Input.is_action_pressed("wheelchair_left_forward"):
			rotate_with_offset(manual_wheelchair_turn_degrees, false, manual_wheelchair_offset_amount)
			rot = -1
		elif Input.is_action_pressed("wheelchair_left_backward"):
			self.velocity = Vector2.from_angle(self.rotation).normalized() * manual_wheelchair_speed * -1
			vel = -1
	
	if vel != 0:
		if vel > 0:
			play_or_continue_animation("anim_manual_forward")
		else: 
			play_or_continue_animation("anim_manual_backward")
	elif rot != 0:
		if rot > 0:
			play_or_continue_animation("anim_manual_turn_right")
		else:
			play_or_continue_animation("anim_manual_turn_left")
	else:
		play_or_continue_animation("anim_manual_idle")
	
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
	
	# handle animations before movement
	if rot != 0:
		if (rot > 0 && vel.y <= 0) || (rot < 0 && vel.y > 0): #need to swap rotation direction when going backwards
			play_or_continue_animation("anim_power_turn_right")
		else:
			play_or_continue_animation("anim_power_turn_left")
	elif vel.y != 0:
		if vel.y < 0:
			play_or_continue_animation("anim_power_forward")
		else:
			play_or_continue_animation("anim_power_backward")
	else:
		play_or_continue_animation("anim_power_idle")
	
	
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

func play_or_continue_animation(anim: String):
	if sprite.animation != anim:
		print("switching to anim: " + anim)
		sprite.play(anim)

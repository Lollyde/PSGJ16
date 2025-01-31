extends CharacterBody2D

@export var walking_speed := 400
@export var crutches_turn_degrees := 15
@export var crutches_speed := 300
@export var crutches_walking_turn := 20.0
@export var crutches_requested_speed := 0.0
@export var crutches_requested_turn := 0.0
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
var last_crutches_direction := 0
var crutches_currently_turning := false

func _debug_change_mode(index: int):
	print("switching to state: " + str(index as move_state))
	change_mode(index)
	
func change_mode(index: int):
	current_mode = index as move_state
	match current_mode:
		move_state.WALKING:
			sprite.play("anim_walking_idle")
		move_state.CRUTCHES:
			sprite.play("anim_crutch_idle")
		move_state.ROLLATOR:
			sprite.play("anim_rollator_idle")
		move_state.MANUAL_WHEELCHAIR:
			sprite.play("anim_manual_idle")
		move_state.POWER_WHEELCHAIR:
			sprite.play("anim_power_idle")

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

func crutches_movement(delta: float):
	if Input.is_action_just_pressed("crutch_right_forward"):
		if last_crutches_direction != 1:
			crutches_currently_turning = true
		else:
			crutches_currently_turning = false
		$AnimationPlayer.stop()
		$AnimationPlayer.play("crutches_right_forward")
		last_crutches_direction = 1
	elif Input.is_action_just_pressed("crutch_left_forward"):
		if last_crutches_direction != 1:
			crutches_currently_turning = true
		else:
			crutches_currently_turning = false
		$AnimationPlayer.stop()
		$AnimationPlayer.play("crutches_left_forward")
		last_crutches_direction = 1
	elif Input.is_action_just_pressed("crutch_right_backward"):
		if last_crutches_direction != -1:
			crutches_currently_turning = true
		else:
			crutches_currently_turning = false
		$AnimationPlayer.stop()
		$AnimationPlayer.play("crutches_right_backward")
		last_crutches_direction = -1
	elif Input.is_action_just_pressed("crutch_left_backward"):
		if last_crutches_direction != -1:
			crutches_currently_turning = true
		else:
			crutches_currently_turning = false
		$AnimationPlayer.stop()
		$AnimationPlayer.play("crutches_left_backward")	
		last_crutches_direction = -1
	
	var rotation_modifier = crutches_walking_turn
	if crutches_currently_turning:
		rotation_modifier *= 2
	self.rotation_degrees -= crutches_requested_turn * delta * rotation_modifier
	
	var vel = Vector2.UP.rotated(self.rotation).normalized()
	var speed_modifier = crutches_requested_speed * crutches_speed * delta
	if crutches_currently_turning or last_crutches_direction != 1:
		speed_modifier *= 0.2
	self.position += vel * speed_modifier
	
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

func manual_wheelchair_movement(delta: float):
	# rewrite time!
	var req_forward = Input.is_action_pressed("wheelchair_left_forward") && Input.is_action_pressed("wheelchair_right_forward")
	var req_backward = Input.is_action_pressed("wheelchair_left_backward") && Input.is_action_pressed("wheelchair_right_backward")
	var req_turnright = Input.is_action_pressed("wheelchair_left_forward") && Input.is_action_pressed("wheelchair_right_backward")
	var req_turnleft = Input.is_action_pressed("wheelchair_left_backward") && Input.is_action_pressed("wheelchair_right_forward")
	var newInput = Input.is_action_just_pressed("wheelchair_left_forward") ||  Input.is_action_just_pressed("wheelchair_right_forward") || Input.is_action_just_pressed("wheelchair_left_backward") || Input.is_action_just_pressed("wheelchair_right_backward")
	
	if newInput:
		if req_forward:
			$AnimationPlayer.stop()
			$AnimationPlayer.play_with_capture("manual_forward")
		elif req_backward:
			$AnimationPlayer.stop()
			$AnimationPlayer.play_with_capture("manual_backward")
		elif req_turnright:
			$AnimationPlayer.stop()
			$AnimationPlayer.play_with_capture("manual_right")
		elif req_turnleft:
			$AnimationPlayer.stop()
			$AnimationPlayer.play_with_capture("manual_left")
	else:
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("manual_idle")
	self.rotation_degrees += manual_wheelchair_turn_request * delta * manual_wheelchair_turn_degrees
	self.position += Vector2.RIGHT.rotated(self.rotation).normalized() * delta * manual_speed_multiplier * manual_wheelchair_speed

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

func play_or_continue_animation(anim: String):
	if sprite.animation != anim:
		#print("switching to anim: " + anim)
		sprite.play(anim)

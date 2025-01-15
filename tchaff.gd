extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

func _ready():
	screen_size = get_viewport_rect().size
	
func _process(delta):
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
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	$AnimatedSprite2D.rotation_degrees = 0 # always straighten up the creature before applying mathematics :3
	
	if velocity.y < 0 and velocity.x == 0: # if moving up and not going left/right
		$AnimatedSprite2D.animation = "wobble_up"
	elif velocity.y > 0 and velocity.x == 0: # if moving down and not going left/right 
			$AnimatedSprite2D.animation = "wobble_down"
	else:
		if velocity.x < 0: # if moving left
			$AnimatedSprite2D.animation = "wobble_left"
			if velocity.y > 0: # if also moving down
				$AnimatedSprite2D.rotation_degrees = -45
			elif velocity.y < 0: # else if also moving up
				$AnimatedSprite2D.rotation_degrees = +45
		elif velocity.x > 0: # if moving right
			$AnimatedSprite2D.animation = "wobble_right"
			if velocity.y > 0: # if also moving down
				$AnimatedSprite2D.rotation_degrees = +45
			elif velocity.y < 0: # else if moving up
				$AnimatedSprite2D.rotation_degrees = -45

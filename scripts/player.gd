extends CharacterBody2D

## Basic movement constants
const SPEED = 110.0
const FRICTION = 20.0
const JUMP_VELOCITY = -220.0

## States
var knocked_back: bool = false
var just_knocked_back: bool = false
var jumped: bool = false
var just_jumped: bool = false


## Coyote Time
const COYOTE_TIME_THRESHOLD = 0.06
var coyote_time_timer = 0
var coyote_can_jump = false # Activates only if you just got of an edge. 

## Hold to jump higher
const GRAVITY_REDUCE_FACTOR = 1/2.8
const JUMP_HOLD_TIME_THRESHOLD = 0.19
var jump_hold_timer = 0
var jump_holding = false # Only true during the jump holding time 

## Jump Buffering
const JUMP_BUFFERING_TIME_THRESHOLD = 0.15
var jump_buffering_timer = 0
var incrementing_jump_buffering_timer = false


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not knocked_back:
		# Basic movement
		detect_sideways_movement()
		
		# Jump detection
		detect_jumping()
		
		# Coyote time
		if not is_on_floor() and not jumped and not knocked_back:
			coyote_can_jump = true
		
		## While you can jump with coyote time, increment the timer and check if you can still jump
		if coyote_can_jump == true:
			coyote_time_timer += delta
			if coyote_time_timer > COYOTE_TIME_THRESHOLD:
				coyote_can_jump = false
				coyote_time_timer = 0
		
		# Jump Buffering
		if incrementing_jump_buffering_timer:
			jump_buffering_timer += delta

		if not is_on_floor():
			if Input.is_action_just_pressed("Jump"):
				jump_buffering_timer = 0
				incrementing_jump_buffering_timer = true
				
		detect_buffered_jumping()
				
		# Jump Holding Detection
		
		## Basic jump (floor jump)
		if Input.is_action_pressed("Jump"):
			if jump_holding:
				jump_hold_timer += delta
			
			if jump_hold_timer > JUMP_HOLD_TIME_THRESHOLD:
				jump_hold_timer = 0
				jump_holding = false
		else:
			jump_hold_timer = 0
			jump_holding = false
		
	# Gravity + Jump Holding
	if not is_on_floor():
		apply_gravity(delta)
	
	# Reset states
	if just_knocked_back:
		just_knocked_back = false
	else:
		if is_on_floor():
			knocked_back = false
			
	if just_jumped:
		just_jumped = false
	else:
		if is_on_floor():
			jumped = false
			
	move_and_slide()
	
func apply_gravity(delta):
	if jump_holding:
		velocity += get_gravity()/2.8 * delta
	else:
		velocity += get_gravity() * delta

func detect_sideways_movement():
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	
func detect_buffered_jumping():
	if is_on_floor():
		if jump_buffering_timer < JUMP_BUFFERING_TIME_THRESHOLD and incrementing_jump_buffering_timer:
			jump()

		jump_buffering_timer = 0
		incrementing_jump_buffering_timer = false

func detect_jumping():	
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() or coyote_can_jump:
			jump()

func jump():
	velocity.y = JUMP_VELOCITY
	
	## Allow jump holding mechanic to kick in
	jump_holding = true
	
	## Set jumped state to true
	jumped = true
	just_jumped = true

func knockback(knockback_velocity: Vector2):
	velocity = knockback_velocity
	knocked_back = true
	just_knocked_back = true

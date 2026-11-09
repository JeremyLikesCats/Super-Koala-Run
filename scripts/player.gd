extends CharacterBody2D


const SPEED = 200.0
const FRICTION = 50.0
const JUMP_VELOCITY = -250.0

# Coyote time!! for better feeling movement allows the player to have a window of time just after falling off a platform to jump
const COYOTE_TIME_THRESHOLD = 0.07
var coyote_time = 0

# Jump buffering - allows the user to jump just before landing for a few frames
const JUMP_BUFFERING_THRESHOLD = 0.3
var jump_buffering_time = JUMP_BUFFERING_THRESHOLD
var incrementing_jump_buffering_time = false

# Knockback
const KNOCKBACK_DURATION = 0.5
var knockback_velocity = Vector2.ZERO
const KNOCKBACK_RESISTANCE_Y = 20.0
const KNOCKBACK_RESISTANCE_X = 14.0
var knocked_back = false
var just_knocked_back = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if just_knocked_back:
			knocked_back = true
			just_knocked_back = false
		if coyote_time < COYOTE_TIME_THRESHOLD:
			coyote_time += delta
		velocity += get_gravity() * delta
		
	if is_on_floor():
		coyote_time = 0
		
		if jump_buffering_time < JUMP_BUFFERING_THRESHOLD:
			jump()
			
		if knocked_back == true:
			knockback_velocity.x = 0
			knocked_back = false
		
		jump_buffering_time = JUMP_BUFFERING_THRESHOLD
		incrementing_jump_buffering_time = false
		

	if incrementing_jump_buffering_time:
		jump_buffering_time += delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_able_to_jump():
		jump()
		
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffering_time = 0
		incrementing_jump_buffering_time = true
		print(jump_buffering_time)
		print(incrementing_jump_buffering_time)
	
	print(knocked_back)
	
	# Handle movement.
	var direction := Input.get_axis("Left", "Right")
	if direction and not knocked_back:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)

	knockback_velocity.y = move_toward(knockback_velocity.y, 0, KNOCKBACK_RESISTANCE_Y)
	knockback_velocity.x = move_toward(knockback_velocity.x, 0, KNOCKBACK_RESISTANCE_X)
	
	print(knockback_velocity)
	velocity += knockback_velocity
	move_and_slide()

func jump():
	velocity.y = JUMP_VELOCITY

func is_able_to_jump():
	if is_on_floor() or coyote_time < COYOTE_TIME_THRESHOLD:
		return true
	return false
		

func knockback(force_vector: Vector2):
	knockback_velocity += force_vector * KNOCKBACK_DURATION

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		# Mario-like enemy hit
		   # moving downward
		if velocity.y > 0 and position.y < area.global_position.y:
			velocity.y = 0
			knockback(Vector2(0, -220))
			area.queue_free()
		elif knocked_back == false:
			velocity.x = 0
			knockback(Vector2((area.velocity - velocity.x) * 1.4, -200))
			just_knocked_back = true

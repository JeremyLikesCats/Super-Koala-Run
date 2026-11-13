extends CharacterBody2D


const SPEED = 120.0
const FRICTION = 20.0
const JUMP_VELOCITY = -220.0
const BOUNCE_VELOCITY = -200.0

# Coyote time!! for better feeling movement allows the player to have a window of time just after falling off a platform to jump
const COYOTE_TIME_THRESHOLD = 0.07
var coyote_time = 0

# Jump buffering - allows the user to jump just before landing for a few frames
const JUMP_BUFFERING_THRESHOLD = 0.15
var jump_buffering_time = JUMP_BUFFERING_THRESHOLD
var incrementing_jump_buffering_time = false

# Knockback
var knocked_back = false
var just_knocked_back = false

# Hold to jump higher
const JUMP_WINDOW = 0.19
var jump_time = 0
var can_increase_jump_time = false

var health: HealthComponent

var leaves: LeafComponent

func _ready() -> void:
	health = $Health
	health.died.connect(die)
	
	leaves = $Leaves
	

func _physics_process(delta: float) -> void:
	
	
	
	# Add the gravity.
	if not is_on_floor():
		if coyote_time < COYOTE_TIME_THRESHOLD:
			coyote_time += delta
		if jump_time > JUMP_WINDOW or can_increase_jump_time == false:
			velocity += get_gravity() * delta
		else:
			velocity += get_gravity()/2.8 * delta
	
	if is_on_floor():
		jump_time = JUMP_WINDOW
		coyote_time = 0
		
		
		if just_knocked_back == false:
			knocked_back = false
		
		if just_knocked_back == true:
			just_knocked_back = false
		
		if jump_buffering_time < JUMP_BUFFERING_THRESHOLD:
			jump()
			
		jump_buffering_time = JUMP_BUFFERING_THRESHOLD
		incrementing_jump_buffering_time = false
		

	if incrementing_jump_buffering_time:
		jump_buffering_time += delta
	
	# Handle jump.
	# TODO: somehow implement so that if you hold jump you keepj umping?
	if Input.is_action_just_pressed("Jump") and is_able_to_jump():
		jump()
		can_increase_jump_time = true
		jump_time = 0
	
	
	
	if Input.is_action_just_pressed("Jump"):
		jump_buffering_time = 0
		incrementing_jump_buffering_time = true

	if Input.is_action_just_released("Jump") or jump_time >= JUMP_WINDOW:
		can_increase_jump_time = false
	
	if Input.is_action_pressed("Jump") and can_increase_jump_time == true:
		jump_time += delta
	
	
	# Handle movement.
	var direction := Input.get_axis("Left", "Right")
	if direction and not knocked_back:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	move_and_slide()
	if knocked_back:
		print(velocity.x)
func jump():
	if not knocked_back:
		velocity.y = JUMP_VELOCITY

func is_able_to_jump():
	if is_on_floor() or coyote_time < COYOTE_TIME_THRESHOLD:
		return true
	return false
		

func knockback(force_vector: Vector2):
	velocity = force_vector
	just_knocked_back = true
	knocked_back = true

func die():
	self.queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		# Mario-like enemy hit
		   # moving downward  # Above enemy                           # not in the state of being knocked back
		if velocity.y > 0 and position.y < area.global_position.y and knocked_back == false:
			velocity.y = BOUNCE_VELOCITY
			area.queue_free()
		elif knocked_back == false:
			knockback(Vector2(area.knockback.x * sign(position.x - area.global_position.x), area.knockback.y))
			health.take_damage(area.damage)
	elif area.is_in_group("Lava"):
		health.die()
	elif area.is_in_group("Collectible"):
		if area.type == "Leaf":
			leaves.add_leaves(area.value)
		area.queue_free()

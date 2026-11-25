extends CharacterBody2D

## Basic movement constants
const SPEED = 110.0
const FRICTION = 20.0
const JUMP_VELOCITY = -220.0
const BOUNCE_VELOCITY = -210.0
const KNOCKBACK_FRICTION = 18.0

## States
var knocked_back: bool = false
var just_knocked_back: bool = false
var jumped: bool = false
var just_jumped: bool = false
var bounced: bool = false
var just_bounced: bool = false

## Coyote Time
const COYOTE_TIME_THRESHOLD = 0.07
var coyote_time_timer = 0
var coyote_can_jump = false # Activates only if you just got of an edge. 

## Hold to jump higher
const GRAVITY_REDUCE_FACTOR = 1/2.8
const JUMP_HOLD_TIME_THRESHOLD = 0.23
var jump_hold_timer = 0
var jump_holding = false # Only true during the jump holding time 

## Jump Buffering
const JUMP_BUFFERING_TIME_THRESHOLD = 0.15
var jump_buffering_timer = 0
var incrementing_jump_buffering_timer = false

## Damage Cooldown
const DAMAGE_COOLDOWN = 1.0
var damage_cooldown_time = 0
var in_damage_cooldown = false

## Stats
@export var health: HealthComponent
@export var leaves: LeafComponent
@export var beginning: Node2D

var can_move = true

func _ready() -> void:
	load_data_from_globals()

func _physics_process(delta: float) -> void:
	if not knocked_back and can_move:
		# Basic movement
		detect_sideways_movement()
		
		# Jump detection
		detect_jumping()
		
		# Coyote time
		if not is_on_floor() and not jumped and not knocked_back and not bounced:
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
	
	if just_bounced:
		just_bounced = false
	else:
		if is_on_floor():
			bounced = false
	
	# Apply knockback horizontal friction
	if can_move:
		velocity.x = move_toward(velocity.x, 0, KNOCKBACK_FRICTION)
	
	# Damage Cooldown
	if in_damage_cooldown:
		damage_cooldown_time += delta
	
	if damage_cooldown_time > DAMAGE_COOLDOWN:
		in_damage_cooldown = false
		damage_cooldown_time = 0
	
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
		if velocity.x >= 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("stop")
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

func get_hit_by_enemy(enemy: Area2D):
	if not in_damage_cooldown:
		knockback(Vector2(enemy.knockback.x * sign(position.x - enemy.global_position.x), enemy.knockback.y))
		damage_cooldown_time = 0
		in_damage_cooldown = true
		health.take_damage(enemy.damage)
		jump_holding = false

## Saving and loading to globals across scenes
func save_data_to_globals():
	PlayerData.current_health = health.current_health
	PlayerData.max_health = health.max_health
	PlayerData.leaves = leaves.leaves
	
func load_data_from_globals():
	health.current_health = PlayerData.current_health
	health.max_health = PlayerData.max_health
	leaves.leaves = PlayerData.leaves

# COLLISIONS
func _on_area_entered(area: Area2D):
	if area.is_in_group("Enemy"):
		# Mario-like enemy hit
		if not knocked_back:
			if velocity.y > 0 and position.y < area.global_position.y:
				if area.id != "spiked_turtle":
					velocity.y = BOUNCE_VELOCITY
					area.healthComponent.take_damage(1)
					print(area.healthComponent.current_health)
					jump_holding = true
					bounced = true
				else:
					get_hit_by_enemy(area)
			else:
				get_hit_by_enemy(area)
	elif area.is_in_group("Lava"):
		position = beginning.position
		health.take_damage(2)
	elif area.is_in_group("Collectible"):
		if area.type == "Leaf":
			leaves.add_leaves(area.value)
		area.queue_free()
	elif area.is_in_group("Meteor"):
		get_hit_by_enemy(area)
	

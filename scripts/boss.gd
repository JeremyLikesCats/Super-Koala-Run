extends Area2D

const MOVE_TOWARD_PLAYER_SPEED = 150

@export var player: CharacterBody2D
@export var boss_bricks: StaticBody2D
var boss_bricks_animation_player: AnimationPlayer

@export var knockback = Vector2(220, -200)
@export var damage = 1
@export var healthComponent: HealthComponent
var id = "sedah"

var animation_player: AnimationPlayer

var raycast: RayCast2D
var warning_line: Line2D
const WARNING_LINE_LENGTH = 64

enum State {NONE, METEOR, LEAPING_START, LEAPING_MIDDLE, LEAPING_WARNING, LEAPING_FALLING, LEAPING_END}
var state: State

const METEOR_TIME = 15.0
var meteor_timer = 0.0

const LEAP_TIME = 4.0
const LEAP_WARNING_TIME = 1.0
var leap_timer = 0.0

var initial_run: bool

@export var cracked_ground: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = State.NONE
	raycast = $RayCast2D
	raycast.add_exception(player)
	warning_line = $WarningLine
	warning_line.visible = false
	warning_line.points = [Vector2.ZERO, Vector2.ZERO]
	animation_player = $AnimationPlayer
	boss_bricks_animation_player = boss_bricks.get_node("AnimationPlayer")
	initial_run = true
	
func start_fight():
	state = State.LEAPING_START
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.NONE:
			pass
		State.METEOR:
			
			meteor_timer += delta
			if meteor_timer >= METEOR_TIME:
				state = State.LEAPING_START
				meteor_timer = 0
		State.LEAPING_START:
			$AnimatedSprite2D.play("lose_fire")
			await $AnimatedSprite2D.animation_finished
			if initial_run == false:
				boss_bricks_animation_player.play("fall")
				cracked_ground.play("uncrack")
			else:
				boss_bricks_animation_player.play("invisible")
			animation_player.play("LEAPING_START")
			state = State.LEAPING_MIDDLE
			warning_line.visible = true
		State.LEAPING_MIDDLE:
			$AnimatedSprite2D.play("no_fire")
			if not animation_player.is_playing():
				position.x = move_toward(position.x, player.global_position.x, MOVE_TOWARD_PLAYER_SPEED * delta)
				var collision_point = warning_line.to_local(raycast.get_collision_point())
				warning_line.set_point_position(0, Vector2(collision_point.x - WARNING_LINE_LENGTH / 2, collision_point.y + warning_line.width / 2))
				warning_line.set_point_position(1, Vector2(collision_point.x + WARNING_LINE_LENGTH / 2, collision_point.y + warning_line.width / 2))
				leap_timer += delta
				if leap_timer >= LEAP_TIME:
					leap_timer = 0
					state = State.LEAPING_WARNING
		State.LEAPING_WARNING:
			position.x = player.global_position.x
			warning_line.get_node("AnimationPlayer").play("flash")
			leap_timer += delta
			if leap_timer >= LEAP_WARNING_TIME:
				leap_timer = 0
				state = State.LEAPING_FALLING
		State.LEAPING_FALLING:
			animation_player.play("LEAPING_FALLING")
			state = State.LEAPING_END
		State.LEAPING_END:
			warning_line.visible = false
			state = State.METEOR
			await animation_player.animation_finished
			cracked_ground.play("crack")
			boss_bricks_animation_player.play("rise")
			initial_run = false
			$AnimatedSprite2D.play("grow_fire")
			

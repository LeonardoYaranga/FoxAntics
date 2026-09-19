class_name Player
extends CharacterBody2D

#Constants
var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")
const RUN_SPEED: float = 200.0
const JUMP_SPEED: float = -350.0
const STOMP_SPEED: float = -200.0
const HURT_VELOCITY: Vector2 = Vector2(0, -200)
const FLASH_COUNT: int = 6
const FLASH_DURATION: float = 0.2
const MAX_FALL_SPEED: float = 300
@export var left_limit_cam: int = -10000000
@export var top_limit_cam: int = -10000000
@export var right_limit_cam: int = 10000000
@export var bottom_limit_cam: int = 10000000

@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var land_sound: AudioStreamPlayer = $LandSound
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player_cam: Camera2D = $PlayerCam
@onready var hurt_timer: Timer = $HurtTimer
@onready var hurt_sound: AudioStreamPlayer = $HurtSound

#AnimationTree
var is_still: bool:
	get: return is_zero_approx(velocity.x)
var is_falling: bool:
	get: return velocity.y > 0
var is_ground: bool:
	get: return is_on_floor()
var is_hurt: bool:
	get: return _is_hurt

var _jumped: bool = false
var _was_on_floor: bool = false
var _start_position: Vector2 = Vector2.ZERO
var _is_hurt: bool = false
var _is_invincible: bool = false
var _invincible_tween: Tween
var _damage_areas: Array[Area2D] = []

func _ready() -> void:
	_start_position = position
	set_camera_limits()

func set_camera_limits() -> void:
	player_cam.limit_left = left_limit_cam
	player_cam.limit_top = top_limit_cam
	player_cam.limit_right = right_limit_cam
	player_cam.limit_bottom = bottom_limit_cam
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		_jumped = true

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	handle_movement()
	flip_sprite()
	check_landed()
	move_and_slide()

func check_landed() -> void:
	if !_was_on_floor and is_on_floor():
		land_sound.play()

	_was_on_floor = is_on_floor()

func flip_sprite() -> void:
	if not is_zero_approx(velocity.x):
		sprite_2d.flip_h = velocity.x < 0
	

func handle_movement() -> void:
	if _is_hurt: return
	velocity.x = RUN_SPEED * Input.get_axis("left", "right")
	if _jumped and is_on_floor():
		_jumped = false
		velocity.y = JUMP_SPEED
		jump_sound.play()
	velocity.y = minf(velocity.y, MAX_FALL_SPEED)

func fell_off() -> void:
	set_position.call_deferred(_start_position)

func go_invincible() -> void:
	if _is_invincible: return
	_is_invincible = true
	if _invincible_tween and _invincible_tween.is_running():
		#_invincible_tween.stop()
		_invincible_tween.kill()

	_invincible_tween = create_tween()
	_invincible_tween.set_loops(FLASH_COUNT)
	_invincible_tween.tween_property(sprite_2d, "modulate", Color.TRANSPARENT, FLASH_DURATION)
	_invincible_tween.tween_property(sprite_2d, "modulate", Color.WHITE, FLASH_DURATION)
	_invincible_tween.finished.connect(_on_invincible_finished)

func _on_invincible_finished() -> void:
	_is_invincible = false
	if _damage_areas.size() > 0:
		apply_hit.call_deferred()

func apply_hurt_jump() -> void:
	if _is_hurt: return
	velocity = HURT_VELOCITY
	_is_hurt = true
	hurt_timer.start()
	hurt_sound.play()

func apply_hit() -> void:
	if _is_invincible: return
	apply_hurt_jump()
	go_invincible()
	
func apply_stomp() -> void:
	velocity.y = STOMP_SPEED

func apply_trampoline_bounce(bounce_velocity: Vector2) -> void:
	velocity = bounce_velocity

func _on_hit_area_area_entered(area: Area2D) -> void:
	print("Player HIT")
	apply_hit.call_deferred()
	if area not in _damage_areas:
		_damage_areas.append(area)

func _on_hit_area_area_exited(area: Area2D) -> void:
	_damage_areas.erase(area)

func _on_hurt_timer_timeout() -> void:
	_is_hurt = false


func _on_stomp_area_entered(area: Area2D) -> void:
	if velocity.y < 0.0 or _is_hurt: return
	if area is StompBox and !area.is_hit:
		apply_stomp.call_deferred()
		area.trigger()
		print("STOMPED")
		
	if area is Trampoline and not area.bouncing:
		area.bounce()
		apply_trampoline_bounce.call_deferred(area.bounce_velocity)

class_name Player
extends CharacterBody2D

@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var land_sound: AudioStreamPlayer = $LandSound
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player_cam: Camera2D = $PlayerCam

@export var left_limit_cam: int = -10000000
@export var top_limit_cam: int = -10000000
@export var right_limit_cam: int = 10000000
@export var bottom_limit_cam: int = 10000000


var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")
const RUN_SPEED: float = 300.0
const JUMP_FORCE: float = -400.0

var _jumped: bool = false
var _was_on_floor: bool = false
var _start_position: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
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
		_was_on_floor = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#apply gravity
	#if not is_on_floor():
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
	velocity.x = RUN_SPEED * Input.get_axis("left", "right")
	if _jumped and is_on_floor():
		_jumped = false
		velocity.y = JUMP_FORCE
		jump_sound.play()

func fell_off() -> void:
	set_position.call_deferred(_start_position)

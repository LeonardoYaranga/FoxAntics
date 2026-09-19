class_name EnemyBase
extends CharacterBody2D

var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var speed: float = 50.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray: RayCast2D = $WallRay
@onready var floor_ray: RayCast2D = $FloorRay
@onready var stomp_box: StompBox = $StompBox
@onready var hit_area: Area2D = $HitArea

var _direction: int = -1

func _ready() -> void:
	if stomp_box and not stomp_box.stomped.is_connected(_on_stomp_box_stomped):
		stomp_box.stomped.connect(_on_stomp_box_stomped)

func _physics_process(delta: float) -> void:	
	_apply_gravity(delta)
	update_behavior(delta)
	#do_walk()
	move_and_slide()
	
func _apply_gravity(delta) -> void:
	velocity.y += GRAVITY * delta

func update_behavior(_delta) -> void:
	pass

func flip_sprite() -> void:
	animated_sprite_2d.flip_h = _direction > 0

func flip_raycasts() -> void:
	wall_ray.target_position.x *= -1
	floor_ray.position.x *= -1
	#print("flipped raycasts", wall_ray.target_position.x, floor_ray.position.x)

func do_walk() -> void:
	if wall_ray.is_colliding() or not floor_ray.is_colliding():
		_direction *= -1
		flip_sprite()
		flip_raycasts()
	velocity.x = _direction * speed
	
func _on_stomp_box_stomped() -> void:
	animated_sprite_2d.play("hit")
	set_physics_process.call_deferred(false)
	hit_area.set_deferred("monitorable", false)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.get_animation() == "hit":
		queue_free()

extends CharacterBody2D

class_name GangsterMC

@export var speed := 1200
@export var jump_speed := -1800
@export var gravity := 4000
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.25

@export var bullet_2d: PackedScene
#@export var camera: Camera2D

var is_running : bool
var is_shooting : bool
var is_jumping : bool

@onready var sprite_parent := %SpriteParent
@onready var sprite := %GangsterSprite
@onready var muzzle_flash := %MuzzleFlash


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		is_shooting = true
		shoot_bullet() # shoot first bullet immediately
	
	if event.is_action_released("click"):
		is_shooting = false

func _process(_delta):
	set_animation()

func _physics_process(delta):
	if is_shooting and is_on_floor():
		return
	
	velocity.y += gravity * delta
	var horizontal_input = Input.get_axis("left", "right")
	
	if is_zero_approx(horizontal_input):
		velocity.x = lerp(velocity.x, 0.0, friction)
	else:
		velocity.x = lerp(velocity.x, horizontal_input * speed, acceleration)
		
		if horizontal_input < 0: # only flip when moving
			sprite_parent.scale.x = -1
		else:
			sprite_parent.scale.x = 1
	
	is_running = absf(horizontal_input) > 0.5
	move_and_slide()
	
	if is_jumping and is_on_floor():
		is_jumping = false
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_jumping = true
		velocity.y = jump_speed

func set_animation():
	if is_shooting:
		play_animation("shoot")
	elif is_jumping:
		play_animation("jump")
	elif is_running:
		play_animation("run")
	elif !is_zero_approx(velocity.x):
		play_animation("walk")
	else:
		play_animation("idle")

func play_animation(anim_name: String):
	if sprite.is_playing() and sprite.animation == anim_name:
		return
	sprite.play(anim_name)

#func _on_muzzle_flash_animation_finished() -> void:
	#muzzle_flash.hide()

func _on_sprite_animation_looped() -> void:
	if is_shooting and sprite.animation == "shoot":
		shoot_bullet()

func shoot_bullet() -> void:
	#muzzle_flash.show()
	#muzzle_flash.play("default")
	# TODO instantiate bullet
	var bullet := bullet_2d.instantiate()
	get_parent().add_child(bullet)
	bullet.start(
		sprite_parent.scale.x > 0,  # is positive x direction
		muzzle_flash.global_position  # initial position of bullet
	)

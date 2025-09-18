extends CharacterBody2D

@export var speed = 1200
@export var jump_speed = -1800
@export var gravity = 4000

var is_running : bool
var is_shooting : bool

@onready var sprite := $Sprite2D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		is_shooting = true
	
	if event.is_action_released("click"):
		is_shooting = false
		

func _process(_delta):
	set_animation()

func _physics_process(delta):
	if is_shooting:
		return
	
	velocity.y += gravity * delta

	var horizontal_input = Input.get_axis("left", "right")
	velocity.x = horizontal_input * speed
	
	sprite.flip_h = horizontal_input < 0
	
	is_running = absf(horizontal_input) > 0.5

	move_and_slide()

	# Only allow jumping when on the ground
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

func set_animation():
	if is_running:
		play_animation("run")
	if is_shooting:
		play_animation("shoot")
	elif velocity.is_zero_approx():
		play_animation("idle")
	else:
		play_animation("walk")
	

func play_animation(anim_name: String):
	if sprite.is_playing() and sprite.animation == anim_name:
		return
	sprite.play(anim_name)

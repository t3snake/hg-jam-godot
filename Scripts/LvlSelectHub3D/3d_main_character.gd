extends CharacterBody3D

class_name MainCharacter3D

# references
@onready var spring_arm = $SpringArm3D  # camera arm
@onready var camera = $SpringArm3D/Camera3D
@onready var anim_player = $AnimationPlayer
@onready var model = $Model

#@onready var footstep_player = %Footsteps
#@onready var jump_player = %Jump
#@onready var gold_collect_player = %GoldCollected
#@onready var death_player = %Death

@export var current_level: int

# editor exported state
@export_group("Player Parameters")
@export var speed = 10.0
@export var acceleration = 10.0

#@export var high_jump_vert_speed = 18.0
#@export var long_jump_vert_speed = 12.0
#@export var dive_vert_speed = 8.0
@export var jump_vert_speed = 12.0

@export_group("Mouse")
@export var mouse_sensitivity = 0.0015
@export var rotation_speed = 15.0

# TODO needed?
@export var killzone_y = -10.0

# debug params
@export_group("Debug")
@export var show_debug_info = true

enum CharacterState { IDLE, RUN, JUMP, DEAD }

# state
var input = Vector2.ZERO
var character_state : CharacterState

var is_running : bool
var is_jumping : bool
var is_dead : bool

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 3

func _ready() -> void:
	GlobalState.init_level(current_level)
	GlobalState.start_timer()
	
	character_state = CharacterState.IDLE
	is_running = false
	is_jumping = false
	is_dead = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	check_level_beaten()
	
	if global_position.y < killzone_y:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		game_over()
	
	velocity.y += -gravity * delta
	if !is_jumping:
		get_move_input(delta)
	move_and_slide()
	
	set_character_state()
	handle_animation()
	
	if !input.is_zero_approx() and !is_jumping:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)	
	
	# Debug info
	if is_jumping and absf(velocity.y) < 0.25 and show_debug_info:
		print("Jump Debug info: ")
		var horiz_speed = Vector2(velocity.x, velocity.z)
		print("Horizontal speed: " + str(horiz_speed.length()))
		print("Vertical height: " + str(global_position.y))

func get_move_input(delta):
	var vy = velocity.y
	velocity.y = 0
	input = Input.get_vector("left", "right", "forward", "back")
	var dir = Vector3(input.x, 0, input.y)
	if spring_arm:
		dir = dir.rotated(Vector3.UP, spring_arm.rotation.y)
	var new_speed = speed*2 if is_running else speed
	velocity = lerp(velocity, dir * new_speed, acceleration * delta)
	velocity.y = vy

func _unhandled_input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# camera handling on mouse movement
			spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
			spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
			spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event.is_action_pressed("click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("jump"):
		if !is_jumping and is_on_floor():
			is_jumping = true
			velocity.y = jump_vert_speed
			#jump_player.play()
	
	if event.is_action_pressed("run"):
		is_running = true
	
	if event.is_action_released("run"):
		is_running = false


func set_character_state():
		
	if is_on_floor():
		is_jumping = false
	
	if is_dead:
		character_state = CharacterState.DEAD
	elif is_jumping:
		character_state = CharacterState.JUMP
	elif is_running and !input.is_zero_approx():
		character_state = CharacterState.RUN
	elif input.is_zero_approx():
		character_state = CharacterState.IDLE
	else:
		character_state = CharacterState.RUN

func handle_animation():
	match character_state:
		CharacterState.RUN:
			play_animation("3DMainCharacterAnims/Run")
		CharacterState.IDLE:
			play_animation("3DMainCharacterAnims/Idle")
		CharacterState.JUMP:
			play_animation("3DMainCharacterAnims/Jump")
		CharacterState.DEAD:
			pass
			#play_animation("die")

func play_animation(anim_name: String) -> void:
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	
	anim_player.play(anim_name)

func die() -> void:
	is_dead = true
	play_death_sound()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		get_tree().change_scene_to_file("res://Scenes/ui/died_menu.tscn")

func play_footstep() -> void:
	pass
	#footstep_player.play()
	
func play_death_sound() -> void:
	pass
	#if !death_player.is_playing():
		#death_player.play(0.57)

func check_level_beaten() -> void:
	if GlobalState.is_current_level_cleared:
		GlobalState.stop_timer()
		#gold_collect_player.play()
		set_physics_process(false)
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scenes/ui/end_menu.tscn")

func game_over() -> void:
	play_death_sound()
	spring_arm.top_level = true;
	GlobalState.stop_timer()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/ui/died_menu.tscn")

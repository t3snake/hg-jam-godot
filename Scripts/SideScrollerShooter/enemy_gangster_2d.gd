extends CharacterBody2D

class_name EnemyGangster

@onready var sprite := $Sprite
@onready var hurt_sound_player := $HurtSoundPlayer

@export var health := 2
@export var speed := 200
@export var gravity := 1800
@export_range(0.0, 1.0) var hit_friction = 0.4
@export_range(0.0 , 1.0) var acceleration = 0.25

@export var dead_body_sprite : PackedScene

var is_running : bool
var is_attacking : bool
var is_hurt : bool
var is_dead : bool

var target : Node2D
var flip : bool

func register_hit():
	if is_dead:
		return
	
	health -= 1
	hurt_sound_player.play()
	if health <= 0:
		is_dead = true
		GlobalState.dopamine_mp += 4.0
		GlobalState.sleep_for_ms(20)
	else:
		is_hurt = true
		GlobalState.sleep_for_ms(20)

func _process(_delta: float) -> void:
	set_animation()

func _physics_process(delta: float) -> void:
	var old_flip = flip
	var vector_to_player = Vector2.ZERO
	velocity.y += gravity * delta
	if is_running and !is_hurt and !is_dead:
		if target.global_position.x < global_position.x:
			flip = true
			vector_to_player = Vector2.LEFT
		else:
			flip = false
			vector_to_player = Vector2.RIGHT
			
		velocity.x = lerpf(velocity.x, speed * vector_to_player.x, acceleration)
	else:
		velocity.x = lerpf(velocity.x, 0.0, hit_friction)
		
	if old_flip != flip:
		scale.x *= -1
	
	move_and_slide()

func set_animation():
	if is_dead:
		play_animation("dead")
	elif is_hurt:
		play_animation("hurt")
	elif is_attacking:
		play_animation("attack")
	elif is_running:
		play_animation("run")
	

func play_animation(anim_name: StringName):
	if sprite.is_playing() and sprite.animation == anim_name:
		return
	sprite.play(anim_name)

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "hurt":
		is_hurt = false
	
	if sprite.animation == "dead":
		is_dead = false
		GlobalState.enemies_killed += 1
		# TODO leave dead body sprite - spawn here?
		
		var dead_body = dead_body_sprite.instantiate()
		dead_body.global_position = global_position
		if flip:
			dead_body.flip_h = true
		get_parent().add_child(dead_body)
		queue_free()

func _on_sprite_frame_changed() -> void:
	if !(sprite.is_playing() and sprite.animation == "attack"):
		return
	
	if sprite.frame == 2 and target is GangsterMC:
		target.register_hit()

func _on_detect_area_body_entered(body: Node2D) -> void:
	if body is GangsterMC:
		is_running = true
		target = body

func _on_detect_area_body_exited(body: Node2D) -> void:
	if body is GangsterMC:
		is_running = false
		target = null

func _on_punch_area_body_entered(body: Node2D) -> void:
	if body is GangsterMC:
		is_attacking = true

func _on_punch_area_body_exited(body: Node2D) -> void:
	if body is GangsterMC:
		is_attacking = false

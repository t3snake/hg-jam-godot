extends CharacterBody2D

@onready var sprite := $Sprite

@export var health := 2

var is_running : bool
var is_attacking : bool
var is_hurt : bool
var is_dead : bool

func register_hit():
	health -= 1
	if health <= 0:
		is_dead = true
	else:
		is_hurt = true

func _process(_delta: float) -> void:
	set_animation()

func _physics_process(_delta: float) -> void:
	pass

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
		

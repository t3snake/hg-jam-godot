extends Area2D

@onready var bullet_sprite := %BulletSprite
@onready var impact_sprite := %ImpactSprite

var has_collided := false
var direction := Vector2.ZERO

@export var speed := 800

func start(is_pos_x_dir: bool, init_pos: Vector2) -> void:
	global_position = init_pos
	
	if is_pos_x_dir:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT
		scale.x = -1
	
	bullet_sprite.play("bullet")

func _physics_process(delta: float) -> void:
	if has_collided:
		return
	
	position += speed * direction * delta

func _on_body_entered(_body: Node2D) -> void:
	has_collided = true
	bullet_sprite.hide()
	impact_sprite.show()
	impact_sprite.play("impact")

func _on_lifetime_timeout() -> void:
	queue_free()

func _on_impact_sprite_animation_finished() -> void:
	queue_free()

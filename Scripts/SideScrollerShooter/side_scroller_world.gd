extends Node2D

@export var enemy_gangster : PackedScene

@onready var player := $Gangster2D

# x: -700 to 400
# y: -300

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy():
	var enemy = enemy_gangster.instantiate()
	enemy.global_position.y = -200
	var new_pos = randf_range(-700.0, 400.0)
	if absf(new_pos - player.global_position.x) < 100.0:
		if new_pos > player.global_position.x:
			new_pos += 150.0
		else:
			new_pos -= 150.0
	enemy.global_position.x = new_pos
	
	$Enemies.add_child(enemy)

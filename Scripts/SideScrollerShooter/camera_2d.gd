extends Camera2D

@export var camera_lerp_speed := 5.0
@export var character_marker : Marker2D

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(
		character_marker.global_position, 
		camera_lerp_speed * delta
	)

extends Node

var timer: float
var is_timer_active: bool

# global state
var total_levels: int = 6
var levels_cleared: int
# TODO this could be array since key is level
var highscore_map: Dictionary
var bonus_time_map: Array  # in seconds

# current state
var current_level : int
var is_current_level_cleared : bool
var is_time_dilated : bool

# bars
var willpower_hp : float
var dopamine_mp : float

const dopamine_decay_rate := 10 ## -10 per second

var kbm_active: bool

# Internal functions
func _ready() -> void:
	levels_cleared = 0
	timer = 0
	is_timer_active = false
	is_time_dilated = false
	
	willpower_hp = 40.0
	dopamine_mp = 0.0
	
	highscore_map = {}
	bonus_time_map = [3, 3, 3, 4, 4, 5]
	for lvl in range(total_levels):
		highscore_map[lvl] = 0

func _process(delta: float) -> void:
	if is_timer_active:
		timer += delta
	
	if is_time_dilated:
		dopamine_mp -= dopamine_decay_rate * delta
		if dopamine_mp <= 0:
			dopamine_mp = 0.0
			toggle_time_dilation()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventKey:
		kbm_active = true
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		kbm_active = false
	
	if event.is_action_pressed("dilate_time"):
		toggle_time_dilation()

# Time dilation functions

## Dilate time to half speed or restore, requires dopamine_mp to sustain
func toggle_time_dilation():
	if is_time_dilated:
		Engine.time_scale = 1
	else:
		Engine.time_scale = 0.5
	
	is_time_dilated = !is_time_dilated

# Level management functions

## Called when new level is started to restart state such as timer
func init_level(level: int) -> void:
	current_level = level
	timer = 0
	is_timer_active = false
	
	is_current_level_cleared = false

## Set level as cleared
func set_level_cleared() -> void:
	if current_level > levels_cleared:
		levels_cleared = current_level
	
	is_current_level_cleared = true
	
	if highscore_map[current_level - 1] == 0:
		highscore_map[current_level - 1] = timer
	elif timer < highscore_map[current_level - 1]:
		highscore_map[current_level - 1] = timer

## Go to next level (if levels are numbered as level1.tscn)
func go_to_next_level() -> void:
	if current_level < total_levels:
		get_tree().change_scene_to_file(
			"res://Scenes/level%d.tscn" % (current_level + 1)
		)
	else:
		get_tree().change_scene_to_file("res://Scenes/ui/beat_game_menu.tscn")

## Restart currently running level
func restart_level() -> void:
	get_tree().change_scene_to_file("res://Scenes/level%d.tscn" % current_level)

# Timer functions

## Start timer and reset counter
func start_timer() -> void:
	is_timer_active = true
	timer = 0

## Unpause a stopped timer without resetting the counter
func unpause_timer() -> void:
	is_timer_active = true

## Pause or Stop timer counting
func stop_timer() -> void:
	is_timer_active = false

## Sleep for time in milliseconds
func sleep_for_ms(time: int) -> void:
	get_tree().paused = true
	await get_tree().create_timer(time/1000.0).timeout
	get_tree().paused = false

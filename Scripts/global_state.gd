extends Node

# main timer
var timer: float
var is_timer_active: bool

var score : int
var enemies_killed : int

# main game ids
const LevelSelectHub3D := "level_select_hub"
const SideScrollLevel := "side_scroll_shooter"
const Race3DLevel := "race_Level"

# ui scene ids
const MainMenu := "main_menu"
const LevelBeatMenu := "level_beat"
const LevelFailMenu := "level_fail"
const GameBeatMenu := "game_beat"

# reusable constants
const scene_root := "res://Scenes/"

# TODO In future would be nice to have all level management in level singleton

## Stores path to scene for key: Level Id
var level_scene_map := {
	SideScrollLevel: scene_root + "SideScrollerShooter/side_scroller_world.tscn",
	LevelSelectHub3D: scene_root + "LvlSelectHub3D/world3d.tscn",
	# TODO other main levels
	MainMenu: scene_root + "UI/main_menu.tscn",
	LevelBeatMenu: scene_root + "UI/end_menu.tscn",
	LevelFailMenu: scene_root + "UI/died_menu.tscn",
	GameBeatMenu: scene_root + "UI/beat_game_menu.tscn"
}

## Stores title for key: Level id
var level_title_map := {
	SideScrollLevel: "Focus and kill impulses",
	LevelSelectHub3D: "Select a task to do"
}

## Stores highscores for key: Level Id (global_state.gd)
var highscore_map := {
	SideScrollLevel: 0,
	Race3DLevel: 0
}

# current state
var current_level : String
var is_current_level_cleared : bool
var is_time_dilated : bool

# bars
var willpower_hp : float
var dopamine_mp : float

const dopamine_decay_rate := 10 ## -10 per second

var kbm_active: bool

# Internal functions
func _ready() -> void:
	reset_state()
	highscore_map = {
		SideScrollLevel: 0,
		Race3DLevel: 0
	}

func reset_state() -> void:
	timer = 0
	is_timer_active = false
	is_time_dilated = false
	
	willpower_hp = 100.0
	dopamine_mp = 0.0
	
	score = 0
	enemies_killed = 0

func _process(delta: float) -> void:
	if is_timer_active:
		timer += delta
	
	if dopamine_mp > 100.0:
		dopamine_mp = 100.0
	
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
func init_level(level: String) -> void:
	current_level = level
	timer = 0
	is_timer_active = false
	
	is_current_level_cleared = false

## Set level as cleared
func set_level_cleared() -> void:	
	is_current_level_cleared = true
	update_high_score()

## Calculate score and update highscore if required
func update_high_score():
	calculate_score()
	
	if highscore_map[current_level] == 0:
		highscore_map[current_level] = score
	elif score > highscore_map[current_level]:
		highscore_map[current_level] = score

func calculate_score():
	var timer_score = timer * 10
	var health_score = willpower_hp * 30
	var dopamine_score = dopamine_mp * 20
	var enemy_kill_score = enemies_killed * 20
	
	score = int(timer_score + health_score + dopamine_score + enemy_kill_score)

## Load scene for given level id (see constants in global_state.gd)
func go_to_level(level_id: String) -> void:
	get_tree().change_scene_to_file(level_scene_map[level_id])

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

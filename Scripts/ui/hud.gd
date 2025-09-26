extends CanvasLayer

@export var hint_enabled : bool
@export var hint_text : String

@export var damage_bar_delay := 5

func _ready() -> void:
	%Level.text = "Level %d" % GlobalState.current_level
	
	if hint_enabled:
		%HintBackground.show()
		%HintText.text = "Hint: %s" % hint_text
	else:
		%HintBackground.hide()

func _process(delta: float) -> void:
	var damage_bar_value = %DamageBar.value
	var willpower_bar_value = %WillpowerBar.value
	%DamageBar.value = lerpf(
		damage_bar_value, 
		willpower_bar_value, 
		damage_bar_delay * delta
	)

func update_hud(time: float):
	%TimeElapsed.text = "Time elapsed: %.2f s" % time
	%WillpowerBar.value = GlobalState.willpower_hp
	

func _on_hud_update_timer_timeout() -> void:
	update_hud(GlobalState.timer)

func _on_hint_disappear_timer_timeout() -> void:
	if hint_enabled:
		%HintBackground.hide()

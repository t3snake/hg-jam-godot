extends CanvasLayer

@export var hint_enabled : bool
@export var hint_text : String

@export var bar_delay := 5

var is_dopamine_depleting = true

func _ready() -> void:
	%Level.text = "Level %d" % GlobalState.current_level
	
	if hint_enabled:
		%HintBackground.show()
		%HintText.text = "Hint: %s" % hint_text
	else:
		%HintBackground.hide()

func _process(delta: float) -> void:
	# Willpower / HP adjustment
	var damage_bar_value = %DamageBar.value
	var willpower_bar_value = %WillpowerBar.value
	%DamageBar.value = lerpf(
		damage_bar_value, 
		willpower_bar_value, 
		bar_delay * delta
	)
	
	# Dopamine / MP adjustment
	if GlobalState.is_time_dilated: # dont lerp while time is dilated
		return
	
	var regen_bar_value = %RegenBar.value
	var dopamine_bar_value = %DopamineBar.value
	if is_dopamine_depleting:
		%RegenBar.value = lerpf(
			regen_bar_value,
			dopamine_bar_value,
			bar_delay * delta
		)
	else:
		%DopamineBar.value = lerpf(
			dopamine_bar_value,
			regen_bar_value,
			bar_delay * delta
		)

func update_hud(time: float):
	%TimeElapsed.text = "Time elapsed: %.2f s" % time
	%WillpowerBar.value = GlobalState.willpower_hp
	
	# if dopamine depleting, move the top dopamine bar first
	# else if dopamine regenerating, move the regen bar first
	if %DopamineBar.value > GlobalState.dopamine_mp:
		is_dopamine_depleting = true
		%DopamineBar.value = GlobalState.dopamine_mp
	else:
		is_dopamine_depleting = false
		%RegenBar.value = GlobalState.dopamine_mp
	

func _on_hud_update_timer_timeout() -> void:
	update_hud(GlobalState.timer)

func _on_hint_disappear_timer_timeout() -> void:
	if hint_enabled:
		%HintBackground.hide()

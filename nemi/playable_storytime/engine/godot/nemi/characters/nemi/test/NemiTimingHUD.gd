class_name NemiTimingHUD
extends CanvasLayer

## Live Timing & Performance Debug HUD for NEMI Directors
## Displays current action, expression, elapsed hold times, intensity, and rig state.

@onready var panel: PanelContainer = $Panel
@onready var action_label: Label = $Panel/Margin/VBox/ActionRow/ActionVal
@onready var state_label: Label = $Panel/Margin/VBox/StateRow/StateVal
@onready var expr_label: Label = $Panel/Margin/VBox/ExprRow/ExprVal
@onready var time_label: Label = $Panel/Margin/VBox/TimeRow/TimeVal
@onready var intensity_label: Label = $Panel/Margin/VBox/IntensityRow/IntensityVal
@onready var mode_label: Label = $Panel/Margin/VBox/ModeRow/ModeVal
@onready var progress_bar: ProgressBar = $Panel/Margin/VBox/ProgressBar

var target_nemi: Nemi

func setup(nemi: Nemi) -> void:
	target_nemi = nemi

func _process(_delta: float) -> void:
	if not target_nemi or not visible:
		return
	
	var actor: NemiActingDirector = target_nemi.actor
	if actor:
		if action_label: action_label.text = actor.current_action
		if state_label:
			state_label.text = actor.acting_state
			match actor.acting_state:
				"HOLDING": state_label.modulate = Color("#ffcb6b") # Gold
				"ACTING": state_label.modulate = Color("#82aaff")  # Soft blue
				"FROZEN": state_label.modulate = Color("#c792ea")  # Magenta
				_: state_label.modulate = Color("#c3e88d")         # Green (Idle)
		
		if time_label:
			var dur: float = actor.action_duration
			var elap: float = actor.action_elapsed
			time_label.text = "%.2fs / %.2fs" % [elap, dur]
			if progress_bar:
				progress_bar.max_value = max(0.01, dur)
				progress_bar.value = min(dur, elap)
		
		if intensity_label:
			intensity_label.text = "%.2f" % actor.current_intensity
	
	if expr_label:
		expr_label.text = target_nemi.current_expression_name.to_upper()
	
	if mode_label and target_nemi.style:
		mode_label.text = "COLOR" if target_nemi.style.current_mode == NemiStyle.ArtMode.COLOR else "MONOCHROME"

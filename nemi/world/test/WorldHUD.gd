class_name WorldHUD
extends CanvasLayer

## On-screen diagnostic HUD for testing the Illustrated World System

@onready var panel: PanelContainer = $PanelContainer
@onready var lbl_env: Label = %LblEnv
@onready var lbl_density: Label = %LblDensity
@onready var lbl_mode: Label = %LblMode
@onready var lbl_cam: Label = %LblCamera
@onready var lbl_props: Label = %LblProps
@onready var lbl_status: Label = %LblStatus

func update_status(env_name: String, density: int, is_mono: bool, cam_name: String, prop_count: int, status_msg: String = "") -> void:
	if lbl_env: lbl_env.text = "Environment: " + env_name
	if lbl_density:
		var d_names := ["0 - Minimal (Floor)", "1 - Sparse", "2 - Normal", "3 - Detailed"]
		lbl_density.text = "Density: " + (d_names[density] if density < d_names.size() else str(density))
	if lbl_mode: lbl_mode.text = "Mode: " + ("MONOCHROME" if is_mono else "COLOR")
	if lbl_cam: lbl_cam.text = "Camera: " + cam_name
	if lbl_props: lbl_props.text = "Active Props: " + str(prop_count)
	if lbl_status and status_msg != "":
		lbl_status.text = "Action: " + status_msg

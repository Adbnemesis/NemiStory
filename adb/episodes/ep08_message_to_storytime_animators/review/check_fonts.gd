extends SceneTree
func _init() -> void:
	for serif in [false,true]:
		var font=SystemFont.new()
		font.font_names=PackedStringArray(["Times New Roman","Times","Liberation Serif"] if serif else ["Arial","Helvetica","Liberation Sans"])
		font.font_weight=400 if serif else 700
		font.get_string_size("Storytime ADB",HORIZONTAL_ALIGNMENT_LEFT,-1,110)
		var name="unavailable"
		if font.has_method("get_font_name"): name=font.call("get_font_name")
		print("EDITORIAL_FONT ","serif" if serif else "intro",": ",name)
	quit()

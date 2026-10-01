extends SceneTree
const Ink = preload("res://common/engine/illustration/LiveInk.gd")
const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Letters = preload("res://common/engine/illustration/DrawnLettering.gd")
const Doodle = preload("res://common/engine/doodles/CommonDoodle.gd")
const Writing = preload("res://common/engine/handwriting/CommonHandwriting.gd")
const AdbDoodles = preload("res://adb/episodes/ep00_intro/ADBIntroDoodles.gd")
const Attachment = preload("res://common/engine/illustration/PropAttachment.gd")
const NemiDoodles = preload("res://nemi/episodes/ep08_forced_bf_channel/Ep08Doodles.gd")
var failures: Array[String] = []
func check(value: bool, message: String) -> void:
	if not value:
		failures.append(message)
		push_error(message)
func _init() -> void:
	call_deferred("run")
func run() -> void:
	var ink := Ink.new()
	ink.prepare([{"pts": PackedVector2Array([Vector2.ZERO,Vector2(100,0)]), "pause":0.0,"duration":1.0}])
	check(is_equal_approx(ink.visible_distance(ink.strokes[0],0.5),50.0),"Two-point line must reveal to its midpoint, not pop complete.")
	ink.prepare([{"pts":PackedVector2Array([Vector2.ZERO,Vector2(100,0)]),"pause":0.0,"duration":1.0},{"pts":PackedVector2Array([Vector2.ZERO,Vector2(50,0)]),"pause":0.5,"duration":1.0}])
	check(ink.visible_distance(ink.strokes[1],0.5)==0.0,"Pen lift must leave next stroke invisible.")
	var drawing := Drawing.new()
	root.add_child(drawing)
	drawing.sample(3.0,1.0,4.0,8.0)
	check(is_equal_approx(drawing.progress,0.5),"Absolute-time sampling must be independent of frame rate.")
	drawing.sample(0.0,1.0,4.0,8.0)
	check(not drawing.visible and drawing.progress==0.0,"Backward seek must restore hidden state.")
	var text_a := Letters.compose("little notes, 6789!",32)
	var text_b := Letters.compose("little notes, 6789!",32)
	check(text_a == text_b,"Identical lettering must render deterministically.")
	check(Letters.compose("iii",32).strokes[0].pts != Letters.compose("iii",32).strokes[2].pts,"Repeated letters must have authored variation.")
	var adb := AdbDoodles.new()
	var nemi := NemiDoodles.new()
	root.add_child(adb)
	root.add_child(nemi)
	var note = adb.spawn_handwritten_note("no plan...",Vector2.ZERO)
	var nemi_note = nemi.spawn_asked_again_note(Vector2.ZERO)
	check(note._ink.strokes.size()>0 and nemi_note._ink.strokes.size()>0,"Both production adapters must use the shared ink engine.")
	var parent := Node2D.new()
	root.add_child(parent)
	parent.position = Vector2(34,52)
	parent.rotation = 0.7
	parent.scale = Vector2(1.4,1.4)
	var hand := Node2D.new()
	parent.add_child(hand)
	hand.position = Vector2(12,23)
	var prop := Node2D.new()
	root.add_child(prop)
	var attachment := Attachment.new()
	attachment.prop = prop
	attachment.target = hand
	attachment.grip_offset = Vector2(0,55)
	root.add_child(attachment)
	attachment.update_attachment()
	check(prop.to_global(attachment.grip_offset).distance_to(hand.global_position) < 0.001,"Prop grip must remain attached under transformed parents.")
	for scene_path in ["res://adb/episodes/ep00_intro/beats/Beat02_IntroConfession.tscn","res://adb/episodes/ep00_intro/beats/Beat03_TableTennis.tscn","res://nemi/episodes/ep08_forced_bf_channel/beats/Beat06_AskingADB.tscn"]:
		var scene = load(scene_path).instantiate()
		scene.is_standalone = false
		root.add_child(scene)
		scene.queue_free()
	for node in [parent,prop,attachment]:
		node.queue_free()
	for node in [drawing,adb,nemi]:
		node.queue_free()
	await process_frame
	print("LIVE INK TESTS: ", "PASS" if failures.is_empty() else "FAIL", " (",failures.size()," failures)")
	quit(0 if failures.is_empty() else 1)

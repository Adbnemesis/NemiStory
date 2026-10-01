extends Node2D
const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Letters = preload("res://common/engine/illustration/DrawnLettering.gd")
const Marks = preload("res://common/engine/illustration/StoryMarks.gd")
const Track = preload("res://common/engine/illustration/IllustrationTrack.gd")
const AdbScene = preload("res://adb/characters/adb/ADB.tscn")
const NemiScene = preload("res://nemi/characters/nemi/nemi.tscn")
const AdbCards = preload("res://adb/episodes/ep00_intro/Episode00Subtitles.gd")
const NemiCards = preload("res://nemi/episodes/ep08_forced_bf_channel/Episode08Subtitles.gd")
const INK := Color("#49303a")
const RED := Color("#a64c50")
const DURATION := 29.03
var pages: Array[Node2D] = []
var tracks: Array[Node] = []
var adb: Node2D
var nemi: Node2D
var subtitle: Label
var elapsed := 0.0
var manual := false
var _last_adb_pose := ""
var _last_nemi_pose := ""

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#faf7f1")
	bg.size = Vector2(1920,1080)
	add_child(bg)
	for i in range(3):
		var page := Node2D.new()
		add_child(page)
		pages.append(page)
		var track := Track.new()
		page.add_child(track)
		tracks.append(track)
	_build_marks_page()
	_build_adb_page()
	_build_nemi_page()
	subtitle = Label.new()
	subtitle.position = Vector2(210,955)
	subtitle.size = Vector2(1500,70)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size",34)
	subtitle.add_theme_color_override("font_color",INK)
	add_child(subtitle)
	sample(0.0)

func _process(delta: float) -> void:
	if not manual:
		elapsed += delta
		sample(elapsed)
		if elapsed >= DURATION:
			get_tree().quit()

func mark(page: int, kind: String, pos: Vector2, scale_value: Vector2, start: float, duration: float, end: float = INF, color: Color = INK, variant: int = 0):
	var d := Drawing.new()
	d.stroke_list = Marks.make(kind,color,variant)
	d.position = pos
	d.scale = scale_value
	pages[page].add_child(d)
	d.prepare()
	tracks[page].add_drawing(d,start,duration,end)
	return d

func words(page: int, text: String, pos: Vector2, size: float, start: float, duration: float, end: float = INF, color: Color = INK, tilt: float = -2.0):
	var d := Drawing.new()
	var data := Letters.compose(text,size,color)
	d.stroke_list.assign(data.strokes)
	d.position = pos
	d.rotation_degrees = tilt
	pages[page].add_child(d)
	d.prepare()
	tracks[page].add_drawing(d,start,duration,end)
	return d

func _build_marks_page() -> void:
	words(0,"a little plan...",Vector2(215,175),70,0.2,1.5)
	mark(0,"notebook",Vector2(650,615),Vector2(2.25,2.25),1.0,1.7)
	words(0,"step 1",Vector2(531,492),35,2.6,0.65)
	words(0,"have an idea",Vector2(525,567),21,3.25,0.9)
	mark(0,"underline",Vector2(640,626),Vector2(1.6,1),4.05,0.45)
	words(0,"seems easy",Vector2(1050,400),49,2.3,1.1,INF,INK,3.0)
	var arrow = mark(0,"arrow",Vector2(950,565),Vector2(1.65,1.65),3.45,0.8)
	arrow.rotation_degrees = 157
	mark(0,"scratch",Vector2(1240,448),Vector2(2.4,1.1),4.9,0.32,INF,RED)
	words(0,"...right?",Vector2(1110,557),60,5.4,1.0,INF,RED,2.5)
	mark(0,"question",Vector2(849,310),Vector2(1.2,1.2),6.45,0.65,INF,RED)

func _build_adb_page() -> void:
	adb = AdbScene.instantiate()
	adb.position = Vector2(495,640)
	adb.scale = Vector2(1.45,1.45)
	pages[1].add_child(adb)
	words(1,"24",Vector2(200,300),56,0.25,0.5,2.8)
	mark(1,"arrow",Vector2(370,385),Vector2.ONE,0.85,0.55,2.8)
	words(1,"the plan",Vector2(935,180),56,2.9,0.8)
	mark(1,"notebook",Vector2(1190,555),Vector2(2.3,2.3),3.75,1.35)
	words(1,"make a video",Vector2(1056,485),22,5.1,0.85)
	words(1,"step 2",Vector2(1065,605),31,6.3,0.65)
	mark(1,"question",Vector2(1250,659),Vector2.ONE,7.1,0.55)
	words(1,"we'll get to that.",Vector2(1350,700),28,8.65,1.05,INF,RED,4.0)
	var arrow = mark(1,"arrow",Vector2(1375,615),Vector2(0.8,0.8),9.8,0.6,INF,RED)
	arrow.rotation_degrees = 152

func _build_nemi_page() -> void:
	nemi = NemiScene.instantiate()
	nemi.position = Vector2(490,680)
	nemi.scale = Vector2(1.45,1.45)
	pages[2].add_child(nemi)
	words(2,"a very convincing argument",Vector2(810,240),31,0.15,1.25)
	words(2,"no.",Vector2(910,430),64,0.4,0.55)
	words(2,"please?",Vector2(1160,465),47,1.5,0.7,INF,RED,3.0)
	words(2,"still no.",Vector2(910,595),53,2.95,0.65)
	words(2,"please??",Vector2(1310,650),47,4.05,0.75,INF,RED,4.0)
	mark(2,"scratch",Vector2(1065,628),Vector2(2.1,1.2),6.4,0.32,INF,RED)
	words(2,"fine.",Vector2(1070,755),72,6.92,0.55)
	mark(2,"underline",Vector2(1170,857),Vector2(1.5,1.0),7.5,0.55,INF,RED,1)

func sample(time: float) -> void:
	var page := 0 if time < 8.0 else (1 if time < 20.27 else 2)
	var local := time if page == 0 else (time - 8.0 if page == 1 else time - 20.27)
	for i in range(pages.size()):
		pages[i].visible = i == page
	tracks[page].sample(local)
	subtitle.text = ""
	if page == 1:
		var pose := "weight_left" if local < 2.8 else ("explaining" if local < 6.85 else ("chin_rub" if local < 9.9 else "open_palms"))
		if pose != _last_adb_pose:
			adb.set_pose(pose,0.0)
			adb.set_expression("confused" if local >= 6.85 else "neutral",0.0)
			_last_adb_pose = pose
		var card := card_at(AdbCards.SUBTITLES, local + 5.57)
		subtitle.text = card.get("text", "")
		adb.set_mouth(["talk_open","talk_wide","neutral","talk_round"][int(local*5)%4] if not card.is_empty() else "neutral")
	elif page == 2:
		var pose := "one_hand_explaining" if local < 5.7 else "confident_presentation"
		if pose != _last_nemi_pose:
			nemi.set_pose(pose,0.0)
			nemi.set_expression("candid" if local<5.7 else "warm_smile")
			_last_nemi_pose=pose
		var card := card_at(NemiCards.SUBTITLES, local + 38.808)
		subtitle.text = card.get("text", "")
		nemi.set_mouth_shape(["small_open","ae","rest","o_u"][int(local*5)%4] if not card.is_empty() else "rest")

func card_at(cards: Array, time: float) -> Dictionary:
	for card in cards:
		if time >= float(card.start) and time < float(card.end):
			return card
	return {}

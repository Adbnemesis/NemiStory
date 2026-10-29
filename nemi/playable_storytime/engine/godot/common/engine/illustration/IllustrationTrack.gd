extends Node
## One time source for all illustrations in a shot. Cues can lead narration,
## land on a word, or wait for a reaction. Safe to seek backwards.
var cues: Array[Dictionary] = []
func add_drawing(drawing: Node2D, start: float, duration: float, end: float = INF) -> void:
	cues.append({"drawing":drawing,"start":start,"duration":duration,"end":end})
	drawing.sample(0.0, start, duration, end)
func sample(time: float) -> void:
	for cue in cues:
		if is_instance_valid(cue.drawing):
			cue.drawing.sample(time, cue.start, cue.duration, cue.end)

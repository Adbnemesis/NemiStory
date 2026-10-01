extends SceneTree
func _init():
	var subs = load("res://nemi/episodes/ep08_forced_bf_channel/Episode08Subtitles.gd")
	var cards = subs.get_cards_for_beat(4)
	print("Beat 4 cards count: ", cards.size())
	for i in range(cards.size()):
		print("  Card ", i, ": [", cards[i]["start"], " - ", cards[i]["end"], "] ", cards[i]["text"])
	quit(0)

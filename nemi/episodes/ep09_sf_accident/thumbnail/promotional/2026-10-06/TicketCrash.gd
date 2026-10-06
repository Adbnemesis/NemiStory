extends Node2D
## Newly authored giant travel-paper/crumpled-cab metaphor, attached at grip.
const Promo = preload("res://nemi/episodes/ep09_sf_accident/thumbnail/promotional/2026-10-06/PromoArt.gd")
func _init() -> void:
	add_child(Promo.make("nemi","b","foreground"))

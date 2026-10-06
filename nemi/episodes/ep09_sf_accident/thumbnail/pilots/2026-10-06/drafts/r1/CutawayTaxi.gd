extends Node2D
## Thumbnail-only cutaway of the exact existing damaged taxi. No prop redraw.
const Travel = preload("res://common/storytime/production/TravelArt.gd")
const WINDOW_MASK = """
shader_type canvas_item;
render_mode unshaded;
varying vec2 taxi_local;
void vertex() {
	taxi_local = VERTEX;
}
float edge_distance(vec2 a, vec2 b, vec2 p) {
	vec2 e = b - a;
	vec2 d = p - a;
	return (e.x*d.y-e.y*d.x)/length(e);
}
void fragment() {
	// Exact original rear-window quad, inset just enough to preserve its ink.
	bool rear_window = edge_distance(vec2(-116.0,-196.0),vec2(-204.0,-116.0),taxi_local)<-2.1
		&& edge_distance(vec2(-204.0,-116.0),vec2(-17.0,-119.0),taxi_local)<-2.1
		&& edge_distance(vec2(-17.0,-119.0),vec2(-17.0,-194.0),taxi_local)<-2.1
		&& edge_distance(vec2(-17.0,-194.0),vec2(-116.0,-196.0),taxi_local)<-2.1;
	if (rear_window) { discard; }
}
"""

func _init() -> void:
	var taxi = Travel.make("nemi", "damaged_car")
	# Original body fill underlies the rear-window fill. A mask through both is
	# necessary to expose the canonical passenger; omitting fill 1 alone is not.
	# Every original polygon and ink stroke is retained in the existing asset.
	assert(taxi.fills.size() >= 3)
	var shader = Shader.new()
	shader.code = WINDOW_MASK
	var window_material = ShaderMaterial.new()
	window_material.shader = shader
	taxi.material = window_material
	taxi.progress = 1.0
	add_child(taxi)

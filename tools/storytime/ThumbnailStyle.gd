extends RefCounted
## Static thumbnail dressing shared by ADB and Nemi; production art is unchanged.
const BG_SHADER = """
shader_type canvas_item;
uniform vec4 top_color : source_color;
uniform vec4 bottom_color : source_color;
void fragment() {
    float lift = clamp(UV.y * 0.77 + UV.x * 0.16, 0.0, 1.0);
    vec3 col = mix(top_color.rgb, bottom_color.rgb, lift);
    float grain = fract(sin(dot(floor(FRAGCOORD.xy / 3.0), vec2(12.9898,78.233))) * 43758.5453) - 0.5;
    col += grain * 0.025;
    COLOR = vec4(col, 1.0);
}
"""
const AURA_SHADER = """
shader_type canvas_item;
void fragment() {
    float inner = texture(TEXTURE, UV).a;
    for (int i=0; i<16; i++) {
        float a = float(i) * 6.2831853 / 16.0;
        vec2 v = vec2(cos(a),sin(a)) * TEXTURE_PIXEL_SIZE;
        inner = max(inner, texture(TEXTURE, UV + v*18.0).a);
    }
    float glow = textureLod(TEXTURE, UV, 5.0).a * 0.65;
    glow = max(glow,textureLod(TEXTURE, UV, 6.0).a * 0.28);
    COLOR = vec4(1.0, 1.0, 1.0, max(inner,glow));
}
"""

static func background(parent: Node, top: String, bottom: String) -> void:
	var rect = ColorRect.new()
	rect.size = Vector2(1920,1080)
	var shader = Shader.new()
	shader.code = BG_SHADER
	var material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("top_color",Color(top))
	material.set_shader_parameter("bottom_color",Color(bottom))
	rect.material = material
	parent.add_child(rect)

static func art_with_aura(parent: Node, img: Image) -> void:
	img.generate_mipmaps()
	var texture = ImageTexture.create_from_image(img)
	var halo = Sprite2D.new()
	halo.texture = texture
	halo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	halo.centered = false
	halo.scale = Vector2(0.5,0.5)
	var shader = Shader.new()
	shader.code = AURA_SHADER
	var material = ShaderMaterial.new()
	material.shader = shader
	halo.material = material
	parent.add_child(halo)
	var art = Sprite2D.new()
	art.texture = texture
	art.centered = false
	art.scale = Vector2(0.5,0.5)
	parent.add_child(art)

static func mark(parent: Node, author: String, kind: String, at: Vector2, size_xy: Vector2, angle: float=0.0) -> void:
	var assets = load("res://common/storytime/ProfileAssets.gd")
	var node = assets.mark(author,kind)
	for stroke in node.stroke_list:
		stroke.col = Color.WHITE
		stroke.w *= 1.5
	node.prepare()
	node.position = at
	node.scale = size_xy
	node.rotation_degrees = angle
	node.progress = 1.0
	parent.add_child(node)

static func headline(parent: Node, value: String, at: Vector2, size_px: int, color: Color=Color.WHITE) -> void:
	var label = Label.new()
	label.text = value
	label.position = at
	label.add_theme_font_override("font",load("res://assets/fonts/Impact.ttf"))
	label.add_theme_font_size_override("font_size",size_px)
	label.add_theme_color_override("font_color",color)
	label.add_theme_color_override("font_shadow_color",Color(0.12,0.035,0.055,0.38))
	label.add_theme_constant_override("shadow_offset_x",5)
	label.add_theme_constant_override("shadow_offset_y",7)
	parent.add_child(label)

static func save_exports(img: Image, prefix: String) -> void:
	assert(img.get_size()==Vector2i(3840,2160))
	assert(img.save_png(prefix+"_master_4k.png")==OK)
	img.resize(1920,1080,Image.INTERPOLATE_LANCZOS)
	assert(img.save_png(prefix+".png")==OK)
	assert(img.save_jpg(prefix+".jpg",0.94)==OK)
	img.resize(320,180,Image.INTERPOLATE_LANCZOS)
	assert(img.save_png(prefix+"_phone.png")==OK)
	img.resize(160,90,Image.INTERPOLATE_LANCZOS)
	assert(img.save_png(prefix+"_tiny.png")==OK)

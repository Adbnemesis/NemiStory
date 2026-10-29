extends SceneTree
const Production=preload("res://common/storytime/production/ProductionStage.gd")
const Wall=preload("res://SchoolWall.gd")
const Drawing=preload("res://DrawingWorld.gd")
func _init() -> void:
	call_deferred("check")
func check() -> void:
	var drawing:=Drawing.new()
	# Endpoint and mid-fold topology/contact checks catch the old thin face
	# and zero-area upright thickness mechanism without a second renderer.
	for folded in [0.0,.25,.5,.75,1.0]:
		var face: Array=drawing.paper_face(Vector2(500,837),folded)
		assert(face[0]==Vector2(240,905),"Paper hinge must preserve supported y905")
		assert(Geometry2D.triangulate_polygon(PackedVector2Array(face)).size()==6,"Paper face must stay a nondegenerate quad")
		var thickness:=Vector2(12.0*(1.0-folded),30.0*folded)
		var front: Array=[face[0],face[3],face[3]+thickness,face[0]+thickness]
		assert(Geometry2D.triangulate_polygon(PackedVector2Array(front)).size()==6,"Paper thickness must remain nondegenerate at every fold endpoint")
	var held: Array=drawing.paper_face(Vector2(500,837),1.0)
	assert(held[0].y==905 and held[3].y==905 and held[0].x<320 and held[3].x>320,"Supported paper must contain the authored arrival sole")
	var edge_on: Array=drawing.paper_face(Vector2(500,837),.5444615528)
	assert(not drawing.paper_polygon_has_area(edge_on),"Turning paper must use the edge-only fallback at its edge-on instant")
	print("MATERIAL GEOMETRY CHECK COMPLETE")
	drawing.free()
	var shader: Shader=load("res://cube_to_sphere.gdshader")
	var material:=ShaderMaterial.new()
	material.shader=shader
	var screen:=ColorRect.new()
	screen.size=Vector2(192,108)
	screen.material=material
	root.add_child(screen)
	var wall:=Wall.new()
	root.add_child(wall)
	wall.sample(0.0)
	await process_frame
	await RenderingServer.frame_post_draw
	print("PLAYABLE ENGINE CHECK COMPLETE")
	quit()

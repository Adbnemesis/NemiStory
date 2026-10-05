extends "res://shorts/godot/BatchAccentArt.gd"
## Fixed authored paths draw once. Moving particles have an event-local finite lifespan.
var path_progress := 1.0
func stroke(points: Array, color: Color, width := 2.5) -> void:
	if points.size() < 2 or path_progress <= 0: return
	var lengths: Array = []
	var total := 0.0
	for i in range(points.size()-1):
		var d := Vector2(points[i][0],points[i][1]).distance_to(Vector2(points[i+1][0],points[i+1][1]))
		lengths.append(d)
		total += d
	var left := total*path_progress
	var pts := PackedVector2Array([Vector2(points[0][0],points[0][1])])
	for i in range(lengths.size()):
		var a := Vector2(points[i][0],points[i][1])
		var b := Vector2(points[i+1][0],points[i+1][1])
		if left >= lengths[i]:
			pts.append(b)
			left -= lengths[i]
		else:
			pts.append(a.lerp(b,left/maxf(lengths[i],.001)))
			break
	if pts.size()>1: draw_polyline(pts,color,width,true)

func circle_path(center: Vector2, radius: float, start: float, stop: float, c: Color, width := 2.5) -> void:
	var points: Array = []
	for i in range(49):
		var p := center+Vector2.from_angle(lerpf(start,stop,float(i)/48))*radius
		points.append([p.x,p.y])
	stroke(points,c,width)

func draw_mark(kind: String, c: Color, phase: float) -> void:
	match kind:
		"stars":
			for data in [[0,0,56],[82,57,25],[-55,74,16]]:
				var points: Array = []
				for i in range(9):
					var p := Vector2(data[0],data[1])+Vector2.from_angle(i*PI/4-PI/2)*float(data[2])*(1.0 if i%2==0 else .24)
					points.append([p.x,p.y])
				stroke(points,c,2.8)
		"arcs":
			for r in [42,64,88]:circle_path(Vector2.ZERO,r,-.72,.72,c)
		"notes":
			circle_path(Vector2(-13,37),12,0,TAU,c)
			stroke([[-3,34],[-3,-46],[42,-57],[42,22]],c,3.4)
			circle_path(Vector2(30,26),12,0,TAU,c)
		"heart":stroke([[0,45],[-39,6],[-37,-20],[-20,-32],[0,-12],[20,-32],[37,-20],[39,6],[0,45]],c,2.8)
		"zigzag":stroke([[-57,-26],[-14,-42],[-30,0],[19,-16],[9,29],[55,9]],c,3.4)
		"brackets":
			stroke([[-55,25],[-55,-32],[-2,-32]],c,3)
			stroke([[4,31],[55,31],[55,-23]],c,3)
		"moon":stroke([[27,-54],[-9,-41],[-26,-13],[-21,18],[4,39],[37,40],[15,16],[5,-17],[27,-54]],c)
		"cloud":stroke([[-57,25],[-63,7],[-49,-6],[-31,-8],[-25,-32],[-3,-40],[22,-26],[24,-8],[47,-9],[59,6],[55,25],[-57,25]],c)
		"leaf":
			stroke([[-3,66],[5,20],[0,-30],[15,-68]],c,2)
			stroke([[4,22],[-25,14],[-42,-7],[-19,-5],[4,22]],c,1.8)
			stroke([[2,-10],[25,-22],[39,-46],[18,-35],[2,-10]],c,1.8)
		"rays","speedlines":
			for i in range(8):
				var p := Vector2.from_angle(i*TAU/8)
				stroke([[p.x*48,p.y*48],[p.x*100,p.y*100]],c,2.7)
		"dash":stroke([[-52,0],[52,0]],c,3.2)
		"ring":circle_path(Vector2.ZERO,60+phase*20,0,TAU,c,2.8)
		"flower":
			circle_path(Vector2.ZERO,12,0,TAU,c)
			for i in range(5):circle_path(Vector2.from_angle(i*TAU/5)*28,20,0,TAU,c)
			stroke([[0,49],[0,91],[25,73]],c)
		"spiral":
			var points: Array = []
			for i in range(101):
				var p := Vector2.from_angle(float(i)/100*TAU*2.2)*float(i)*.7
				points.append([p.x,p.y])
			stroke(points,c)
		"cat":
			stroke([[-53,34],[-56,-35],[-27,-13],[0,-21],[27,-13],[56,-35],[53,34],[29,53],[-29,53],[-53,34]],c,3)
			stroke([[-26,10],[-21,7],[-17,10]],c)
			stroke([[17,10],[21,7],[26,10]],c)
			stroke([[-6,24],[0,28],[6,24],[0,28],[0,38],[-9,42]],c)
			stroke([[0,38],[9,42]],c)
			for side in [-1,1]:
				stroke([[side*34,23],[side*76,15]],c,2)
				stroke([[side*36,32],[side*76,36]],c,2)
		"confetti","spark_trail":
			for i in range(12):
				var direction := Vector2.from_angle(-PI+float(i)*TAU/12)
				var p := direction*(18+phase*115)+Vector2(0,phase*phase*90)
				if kind=="spark_trail": p += Vector2(-phase*90,0)
				var tangent := Vector2(-direction.y,direction.x)*(6+float(i%3)*2)
				draw_line(p-tangent,p+tangent,c,2.5,true)

func _draw() -> void:
	var all_events: Array = events
	# Reuse the established stage and foreground pencil/flash compositions.
	events = []
	for ev in all_events:
		if ev.kind in ["pencil","flash"]:events.append(ev)
	super._draw()
	events = all_events
	if foreground:return
	for ev in events:
		if ev.kind in ["pencil","flash"] or frame<int(ev.at) or frame>=int(ev.end):continue
		var age := float(frame-int(ev.at))
		var animation: String = ev.get("animation","pop")
		var phase := clampf(age/maxf(1,float(ev.end-ev.at-1)),0,1)
		var p := Vector2(ev.position[0],ev.position[1])
		var size := float(ev.get("scale",1))
		var rotation := deg_to_rad(float(ev.get("rotation",0)))
		path_progress = clampf(age/9,0,1) if animation=="draw" else 1.0
		if animation=="pop":size *= 1-.22*pow(1-clampf(age/6,0,1),3)
		if animation=="orbit":
			p += Vector2(sin(phase*PI)*24,(cos(phase*PI)-1)*12)
			rotation += sin(phase*PI)*.12
		if animation=="wipe":p.x += lerpf(-90,90,phase)
		draw_set_transform(p,rotation,Vector2.ONE*size)
		draw_mark(ev.kind,accent if ev.get("accent",true) else ink,phase if animation in ["burst","orbit","wipe"] else 0.0)
		draw_set_transform(Vector2.ZERO)
	path_progress = 1.0

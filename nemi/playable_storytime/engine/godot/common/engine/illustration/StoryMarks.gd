extends RefCounted
## Deliberately drawn silhouettes; pen lifts are separate strokes, not noise.
const INK := Color("#423035")

static func path(coords: Array, width: float = 3.0, color: Color = INK, smooth: bool = true, pause: float = 0.04) -> Dictionary:
	var pts := PackedVector2Array()
	for p in coords:
		pts.append(Vector2(p[0], p[1]))
	return {"pts": pts, "w": width, "col": color, "smooth": smooth, "pause": pause, "pressure": PackedFloat32Array([0.64, 0.92, 0.85, 1.0, 0.5])}

static func make(kind: String, color: Color = INK, variant: int = 0) -> Array[Dictionary]:
	var strokes: Array[Dictionary] = []
	match kind:
		"arrow":
			if variant % 2 == 0:
				strokes.append(path([[-75,22],[-51,5],[-23,-6],[3,-4],[29,5],[49,18]],3.1,color))
			else:
				strokes.append(path([[-72,26],[-50,12],[-17,9],[12,15],[47,25]],3.1,color))
			strokes.append(path([[29,-1],[49,18],[24,20]],3.3,color,false,0.07))
		"circle":
			strokes.append(path([[18,-33],[-9,-37],[-36,-24],[-47,1],[-36,29],[-4,37],[29,28],[45,6],[37,-21],[14,-34],[-11,-32]],3.0,color))
			# A pen lift leaves a real gap before the small corrective flourish.
			strokes.append(path([[-21,-29],[-34,-17],[-39,-4]],1.8,color,true,0.075))
		"underline":
			strokes.append(path([[-60,1],[-29,-2],[4,1],[33,0],[61,-3]],3.2,color))
			if variant % 2 == 1:
				strokes.append(path([[-48,8],[-11,6],[22,8],[49,5]],1.8,color))
		"question":
			strokes.append(path([[-13,-19],[-10,-32],[5,-36],[17,-27],[12,-13],[0,-4],[-1,8]],3.5,color))
			strokes.append(path([[-2,22],[0,23]],4.0,color))
		"exclamation":
			strokes.append(path([[3,-34],[1,-15],[-1,5]],3.8,color))
			strokes.append(path([[-2,20],[0,22]],4.2,color))
		"star":
			strokes.append(path([[-5,-32],[5,-9],[30,-7],[11,7],[16,30],[-4,16],[-26,30],[-18,5],[-35,-9],[-11,-10],[-5,-32]],2.8,color,false))
		"check":
			strokes.append(path([[-24,0],[-10,16],[0,2],[26,-24]],3.8,color,false))
		"bracket":
			strokes.append(path([[15,-35],[-4,-32],[-8,0],[-4,32],[17,35]],3.0,color,false))
		"scratch":
			strokes.append(path([[-78,-22],[56,-27],[-65,-10],[76,-12],[-72,4],[66,9],[-57,23],[77,21]],3.8,color,false))
			strokes.append(path([[-64,-31],[70,30]],2.2,color,false,0.06))
		"notebook":
			strokes.append(path([[-73,-88],[47,-93],[59,68],[-65,76],[-73,-88]],3.2,color,false))
			strokes.append(path([[-63,-77],[35,-81],[45,57],[-56,64]],1.6,color,false))
			strokes.append(path([[-65,76],[-58,87],[68,77],[59,68]],2.5,color,false))
			for y in [-58,-25,9,41]:
				strokes.append(path([[-79,y],[-89,y-3],[-92,y+4],[-83,y+9],[-69,y+6]],2.4,color))
		"emphasis":
			strokes.append(path([[-20,-12],[-37,-25]],3.0,color))
			strokes.append(path([[0,-18],[1,-39]],3.6,color))
			strokes.append(path([[20,-12],[33,-24]],2.8,color))
	return strokes

extends RefCounted
## Small, seekable path vocabulary. Endpoints hold; no ongoing animation.
static func between(path: Array, time: float) -> Dictionary:
	var a: Dictionary=path[0]
	var b: Dictionary=a
	for i in range(path.size()):
		if time>=float(path[i].at):
			a=path[i]
			b=path[mini(i+1,path.size()-1)]
	var u := clampf((time-float(a.at))/maxf(0.0001,float(b.at)-float(a.at)),0,1)
	u=u*u*(3-2*u)
	return {"a":a,"b":b,"u":u}

static func point(path: Array, time: float, field: String="position") -> Vector2:
	var part := between(path,time)
	var a: Array=part.a[field]
	var b: Array=part.b[field]
	var start := Vector2(a[0],a[1])
	var finish := Vector2(b[0],b[1])
	var bend: Array=part.b.get("bend",[0,0])
	return start.lerp(finish,part.u)+Vector2(bend[0],bend[1])*sin(PI*part.u)

static func scalar(path: Array, time: float, field: String, fallback: float) -> float:
	var part := between(path,time)
	return lerpf(float(part.a.get(field,fallback)),float(part.b.get(field,fallback)),part.u)

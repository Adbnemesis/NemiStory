shader_type canvas_item;
render_mode unshaded;
uniform sampler2D wall_front : filter_linear;
uniform sampler2D wall_right : filter_linear;
uniform sampler2D wall_back : filter_linear;
uniform sampler2D wall_left : filter_linear;
uniform sampler2D stage_front : filter_linear;
// One canonical stage texture, placed on an explicitly authored cube face.
uniform int stage_wall = 0;
uniform bool perspective = false;
uniform float yaw = 0.0;
uniform float pitch = 0.0;
uniform float fov = 75.0;
uniform float aspect = 1.7777778;

void fragment(){
	vec3 ray;
	if(perspective){
		vec2 p=(UV-0.5)*2.0;
		float tangent=tan(radians(fov)*0.5);
		ray=normalize(vec3(p.x*tangent*aspect,-p.y*tangent,-1.0));
		float elevation=radians(pitch);
		ray=vec3(ray.x,ray.y*cos(elevation)-ray.z*sin(elevation),ray.y*sin(elevation)+ray.z*cos(elevation));
		float a=radians(yaw);
		ray=vec3(ray.x*cos(a)-ray.z*sin(a),ray.y,ray.x*sin(a)+ray.z*cos(a));
	}else{
		float longitude=(UV.x-0.5)*6.283185307;
		float latitude=(0.5-UV.y)*3.141592654;
		ray=vec3(sin(longitude)*cos(latitude),sin(latitude),-cos(longitude)*cos(latitude));
	}
	vec3 distance=vec3(2.0,1.125,2.0)/max(abs(ray),vec3(0.00001));
	float length=min(distance.x,min(distance.y,distance.z));
	vec3 hit=ray*length;
	vec4 color=vec4(0.98,0.969,0.945,1.0);
	vec2 uv;
	if(distance.y<distance.x && distance.y<distance.z){
		if(ray.y<0.0){
			float grid=max(step(0.985,fract((hit.x+2.0)*2.0)),step(0.985,fract((hit.z+2.0)*2.0)));
			color=vec4(mix(vec3(0.90,0.865,0.82),vec3(0.82,0.78,0.74),grid*0.38),1.0);
		}
	}else{
		uv.y=0.5-hit.y/2.25;
		int wall_index=-1;
		if(distance.z<=distance.x){
			if(ray.z<0.0){
				wall_index=0;
				uv.x=0.5+hit.x/4.0;
				color=texture(wall_front,uv);
			}else{wall_index=2;uv.x=0.5-hit.x/4.0;color=texture(wall_back,uv);}
		}else{
			if(ray.x>0.0){wall_index=1;uv.x=0.5+hit.z/4.0;color=texture(wall_right,uv);}
			else{wall_index=3;uv.x=0.5-hit.z/4.0;color=texture(wall_left,uv);}
		}
		if(wall_index==stage_wall){
			vec4 actor=texture(stage_front,uv);
			color=mix(color,actor,actor.a);
		}
	}
	COLOR=vec4(color.rgb,1.0);
}

extends SceneTree
const A=preload("res://adb/characters/adb/ADBGeometry.gd")
const N=preload("res://nemi/characters/nemi/NemiGeometry.gd")
func encode(value):
 if value is PackedVector2Array:
  var result=[]
  for v in value: result.append([snappedf(v.x,.001),snappedf(v.y,.001)])
  return result
 if value is Array:
  var result=[]
  for v in value: result.append(encode(v))
  return result
 if value is Dictionary:
  var result={}
  for k in value: result[k]=encode(value[k])
  return result
 return value
func _initialize():
 var adb={"head":A.get_head_base_polygon(),"jaw":A.get_jaw_outline(),"hair":A.get_curtain_bangs_polygon(),"backHair":A.get_hair_back_polygon(),"hairCreases":A.get_curtain_creases(),"flicks":A.get_hair_flicks(),"torso":A.get_sweater_body_polygon(),"collarLeft":A.get_collar_lapel_left(),"collarRight":A.get_collar_lapel_right(),"chest":A.get_bare_chest_polygon(),"pelvis":A.get_trouser_pelvis_polygon(),"legLeft":A.get_trouser_leg_polygon(-20,-24,true),"legRight":A.get_trouser_leg_polygon(20,24,false),"shoeLeft":A.get_sneaker_polygon(Vector2(-24,178),true),"shoeRight":A.get_sneaker_polygon(Vector2(24,178),false),"soleLeft":A.get_sneaker_sole(Vector2(-24,178),true),"soleRight":A.get_sneaker_sole(Vector2(24,178),false)}
 var nemi={"head":N.get_head_base_polygon(),"jaw":N.get_jaw_outline(),"hair":N.get_hair_bangs_polygon(),"backHair":N.get_hair_back_polygon(),"hairCreases":N.get_bangs_creases(),"tressLeft":N.get_hair_tress_polygon(true),"tressRight":N.get_hair_tress_polygon(false),"ahoge":N.get_ahoge_polygon(),"torso":N.get_hoodie_torso_polygon(),"collar":N.get_hoodie_collar_polygon(),"skirt":N.get_skirt_polygon(),"pleats":N.get_skirt_pleat_lines(),"bag":N.get_bag_polygon(),"bagFlap":N.get_bag_flap_polygon(),"strap":N.get_bag_strap_polygon(),"shoeLeft":N.get_sneaker_polygon(true),"shoeRight":N.get_sneaker_polygon(false),"soleLeft":N.get_sneaker_sole_polygon(true),"soleRight":N.get_sneaker_sole_polygon(false),"hand":N.get_hand_polygon(0,false)}
 for author in ["adb","nemi"]:
  var file=FileAccess.open("res://../../"+author+"/characters/geometry.json",FileAccess.WRITE)
  file.store_string(JSON.stringify(encode(adb if author=="adb" else nemi),"\t"))
 quit()

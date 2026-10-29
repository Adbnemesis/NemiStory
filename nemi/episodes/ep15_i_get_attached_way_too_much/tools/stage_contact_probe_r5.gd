extends SceneTree
const Stage=preload("res://common/storytime/production/ProductionStage.gd")
func _initialize():
 call_deferred("probe")
func xy(p:Vector2)->Array:
 return [p.x,p.y]
func probe():
 var stage=Stage.new()
 stage.manual=true
 stage.spec_path="res://nemi/episodes/ep15_i_get_attached_way_too_much/scene_r5.json"
 root.add_child(stage)
 await process_frame
 var actor=stage.actors.nemi.node
 var rows=[]
 for t in [135.688147,135.688148,135.708148,135.808148,135.928148,137.288148,137.488148,137.768147,137.768148,137.768149,137.788148,137.898148,138.418147,138.418148,138.418149,138.438148,140.228148,142.468147,142.468148,147.128148,148.738148,150.19]:
  stage.sample(t)
  var phone:Node2D=null
  for entry in stage.pictures:
   if entry.spec.kind=="phone" and float(entry.spec.at)>100:
    phone=entry.node
  var hand=actor.right_hand_bone
  var contact_error=hand.to_global(Vector2(0,8)).distance_to(phone.to_global(Vector2(0,11)))
  var row={"at":t,"shot":stage.current_shot,"hand_actor_local":xy(actor.to_local(hand.global_position)),
   "hand_world":xy(stage.world.to_local(hand.global_position)),"hand_angle":rad_to_deg(hand.global_rotation),
   "right_hand_pose":actor.right_hand_visual.hand_pose,"phone_visible":phone.visible,
   "phone_world":xy(stage.world.to_local(phone.global_position)),"phone_tilt":phone.rotation_degrees,
   "phone_bottom_world_y":stage.world.to_local(phone.to_global(Vector2(25,0))).y,
   "grip_socket_distance_screen_pixels":contact_error,
   "left_foot_world":xy(stage.world.to_local(actor.left_foot_bone.global_position)),
   "right_foot_world":xy(stage.world.to_local(actor.right_foot_bone.global_position)),"caption":stage.caption.text}
  rows.append(row)
 print("TIMING_STAGE ",JSON.stringify(rows))
 quit()

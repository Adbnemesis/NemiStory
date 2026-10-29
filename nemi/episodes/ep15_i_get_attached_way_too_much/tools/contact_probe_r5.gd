extends SceneTree
const Acting=preload('res://common/storytime/production/ActingTimeline.gd')
const Hands=preload('res://common/storytime/production/HandPaths.gd')
func _initialize():
 call_deferred('probe')
func probe():
 var actor=load('res://nemi/characters/nemi/nemi.tscn').instantiate()
 root.add_child(actor)
 actor.process_mode=Node.PROCESS_MODE_DISABLED
 actor.position=Vector2(1110,533.25)
 actor.scale=Vector2.ONE*1.75
 var acting=Acting.new()
 acting.bind(actor,'nemi')
 acting.sample(actor,'nemi',[{'at':0,'recipe':'recover','hands':{'left':'relaxed','right':'hold_prop'}}],0)
 print('RECIPE_HAND_LOCAL ',actor.to_local(actor.right_hand_bone.global_position),' ANGLE ',actor.right_hand_bone.global_rotation_degrees)
 Hands.sample(actor,'nemi',{'right':[{'at':0,'position':[65,-29.785714],'angle':90}]},0)
 var hand=actor.right_hand_bone
 var phone_position=hand.to_global(Vector2(0,8))-Transform2D(deg_to_rad(90),Vector2.ZERO).basis_xform(Vector2(0,11)*1.155)
 print('CONTACT_PROBE hand=',hand.global_position,' restphone=',phone_position,' feet=',actor.right_foot_bone.global_position)
 quit()

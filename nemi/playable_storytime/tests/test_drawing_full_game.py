"""A drawing-world movie must retain real whole-file YouTube digit routes."""
import copy
import importlib.util
from pathlib import Path
import unittest
import sys

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('drawing_full_validation',ROOT/'tools/validate_episode.py')
validation=importlib.util.module_from_spec(spec);spec.loader.exec_module(validation)
sys.path.insert(0,str(ROOT/'tools'))
render_spec=importlib.util.spec_from_file_location('drawing_full_render',ROOT/'tools/render.py')
render=importlib.util.module_from_spec(render_spec);render_spec.loader.exec_module(render)


def fixture():
    objects=[
        {'id':'door','author':'nemi','kind':'sketch_door','x':1420,'y':610,'text':'1 TRY THE DOOR'},
        {'id':'tear','author':'nemi','kind':'page_tear','x':500,'y':610,'text':'2 TAKE THE TEAR'},
        {'id':'bridge','author':'nemi','kind':'sketch_bridge','x':1420,'y':720,'text':'4 RUN ACROSS'},
        {'id':'tab','author':'nemi','kind':'paper_tab','x':500,'y':720,'text':'5 FOLD THE TAB'},
        {'id':'eraser','author':'nemi','kind':'eraser','x':1000,'y':820,'text':'8 RIDE IT'},
        {'id':'edge','author':'nemi','kind':'page_edge','x':1000,'y':750},
        {'id':'desk','author':'nemi','kind':'studio_desk','x':960,'y':720},
    ]
    scenes=[]
    for key in range(10):
        walls=[{'index':index,'objects':[]} for index in range(4)]
        walls[0]['objects']=copy.deepcopy(objects)
        scenes.append({'id':f's{key}','start':key*24,'end':(key+1)*24,
            'location':'sketchbook','actor_wall':0,'walls':walls})
    navigation={'mode':'youtube_digits','key_targets':[{'key':key,'chapter':f's{key}'} for key in range(10)]}
    timeline={'duration':240,'fps':30,'world_renderer':'drawing','world_continuity':True,
        'navigation':copy.deepcopy(navigation),'scenes':scenes}
    choices={0:[1,2],1:[2],3:[4,5],4:[5],6:[7,8],7:[8]}
    labels={1:'Try the door',2:'Take the tear',4:'Run across',5:'Fold the tab',7:'Race it',8:'Ride it'}
    timeline['interaction_scenes']=[{'id':f's{key}','start':key*24,'end':(key+1)*24,
        'objective':'Help Nemi get off the page',
        'choices':[{'key':answer,'label':labels[answer],'chapter':f's{answer}'} for answer in choices.get(key,[])]}
        for key in range(10)]
    challenges=[]
    for index,(start,end,solution,wrong,clue,label) in enumerate([
        (0,24,2,1,'tear','2 TAKE THE TEAR'),
        (72,96,5,4,'tab','5 FOLD THE TAB'),
        (144,168,8,7,'eraser','8 RIDE IT'),
    ]):
        challenges.append({'id':f'choice_{index}','start':start,'end':end,'state_tracking':False,
            'objective':'Reach a physical route off the page','instructions':'Look around, then press one offered number',
            'visual_change':'The selected authored outcome plays','success':'The useful route opens',
            'retry_method':f'Press {solution} for the useful route','do_nothing':'The failed attempt rewinds and passive playback continues',
            'wrong_answer':'A comic physical failure and rewind play','device_limitations':['Desktop keyboard focus; mobile chapters'],
            'valid_destinations':[solution*24],'alternative_outcomes':[wrong*24],
            'solution_key':solution,'retry_key':solution,'alternative_keys':[wrong],
            'solution':label,'clue_id':clue,'hints':[]})
    game={'duration':240,'automatic_state':False,'navigation':navigation,'challenges':challenges,
        'interaction_scenes':copy.deepcopy(timeline['interaction_scenes']),
        'routes':[{'id':'main','times':[0,48,120,192]},
            {'id':'passive','times':[key*24 for key in range(10)]},
            {'id':'failures','times':[0,24,48,72,96,120,144,168,192,216]}]}
    return timeline,game


class DrawingFullGameTests(unittest.TestCase):
    def test_full_drawing_movie_keeps_the_actual_percentage_map(self):
        timeline,game=fixture();result=validation.check_data(timeline,game)
        self.assertEqual(result['world_renderer'],'drawing')
        self.assertEqual({key:item['at'] for key,item in result['digit_map'].items()},
            {key:key*24 for key in range(10)})
        self.assertEqual([route['landings'] for route in result['routes'] if route['id']=='main'],[[0,48,120,192]])

    def test_only_six_story_choice_keys_are_advertised(self):
        timeline,game=fixture();result=validation.check_data(timeline,game)
        shown={key for prompt in result['interaction_prompts'] for key in prompt['choice_keys']}
        self.assertEqual(shown,{1,2,4,5,7,8})
        self.assertTrue({3,6,9}.issubset(result['digit_map']))

    def test_enhanced_preview_turns_are_explicit_and_have_bounded_targets(self):
        timeline,game=fixture();timeline['preview_choice_turns']=True
        for scene in timeline['scenes']:scene['review_yaw']=0
        timeline['scenes'][1]['review_yaw']=-76;timeline['scenes'][2]['review_yaw']=76
        validation.check_data(timeline,game)
        for edit in ['non_boolean','missing_yaw','nan_yaw','outside_yaw','school']:
            data=copy.deepcopy(timeline)
            if edit=='non_boolean':data['preview_choice_turns']=1
            if edit=='missing_yaw':data['scenes'][3].pop('review_yaw')
            if edit=='nan_yaw':data['scenes'][3]['review_yaw']=float('nan')
            if edit=='outside_yaw':data['scenes'][3]['review_yaw']=181
            if edit=='school':data['world_renderer']='school'
            with self.subTest(edit=edit),self.assertRaises(ValueError):validation.check_data(data,game)

    def test_supported_drawing_event_kinds_keep_named_bounded_scene_clock(self):
        for kind in validation.WORLD_EVENT_KINDS['drawing']:
            timeline,game=fixture();timeline['scenes'][0]['environment_events']=[
                {'id':'action','object':'eraser','kind':kind,'at':2,'end':4.5,'event':'canonical_action'}]
            with self.subTest(kind=kind):validation.check_data(timeline,game)

    def test_school_kinds_and_events_do_not_leak_into_drawing_world(self):
        for field,value in [('object','locker'),('event','clock_tick')]:
            timeline,game=fixture()
            if field=='object':timeline['scenes'][0]['walls'][0]['objects'][0]['kind']=value
            else:timeline['scenes'][0]['environment_events']=[
                {'id':'action','object':'eraser','kind':value,'at':2,'end':3,'event':'canonical_action'}]
            with self.subTest(field=field),self.assertRaisesRegex(ValueError,'Unknown'):
                validation.check_data(timeline,game)

    def test_drawing_kinds_and_events_do_not_leak_into_default_school_world(self):
        timeline,game=fixture();timeline.pop('world_renderer');timeline.pop('world_continuity')
        with self.assertRaisesRegex(ValueError,'Unknown drawable'):validation.check_data(timeline,game)

    def test_drawing_movie_still_rejects_wrong_digit_landing_and_fake_state(self):
        for edit in ['landing','state','unoffered_answer']:
            timeline,game=fixture()
            if edit=='landing':timeline['scenes'][2]['start']+=1;timeline['scenes'][1]['end']+=1
            if edit=='state':game['automatic_state']=True
            if edit=='unoffered_answer':timeline['interaction_scenes'][0]['choices'].pop();game['interaction_scenes']=copy.deepcopy(timeline['interaction_scenes'])
            with self.subTest(edit=edit),self.assertRaises(ValueError):validation.check_data(timeline,game)

    def test_world_motion_still_requires_existing_target_named_event_and_lifetime(self):
        for changes in [{'object':'missing'},{'event':''},{'end':10.1},{'at':-1}]:
            timeline,game=fixture();timeline['scenes'][0]['environment_events']=[
                {'id':'action','object':'eraser','kind':'eraser_pass','at':2,'end':4.5,'event':'canonical_action',**changes}]
            with self.subTest(changes=changes),self.assertRaises(ValueError):validation.check_data(timeline,game)

    def test_only_eraser_travel_may_use_the_eight_second_window(self):
        for kind,end,accepted in [('eraser_pass',10,True),('eraser_pass',10.001,False),
                ('tab_fold',4.5,True),('tab_fold',4.501,False),('bridge_break',10,False)]:
            timeline,game=fixture();timeline['scenes'][0]['environment_events']=[
                {'id':'action','object':'eraser','kind':kind,'at':2,'end':end,'event':'canonical_action'}]
            with self.subTest(kind=kind,end=end):
                if accepted:validation.check_data(timeline,game)
                else:
                    with self.assertRaisesRegex(ValueError,'lifetime'):validation.check_data(timeline,game)


def grouped_fixture():
    timeline,game=fixture();timeline.pop('world_continuity')
    for index,scene in enumerate(timeline['scenes']):
        group=['room','gap','edge','studio'][min(index//3,3)]
        scene['continuity_group']=group
        shift=min(index//3,3)*10
        for wall in scene['walls']:
            for obj in wall['objects']:obj['x']+=shift
    return timeline,game


class DrawingContinuityGroupTests(unittest.TestCase):
    def test_separate_sets_have_independent_matching_layouts(self):
        timeline,game=grouped_fixture();result=validation.check_data(timeline,game)
        self.assertEqual(result['continuity_groups'],['edge','gap','room','studio'])
        self.assertNotEqual(timeline['scenes'][0]['walls'],timeline['scenes'][3]['walls'])

    def test_groups_cannot_be_mixed_with_global_continuity(self):
        timeline,game=grouped_fixture();timeline['world_continuity']=True
        with self.assertRaisesRegex(ValueError,'cannot be mixed'):validation.check_data(timeline,game)

    def test_every_scene_in_grouped_mode_has_a_valid_name(self):
        for value in [None,'',' room',False,5,'x'*65]:
            timeline,game=grouped_fixture()
            if value is None:timeline['scenes'][1].pop('continuity_group')
            else:timeline['scenes'][1]['continuity_group']=value
            with self.subTest(value=value),self.assertRaisesRegex(ValueError,'continuity_group'):
                validation.check_data(timeline,game)

    def test_layout_changes_are_rejected_only_within_the_same_group(self):
        timeline,game=grouped_fixture();timeline['scenes'][1]['walls'][0]['objects'][0]['x']+=1
        with self.assertRaisesRegex(ValueError,'continuity group'):validation.check_data(timeline,game)
        timeline,game=grouped_fixture()
        for scene in timeline['scenes'][3:6]:scene['walls'][0]['objects'][0]['x']+=1
        validation.check_data(timeline,game)

    def test_grouped_events_keep_global_unique_canonical_identities(self):
        timeline,game=grouped_fixture()
        for index in [0,3]:
            scene=timeline['scenes'][index];scene['environment_events']=[
                {'id':'same','object':'eraser','kind':'eraser_pass','at':scene['start']+2,
                 'end':scene['start']+8,'event':f'canonical_{index}'}]
        with self.assertRaisesRegex(ValueError,'unique nonempty IDs'):validation.check_data(timeline,game)

    def test_school_timeline_cannot_acquire_drawing_group_state(self):
        timeline,game=grouped_fixture();timeline['world_renderer']='school'
        for scene in timeline['scenes']:
            for wall in scene['walls']:
                for obj in wall['objects']:obj['kind']='door'
        with self.assertRaisesRegex(ValueError,'only by the drawing'):validation.check_data(timeline,game)


def transport_fixture():
    timeline,game=grouped_fixture();scene=timeline['scenes'][8]
    # The already-aboard ride is a distinct authored set/cut.
    scene['continuity_group']='ride';scene['actor_wall']=1
    scene['walls'][1]['objects'].append({'id':'ride_eraser','kind':'ride_eraser','author':'nemi',
        'x':650,'y':780,'path':[{'at':198,'position':[650,780]},{'at':206,'position':[1150,780]}]})
    scene['environment_events']=[{'id':'ride_travel_action','kind':'eraser_pass','object':'ride_eraser',
        'at':198,'end':206,'event':'ride_travel'}]
    scene['actor_transport']={'actor':'nemi','object':'ride_eraser','event':'ride_travel'}
    spec={'actors':[{'id':'nemi','author':'nemi'}],
        'shots':[{'id':scene['id'],'start':scene['start'],'end':scene['end'],
            'camera':{'center':[960,540],'zoom':1}}]}
    return timeline,game,scene,spec


class ActorTransportTests(unittest.TestCase):
    def test_transport_reuses_one_vehicle_path_and_canonical_event(self):
        timeline,game,scene,spec=transport_fixture()
        validation.check_data(timeline,game)
        target=validation.validate_actor_transport(scene,'drawing',{'ride_travel':198},spec)
        self.assertEqual(target['id'],'ride_eraser')
        render.validate_environment_events(scene,{'ride_travel':198},'drawing')

    def test_transport_requires_unique_matching_vehicle_on_actor_wall(self):
        for edit in ['missing','duplicate','wrong_wall','wrong_kind','no_path','wrong_actor','extra_field']:
            timeline,game,scene,spec=transport_fixture();target=scene['walls'][1]['objects'][-1]
            if edit=='missing':scene['actor_transport']['object']='unknown'
            if edit=='duplicate':scene['walls'][0]['objects'].append(copy.deepcopy(target))
            if edit=='wrong_wall':scene['actor_wall']=3
            if edit=='wrong_kind':target['kind']='eraser'
            if edit=='no_path':target.pop('path')
            if edit=='wrong_actor':scene['actor_transport']['actor']='adb'
            if edit=='extra_field':scene['actor_transport']['auto_walk']=True
            with self.subTest(edit=edit),self.assertRaises(ValueError):validation.check_data(timeline,game)

    def test_path_requires_finite_increasing_in_scene_base_aligned_points(self):
        for edit in ['empty','single','same_time','backward','nan','position_nan','off_canvas',
                'early','late','wrong_base','bend','extra_field','long']:
            timeline,game,scene,spec=transport_fixture();target=scene['walls'][1]['objects'][-1]
            path=target['path']
            if edit=='empty':target['path']=[]
            if edit=='single':target['path']=path[:1]
            if edit=='same_time':path[1]['at']=198
            if edit=='backward':path[1]['at']=197
            if edit=='nan':path[1]['at']=float('nan')
            if edit=='position_nan':path[1]['position'][0]=float('nan')
            if edit=='off_canvas':path[1]['position'][0]=1920
            if edit=='early':path[0]['at']=191
            if edit=='late':path[1]['at']=217
            if edit=='wrong_base':path[0]['position'][0]=651
            if edit=='bend':path[1]['bend']=[0,-30]
            if edit=='extra_field':path[1]['speed']=1
            if edit=='long':path[1]['at']=207
            with self.subTest(edit=edit),self.assertRaises(ValueError):validation.check_data(timeline,game)

    def test_path_and_transport_must_share_the_exact_eraser_event_endpoints(self):
        for edit in ['start','end','name','kind','duplicate']:
            timeline,game,scene,spec=transport_fixture();event=scene['environment_events'][0]
            if edit=='start':event['at']=199
            if edit=='end':event['end']=205
            if edit=='name':event['event']='other_canonical_event'
            if edit=='kind':event['kind']='escape_reveal'
            if edit=='duplicate':scene['environment_events'].append(copy.deepcopy(event))
            with self.subTest(edit=edit),self.assertRaises(ValueError):validation.check_data(timeline,game)

    def test_renderer_binds_transport_to_exact_production_clock_and_single_actor_stage(self):
        for edit in ['missing_event','wrong_time','wrong_author','extra_actor','missing_shot','zoom','camera_path']:
            timeline,game,scene,spec=transport_fixture();events={'ride_travel':198}
            if edit=='missing_event':events={}
            if edit=='wrong_time':events['ride_travel']=198.01
            if edit=='wrong_author':spec['actors'][0]['author']='adb'
            if edit=='extra_actor':spec['actors'].append({'id':'guest','author':'adb'})
            if edit=='missing_shot':spec['shots']=[]
            if edit=='zoom':spec['shots'][0]['camera']['zoom']=1.2
            if edit=='camera_path':spec['shots'][0]['camera']['path']=[]
            with self.subTest(edit=edit),self.assertRaises(ValueError):
                validation.validate_actor_transport(scene,'drawing',events,spec)

    def test_renderer_uses_per_kind_finite_lifetime(self):
        timeline,game,scene,spec=transport_fixture()
        render.validate_environment_events(scene,{'ride_travel':198},'drawing')
        scene['environment_events'][0]['end']=206.01
        with self.assertRaisesRegex(ValueError,'finite bounded'):render.validate_environment_events(scene,{'ride_travel':198},'drawing')


if __name__=='__main__':unittest.main()

"""Final measured words must own acting/reaction timing and director framing."""
import copy
import importlib.util
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('performance_compiler',ROOT/'tools/prepare_episode.py')
compiler=importlib.util.module_from_spec(spec);spec.loader.exec_module(compiler)

def fixture():
    words={'voice_a':[{'word':'Wait,','start':25.1,'end':25.45},
        {'word':'qualifications?','start':26.2,'end':26.85},
        {'word':'Wait.','start':27.1,'end':27.6}]}
    chapter={'id':'sandwich','start':24,'end':48,'lines':[{'id':'voice_a'}]}
    beat={'id':'inspect_lunch','clip_id':'voice_a','word':'qualifications',
        'offset':-.06,'recipe':'skeptical','duration':.42,
        'gaze':[-.55,0],'hands':{'right':'open_palm_up'},
        'intent':'Interview lunch like an applicant'}
    return words,chapter,beat

class PerformanceCompilerTests(unittest.TestCase):
    def test_chapter_does_not_require_persistent_heading_or_prop(self):
        chapter={'id':'reaction','start':24,'end':48}
        for value in [None,'','   ',7]:
            self.assertEqual(compiler.chapter_plates({**chapter,'drawing':value,'prop':value}),([],[]))
        self.assertEqual(compiler.chapter_plates(chapter),([],[]))

    def test_existing_chapter_plates_keep_their_shot_and_clock(self):
        chapter={'id':'reaction','start':24,'end':48,'drawing':'Read the fine print','prop':'clipboard','heading_size':34}
        drawings,props=compiler.chapter_plates(chapter)
        self.assertEqual(drawings[0]['text'],'Read the fine print')
        self.assertEqual(drawings[0]['size'],34)
        self.assertEqual(props[0]['kind'],'clipboard')
        for item in drawings+props:
            self.assertEqual((item['at'],item['end']),(24,48))
            self.assertEqual(item['shots'],['reaction'])

    def test_additional_art_retains_v2_fields_and_uses_measured_event(self):
        art={'author':'nemi','kind':'clipboard','at':0,'end':31,'position':[1100,520],
             'mode':'hold','scale':[.8,.8],'shots':['reaction'],'event':'acting_evidence','event_offset':.12}
        result=compiler.resolve_art_event(art,{'acting_evidence':26.14})
        self.assertEqual(result,{**art,'at':26.26})
        self.assertEqual(art['at'],0)
        result['position'][0]=1200
        self.assertEqual(art['position'],[1100,520])
        with self.assertRaisesRegex(ValueError,'missing event'):
            compiler.resolve_art_event(art,{})

    def test_line_keeps_recipe_gaze_and_hands_when_unset(self):
        cue=compiler.performance_cue({'recipe':'skeptical'},25)
        self.assertNotIn('gaze',cue);self.assertNotIn('hands',cue)
        self.assertNotIn('blinks',cue);self.assertEqual(cue['duration'],.34)

    def test_authored_cadence_and_face_are_preserved_independently(self):
        line={'recipe':'realization','duration':.7,'motion':'stepped','step_fps':10,
            'gaze':[-.4,0],'face':{'pupil_scale':.65},'hands':{'right':'open'},'blinks':[27.2]}
        cue=compiler.performance_cue(line,26)
        self.assertEqual(cue['motion'],'stepped');self.assertEqual(cue['step_fps'],10)
        cue['face']['pupil_scale']=1.2
        self.assertEqual(line['face']['pupil_scale'],.65)

    def test_anchor_matches_punctuation_and_selects_occurrence(self):
        words,_,_=fixture()
        self.assertEqual(compiler.measured_anchor({'clip_id':'voice_a','word':'WAIT','occurrence':1,'offset':.08},words),27.18)

    def test_stale_or_ambiguous_anchor_fails_explicitly(self):
        words,_,_=fixture()
        for item in [{'clip_id':'gone','word':'Wait'},
                     {'clip_id':'voice_a','word':'missing'},
                     {'clip_id':'voice_a','word':'Wait','occurrence':2}]:
            with self.assertRaisesRegex(ValueError,'missing'):compiler.measured_anchor(item,words)

    def test_invalid_occurrence_and_large_offset_rejected(self):
        words,_,_=fixture()
        for extra in [{'occurrence':-1},{'occurrence':True},{'offset':2.01},{'offset':float('nan')}]:
            with self.assertRaises(ValueError):compiler.measured_anchor({'clip_id':'voice_a','word':'Wait',**extra},words)

    def test_acting_event_and_cue_share_final_word_time(self):
        words,chapter,beat=fixture()
        cues,events=compiler.anchored_acting([beat],words,[chapter])
        self.assertEqual(cues[0]['at'],26.14)
        self.assertEqual(cues[0]['event'],events[0]['id'])
        self.assertEqual(events[0]['at'],26.14)
        self.assertEqual(cues[0]['gaze'],[-.55,0])
        self.assertNotIn('clip_id',cues[0]);self.assertNotIn('word',cues[0])

    def test_acting_cannot_cross_chapter_or_duplicate_landing(self):
        words,chapter,beat=fixture()
        with self.assertRaisesRegex(ValueError,'leaves its chapter'):
            compiler.anchored_acting([{**beat,'duration':23}],words,[chapter])
        duplicate={**copy.deepcopy(beat),'id':'another_thought'}
        with self.assertRaisesRegex(ValueError,'share a time'):
            compiler.anchored_acting([beat,duplicate],words,[chapter])

    def test_unknown_acting_controls_do_not_silently_disappear(self):
        words,chapter,beat=fixture()
        with self.assertRaisesRegex(ValueError,'Unknown anchored acting field'):
            compiler.anchored_acting([{**beat,'root_bobbing':True}],words,[chapter])

    def test_camera_anchors_whole_world_projection_without_stage_scale(self):
        words,chapter,_=fixture()
        beats=[{'clip_id':'voice_a','word':'qualifications','yaw':0,'fov':50,
                'duration':.18,'intent':'Read her suspicious reaction'}]
        result=compiler.anchored_camera(beats,words,chapter)
        self.assertEqual(result,[{'at':26.2,'yaw':0,'pitch':0,'fov':50,'duration':.18,'intent':'Read her suspicious reaction'}])
        self.assertNotIn('center',result[0]);self.assertNotIn('zoom',result[0])

    def test_whole_world_portrait_preserves_authored_pitch(self):
        words,chapter,_=fixture()
        result=compiler.anchored_camera([{'clip_id':'voice_a','word':'qualifications',
            'yaw':-8,'pitch':16,'fov':34,'duration':.18,'intent':'Read the tight face reaction'}],words,chapter)
        self.assertEqual((result[0]['yaw'],result[0]['pitch'],result[0]['fov']),(-8,16,34))

    def test_camera_cannot_borrow_another_chapter_voice(self):
        words,chapter,_=fixture();chapter['lines']=[{'id':'different_voice'}]
        with self.assertRaisesRegex(ValueError,'from its chapter'):
            compiler.anchored_camera([{'clip_id':'voice_a','word':'Wait','yaw':0,'fov':60,'intent':'Reaction'}],words,chapter)

    def test_camera_transition_order_and_projection_bounds_rejected(self):
        words,chapter,_=fixture()
        beat={'clip_id':'voice_a','word':'Wait','yaw':0,'fov':60,'duration':2,'intent':'Reaction'}
        with self.assertRaisesRegex(ValueError,'overlapping'):
            compiler.anchored_camera([beat,{**beat,'word':'qualifications'}],words,chapter)
        for extra in [{'fov':33},{'yaw':181},{'pitch':26},{'pitch':-26},{'duration':24},{'intent':''},{'zoom':2}]:
            with self.assertRaises(ValueError):compiler.anchored_camera([{**beat,**extra}],words,chapter)

if __name__=='__main__':unittest.main()

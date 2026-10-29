"""Guard baked entry feedback and the actual scene choices shown to viewers."""
import copy
import importlib.util
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('entry_validation',ROOT/'tools/validate_episode.py')
validation=importlib.util.module_from_spec(spec);spec.loader.exec_module(validation)

def fixture():
    scenes=[];prompts=[]
    for key in range(10):
        scene_id=f's{key}';start=key*24;end=(key+1)*24
        scenes.append({'id':scene_id,'start':start,'end':end,
            'walls':[{'index':index,'objects':[]} for index in range(4)],
            'entry_card':{'duration':3.5,'title':f'{key} ROUTE READY','subtitle':'FOLLOW THE CLUE'}})
        prompts.append({'id':scene_id,'start':start,'end':end,'objective':'Find the route number',
            'choices':[{'key':(key+1)%10,'label':'Continue','chapter':f's{(key+1)%10}'}],
            'feedback':'This route continues the story'})
    navigation={'mode':'youtube_digits','key_targets':[{'key':key,'chapter':f's{key}'} for key in range(10)]}
    timeline={'duration':240,'fps':30,'scenes':scenes,'navigation':copy.deepcopy(navigation),
        'interaction_scenes':prompts}
    game={'duration':240,'automatic_state':False,'challenges':[],'routes':[],
        'navigation':navigation,'interaction_scenes':copy.deepcopy(prompts)}
    return timeline,game

class EntryInteractionContractTests(unittest.TestCase):
    def setUp(self):self.timeline,self.game=fixture()
    def check(self):return validation.check_data(self.timeline,self.game)
    def remove_mirror(self):self.game.pop('interaction_scenes')
    def test_complete_entry_and_choice_contract(self):
        self.assertEqual(len(self.check()['interaction_prompts']),10)
    def test_entry_hold_too_short_rejected(self):
        self.timeline['scenes'][0]['entry_card']['duration']=1.9
        with self.assertRaisesRegex(ValueError,'2–4'):self.check()
    def test_entry_hold_too_long_rejected(self):
        self.timeline['scenes'][0]['entry_card']['duration']=4.1
        with self.assertRaisesRegex(ValueError,'2–4'):self.check()
    def test_entry_title_must_fit(self):
        self.timeline['scenes'][0]['entry_card']['title']='one two three four five six seven eight nine'
        with self.assertRaisesRegex(ValueError,'title.*too long'):self.check()
    def test_entry_subtitle_must_be_one_line(self):
        self.timeline['scenes'][0]['entry_card']['subtitle']='FIRST\nSECOND'
        with self.assertRaisesRegex(ValueError,'one line'):self.check()
    def test_every_scene_needs_one_prompt(self):
        self.remove_mirror();self.timeline['interaction_scenes'].pop()
        with self.assertRaisesRegex(ValueError,'every scene'):self.check()
    def test_prompt_must_cover_full_scene(self):
        self.remove_mirror();self.timeline['interaction_scenes'][0]['end']=23.8
        with self.assertRaisesRegex(ValueError,'complete scene interval'):self.check()
    def test_choice_destination_must_match_native_key(self):
        self.remove_mirror();self.timeline['interaction_scenes'][0]['choices'][0]['chapter']='s6'
        with self.assertRaisesRegex(ValueError,'actual digit destination'):self.check()
    def test_three_choices_rejected(self):
        self.remove_mirror();self.timeline['interaction_scenes'][0]['choices']=[
            {'key':key,'label':'Route','chapter':f's{key}'} for key in [1,2,3]]
        with self.assertRaisesRegex(ValueError,'at most two'):self.check()
    def test_duplicate_choice_key_rejected(self):
        self.remove_mirror();choices=self.timeline['interaction_scenes'][0]['choices'];choices.append(copy.deepcopy(choices[0]))
        with self.assertRaisesRegex(ValueError,'duplicated'):self.check()
    def test_automatic_answer_detection_field_rejected(self):
        self.remove_mirror();self.timeline['interaction_scenes'][0]['detect_answer']=True
        with self.assertRaisesRegex(ValueError,'automatic detection'):self.check()
    def test_zero_choices_and_replay_at_end_are_valid(self):
        self.remove_mirror();self.timeline['interaction_scenes'][0]['choices']=[]
        self.timeline['interaction_scenes'][-1]['choices']=[{'key':0,'label':'Replay','chapter':'s0'}]
        self.assertEqual(self.check()['interaction_prompts'][-1]['choice_keys'],[0])
    def test_challenge_answer_must_be_an_offered_choice(self):
        self.remove_mirror()
        for scene in self.timeline['scenes']:
            scene['walls'][0]['objects']=[{'id':'badge','kind':'badge','author':'nemi','x':960,'y':500,'text':'3 USE BADGE'}]
        self.game['challenges']=[{'id':'badge','start':24,'end':48,'state_tracking':False,
            'objective':'Find badge','instructions':'Use the badge','visual_change':'The route plays',
            'success':'Badge route','retry_method':'Press 1 to retry','do_nothing':'Story continues',
            'wrong_answer':'Try another route','device_limitations':['Desktop keys need focus'],
            'valid_destinations':[72],'alternative_outcomes':[],'solution_key':3,'retry_key':1,
            'alternative_keys':[],'solution':'3 USE BADGE','clue_id':'badge','hints':[]}]
        with self.assertRaisesRegex(ValueError,'offered by an interaction choice'):self.check()
        self.timeline['interaction_scenes'][1]['choices']=[{'key':3,'label':'Use badge','chapter':'s3'}]
        self.assertEqual(self.check()['interaction_prompts'][1]['choice_keys'],[3])
    def test_optional_contracts_preserve_existing_scenes(self):
        del self.timeline['interaction_scenes'];self.remove_mirror()
        for scene in self.timeline['scenes']:del scene['entry_card']
        self.assertEqual(self.check()['interaction_prompts'],[])

if __name__=='__main__':unittest.main()

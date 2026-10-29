"""Reject route contracts that cannot land on YouTube's actual digit jumps."""
import copy
import importlib.util
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('digit_validation',ROOT/'tools/validate_episode.py')
validation=importlib.util.module_from_spec(spec);spec.loader.exec_module(validation)

def fixture():
    scenes=[]
    for key in range(10):
        walls=[{'index':index,'objects':[]} for index in range(4)]
        walls[0]['objects']=[{'id':'badge','kind':'badge','author':'nemi','x':960,'y':500,'text':'PRESS 3'}]
        scenes.append({'id':f's{key}','start':key*24,'end':(key+1)*24,'walls':walls})
    timeline={'duration':240,'fps':30,'scenes':scenes}
    navigation={'mode':'youtube_digits','key_targets':[{'key':key,'chapter':f's{key}'} for key in range(10)]}
    timeline['navigation']=copy.deepcopy(navigation)
    challenge={'id':'badge','start':24,'end':72,'state_tracking':False,'objective':'Find badge',
        'instructions':'Find its number and press it','visual_change':'View rotates; key changes video position',
        'success':'The badge route plays','retry_method':'Press 1 to retry','do_nothing':'Hints continue',
        'wrong_answer':'Choose another route or retry','device_limitations':['Desktop player focus required'],
        'valid_destinations':[72],'alternative_outcomes':[120],'solution_key':3,'retry_key':1,
        'alternative_keys':[5],'solution':'PRESS 3','clue_id':'badge','hints':[{'at':48}]}
    game={'duration':240,'automatic_state':False,'navigation':navigation,'challenges':[challenge],
        'routes':[{'id':'success','times':[0,24,72]}]}
    return timeline,game

class DigitNavigationTests(unittest.TestCase):
    def setUp(self):self.timeline,self.game=fixture()
    def test_exact_percentage_landings(self):
        result=validation.check_data(self.timeline,self.game)
        self.assertEqual(result['digit_map'][9],{'chapter':'s9','at':216})
        self.assertEqual(result['digit_map'][0]['at'],0)
    def test_misaligned_chapter_rejected(self):
        self.timeline['scenes'][3]['start']=73;self.timeline['scenes'][2]['end']=73
        with self.assertRaisesRegex(ValueError,'percentage landing'):validation.check_data(self.timeline,self.game)
    def test_answer_must_match_key_destination(self):
        self.game['challenges'][0]['solution_key']=6
        with self.assertRaisesRegex(ValueError,'Answer key'):validation.check_data(self.timeline,self.game)
    def test_retry_text_must_match_key(self):
        self.game['challenges'][0]['retry_method']='Press 4 to retry'
        with self.assertRaisesRegex(ValueError,'Retry'):validation.check_data(self.timeline,self.game)
    def test_alternative_must_match_key(self):
        self.game['challenges'][0]['alternative_keys']=[6]
        with self.assertRaisesRegex(ValueError,'Alternative keys'):validation.check_data(self.timeline,self.game)
    def test_duplicate_key_rejected(self):
        self.game['navigation']['key_targets'][9]['key']=8
        with self.assertRaisesRegex(ValueError,'unique'):validation.check_data(self.timeline,self.game)
    def test_bool_is_not_a_key(self):
        self.game['challenges'][0]['solution_key']=True
        with self.assertRaisesRegex(ValueError,'invalid challenge digit'):validation.check_data(self.timeline,self.game)
    def test_answer_cannot_also_be_wrong_alternative(self):
        self.game['challenges'][0]['alternative_keys']=[3]
        with self.assertRaisesRegex(ValueError,'wrong alternative'):validation.check_data(self.timeline,self.game)
    def test_digit_outcome_label_is_supported(self):
        self.game['challenges'][0]['solution']='3 USE BADGE'
        for scene in self.timeline['scenes']:scene['walls'][0]['objects'][0]['text']='STAR\n3 USE BADGE'
        self.assertEqual(validation.check_data(self.timeline,self.game)['digit_map'][3]['at'],72)
    def test_wrong_leading_digit_in_outcome_label_rejected(self):
        self.game['challenges'][0]['solution']='6 USE BADGE'
        with self.assertRaisesRegex(ValueError,'Printed solution'):validation.check_data(self.timeline,self.game)
    def test_outcome_digit_must_be_anchored_and_have_words(self):
        for label in ['3','13 USE BADGE','LOOK FOR 3 USE BADGE','PRESS 13']:
            with self.subTest(label=label):
                self.game['challenges'][0]['solution']=label
                with self.assertRaisesRegex(ValueError,'Printed solution'):validation.check_data(self.timeline,self.game)
    def test_timeline_and_manifest_must_agree(self):
        self.timeline['navigation']['mode']='timestamp'
        with self.assertRaisesRegex(ValueError,'disagree'):validation.check_data(self.timeline,self.game)
    def test_legacy_timestamp_contract_remains_supported(self):
        del self.game['navigation'];del self.timeline['navigation']
        challenge=self.game['challenges'][0];challenge['retry_method']='Seek to 0:24';challenge['solution']='1:12'
        for scene in self.timeline['scenes']:scene['walls'][0]['objects'][0]['text']='1:12'
        self.assertIsNone(validation.check_data(self.timeline,self.game)['digit_map'])

if __name__=='__main__':unittest.main()

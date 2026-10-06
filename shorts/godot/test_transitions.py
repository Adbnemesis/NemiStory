"""Validate authored silhouette/contact limits and exact transition ownership."""
from copy import deepcopy
import json,tempfile,unittest
from pathlib import Path
from validate_ink import ROOT,validate

class TransitionTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.base=validate(ROOT/'shorts/nemi/my-song/short.json')
 def checked(self,change,reject=False):
  config=deepcopy(self.base);change(config)
  with tempfile.TemporaryDirectory() as temp:
   path=Path(temp)/'short.json';path.write_text(json.dumps(config))
   if reject:
    with self.assertRaises(AssertionError):validate(path)
   else:return validate(path)
 def transition(self,config,kind='whip',duration=7):
  shot=config['shots'][1]
  shot['transition']={'kind':kind,'duration':duration,'event':'test-pose-change','direction':1,'focus':[540,800]}
  config['events'].append({'id':'test-pose-change','at':shot['frame'],'end':shot['frame']+duration,'kind':'landing_ticks' if kind=='match' else 'ink_swoosh','animation':'burst','position':[900,800]})
 def test_four_devices_pass(self):
  for kind in ['smear','whip','match','focus_wipe']:
   with self.subTest(kind=kind):self.checked(lambda c:self.transition(c,kind))
 def test_unknown_body_drawing_rejected(self):self.checked(lambda c:c['actors'][0]['cues'][0].update(bodyPose='dance_forever'),True)
 def test_back_body_drawing_rejected(self):self.checked(lambda c:c['actors'][0]['cues'][0].update(bodyPose='crouch',view='back',action='rest'),True)
 def test_folded_phone_rejected(self):self.checked(lambda c:c['actors'][0]['cues'][0].update(bodyPose='folded',action='phone'),True)
 def test_folded_rest_passes(self):self.checked(lambda c:c['actors'][0]['cues'][0].update(bodyPose='folded',view='front',action='rest'))
 def test_folded_chin_rejected(self):self.checked(lambda c:c['actors'][0]['cues'][0].update(bodyPose='folded',action='chin'),True)
 def test_celebrate_rest_rejected(self):self.checked(lambda c:c['actors'][0]['cues'][0].update(bodyPose='celebrate',action='rest'),True)
 def test_missing_transition_event_rejected(self):self.checked(lambda c:c['shots'][1].update(transition={'kind':'whip','duration':7,'event':'absent'}),True)
 def test_blank_opening_transition_rejected(self):self.checked(lambda c:c['shots'][0].update(transition={'kind':'whip','duration':7,'event':'absent'}),True)
 def test_mismatched_window_rejected(self):
  def change(c):self.transition(c);c['events'][-1]['at']+=1
  self.checked(change,True)
 def test_match_needs_focus(self):
  def change(c):self.transition(c,'match');del c['shots'][1]['transition']['focus']
  self.checked(change,True)
 def test_wrong_transition_accent_rejected(self):
  def change(c):self.transition(c);c['events'][-1]['kind']='landing_ticks'
  self.checked(change,True)
 def test_boolean_duration_rejected(self):
  def change(c):self.transition(c);c['shots'][1]['transition']['duration']=True
  self.checked(change,True)
 def test_long_transition_rejected(self):self.checked(lambda c:self.transition(c,duration=13),True)
 def test_static_new_effect_rejected(self):
  def change(c):self.transition(c);c['events'][-1]['animation']='pop'
  self.checked(change,True)
 def test_prebeat_target_passes(self):
  def change(c):self.transition(c);c['shots'][1]['transition']['poseFrame']=c['shots'][1]['frame']+7
  self.checked(change)
 def test_target_after_transition_rejected(self):
  def change(c):self.transition(c);c['shots'][1]['transition']['poseFrame']=c['shots'][1]['frame']+8
  self.checked(change,True)
 def test_boundary_overlap_rejected(self):
  def change(c):self.transition(c);c['shots'][2]['frame']=c['shots'][1]['frame']+6
  self.checked(change,True)
if __name__=='__main__':unittest.main()

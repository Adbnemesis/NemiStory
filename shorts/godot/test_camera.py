"""Finite authored camera paths, shared-clock bounds and strict composition."""
from copy import deepcopy
import json,tempfile,unittest
from pathlib import Path
from validate_ink import ROOT,validate

class CameraTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.base=validate(ROOT/'shorts/nemi/my-song/short.json')
 def camera(self,config):
  shot=config['shots'][0];shot.pop('travel',None)
  shot['camera']={'focus':[540,650],'keys':[{'frame':0,'factor':1,'pan':[0,0],'roll':0,'ease':'linear'},{'frame':config['shots'][1]['frame']-1,'factor':1.07,'pan':[-25,8],'roll':.4,'ease':'smooth'}]}
  return shot['camera']
 def checked(self,change,rejected=False):
  config=deepcopy(self.base);self.camera(config);change(config)
  with tempfile.TemporaryDirectory() as temp:
   path=Path(temp)/'short.json';path.write_text(json.dumps(config))
   if rejected:
    with self.assertRaises(AssertionError):validate(path)
   else:return validate(path)
 def test_finite_camera_passes(self):self.checked(lambda c:None)
 def test_destination_eases_pass(self):
  for ease in ['linear','smooth','in','out']:
   with self.subTest(ease=ease):self.checked(lambda c:c['shots'][0]['camera']['keys'][-1].update(ease=ease))
 def test_crossing_cut_rejected(self):self.checked(lambda c:c['shots'][0]['camera']['keys'][-1].update(frame=c['shots'][1]['frame']),True)
 def test_competing_travel_rejected(self):self.checked(lambda c:c['shots'][0].update(travel={'pan':[5,0],'zoom':1.01,'end':12}),True)
 def test_late_start_rejected(self):self.checked(lambda c:c['shots'][0]['camera']['keys'][0].update(frame=1),True)
 def test_zoom_range_rejected(self):self.checked(lambda c:c['shots'][0]['camera']['keys'][-1].update(factor=1.26),True)
 def test_roll_range_rejected(self):self.checked(lambda c:c['shots'][0]['camera']['keys'][-1].update(roll=-3.1),True)
 def test_pan_range_rejected(self):self.checked(lambda c:c['shots'][0]['camera']['keys'][-1].update(pan=[121,0]),True)
 def test_boolean_clock_rejected(self):self.checked(lambda c:c['shots'][0]['camera']['keys'][0].update(frame=False),True)
 def test_unknown_camera_key_rejected(self):self.checked(lambda c:c['shots'][0]['camera']['keys'][-1].update(loopForever=True),True)
 def test_single_key_rejected(self):self.checked(lambda c:c['shots'][0]['camera'].update(keys=[c['shots'][0]['camera']['keys'][0]]),True)
 def test_motionless_camera_rejected(self):
  def change(c):c['shots'][0]['camera']['keys'][-1].update(factor=1,pan=[0,0],roll=0)
  self.checked(change,True)
if __name__=='__main__':unittest.main()

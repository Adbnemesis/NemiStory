"""Version3 guardrails: motion/contact clocks and decoded actual static output."""
from copy import deepcopy
import json,tempfile,unittest
from pathlib import Path
import cv2,numpy as np
from validate_ink import ROOT,validate
from check_pacing import measure
class DynamicTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.base=validate(ROOT/'shorts/nemi/my-song/short.json')
 def rejected(self,change):
  c=deepcopy(self.base);change(c)
  with tempfile.TemporaryDirectory() as t:
   p=Path(t)/'short.json';p.write_text(json.dumps(c))
   with self.assertRaises(AssertionError):validate(p)
 def test_new_motion_action_passes(self):self.assertTrue(any(q['action']=='heart_hand' for q in self.base['actors'][0]['cues']))
 def test_no_motion_rejected(self):self.rejected(lambda c:c['actors'][0].update(motion=[]))
 def test_head_range_rejected(self):self.rejected(lambda c:c['actors'][0]['motion'][0].update(head=11))
 def test_unknown_motion_rejected(self):self.rejected(lambda c:c['actors'][0]['motion'][0].update(danceLoop=True))
 def test_back_prop_rejected(self):self.rejected(lambda c:c['actors'][0]['cues'][0].update(view='back',action='phone_up'))
 def test_travel_crossing_cut_rejected(self):self.rejected(lambda c:c['shots'][0]['travel'].update(end=c['shots'][1]['frame']))
 def test_long_particle_rejected(self):self.rejected(lambda c:c['events'][0].update(end=c['events'][0]['at']+46,animation='burst'))
 def test_shorter_than_12_seconds_rejected(self):self.rejected(lambda c:c.update(frames=359))
 def test_duplicate_keys_rejected(self):self.rejected(lambda c:c['actors'][0]['motion'][1].update(frame=0))
 def test_decoded_still_fixture_is_detected(self):
  with tempfile.TemporaryDirectory() as t:
   movie=Path(t)/'static.avi';writer=cv2.VideoWriter(str(movie),cv2.VideoWriter_fourcc(*'MJPG'),30,(216,384))
   for i in range(90):writer.write(np.full((384,216,3),180,np.uint8))
   writer.release();report=measure(movie,30)
   self.assertEqual(report['frames'],90);self.assertGreater(report['maxStaticSeconds'],1.5)
if __name__=='__main__':unittest.main()

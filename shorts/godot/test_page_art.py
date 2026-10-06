"""Editable page selection validates without changing the held-page contact API."""
from copy import deepcopy
import json,tempfile,unittest
from pathlib import Path
from validate_ink import ROOT,validate

class PageArtTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.base=validate(ROOT/'shorts/nemi/my-song/short.json')
 def checked(self,value=None,explicit=True):
  config=deepcopy(self.base)
  cue=config['actors'][0]['cues'][0]
  cue.update(action='sketch',bodyPose='neutral',view='front')
  cue.pop('pageArt',None)
  if explicit:cue['pageArt']=value
  with tempfile.TemporaryDirectory() as work:
   path=Path(work)/'short.json';path.write_text(json.dumps(config));return validate(path)
 def test_missing_selector_preserves_default(self):
  self.assertNotIn('pageArt',self.checked(explicit=False)['actors'][0]['cues'][0])
 def test_three_supported_selections(self):
  for art in ['moon','cat','blank']:
   with self.subTest(page=art):self.assertEqual(self.checked(art)['actors'][0]['cues'][0]['pageArt'],art)
 def test_unknown_selection_rejected(self):
  with self.assertRaises(AssertionError):self.checked('live_transform')
 def test_nonstring_selection_rejected(self):
  for art in [True,{},[],None]:
   with self.subTest(value=art):
    with self.assertRaises(AssertionError):self.checked(art)
if __name__=='__main__':unittest.main()

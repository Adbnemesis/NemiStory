"""Keep final exports in their own episode and reject ambiguous legacy folders."""
import unittest
from render_scene import ROOT, allowed_output
class OutputRouting(unittest.TestCase):
    def test_matching_episode_and_studies(self):
        for author in ['nemi','adb']:
            folder=ROOT/author/'episodes/ep09_story'
            self.assertTrue(allowed_output(folder/'scene.json',folder/'renders/camera_1080p.mp4'))
            self.assertTrue(allowed_output(folder/'scene.json',ROOT/'renders/proof/10s.mp4'))
            self.assertFalse(allowed_output(folder/'scene.json',ROOT/author/'episodes/ep10_other/renders/final.mp4'))
            self.assertFalse(allowed_output(folder/'scene.json',folder/'final.mp4'))
            self.assertFalse(allowed_output(folder/'scene.json',folder/'renders/final.avi'))
    def test_legacy_folder_and_path_escape(self):
        legacy=ROOT/'nemi/episodes/nemi_sf_accident'
        self.assertFalse(allowed_output(legacy/'scene.json',legacy/'renders/final.mp4'))
        folder=ROOT/'nemi/episodes/ep09_story'
        self.assertFalse(allowed_output(folder/'scene.json',folder/'renders/../../ep10_other/renders/final.mp4'))
        self.assertFalse(allowed_output(ROOT/'common/storytime/examples/test/scene.json',folder/'renders/final.mp4'))
if __name__=='__main__':unittest.main()

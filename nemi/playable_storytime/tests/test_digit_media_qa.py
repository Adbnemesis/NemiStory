"""Check real duration arithmetic and the projection used for clue evidence."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
spec=importlib.util.spec_from_file_location('digit_media_qa',ROOT/'tools/digit_media_qa.py')
qa=importlib.util.module_from_spec(spec);spec.loader.exec_module(qa)

def fixture():
    timeline={'duration':240,'fps':30,'scenes':[]}
    for key in range(10):
        timeline['scenes'].append({'id':f's{key}','start':key*24,'end':(key+1)*24,
            'walls':[{'index':index,'objects':[]} for index in range(4)]})
    game={'duration':240,'automatic_state':False,'challenges':[],
        'routes':[{'id':'linear','times':list(range(0,240,24))}],
        'navigation':{'mode':'youtube_digits','key_targets':[{'key':key,'chapter':f's{key}'} for key in range(10)]}}
    media={'format':{'duration':'240.000000'},'streams':[{'codec_type':'video','width':2160,'height':1080,
        'avg_frame_rate':'30/1','start_time':'0.000000','nb_frames':'7200'}]}
    return timeline,game,media

class DigitMediaClockTests(unittest.TestCase):
    def test_uses_encoded_duration_for_real_key_positions(self):
        timeline,game,media=fixture();media['format']['duration']='240.020000'
        result=qa.inspect_clock(timeline,game,media)
        self.assertAlmostEqual(result['landings'][9]['encoded_percentage_seconds'],216.018)
        self.assertTrue(result['clock_passed'])
    def test_frame_drift_fails(self):
        timeline,game,media=fixture();media['format']['duration']='240.1'
        self.assertFalse(qa.inspect_clock(timeline,game,media)['clock_passed'])
    def test_wrong_fps_fails(self):
        timeline,game,media=fixture();media['streams'][0]['avg_frame_rate']='24/1'
        self.assertFalse(qa.inspect_clock(timeline,game,media)['clock_passed'])
    def test_frame_plan_has_ten_front_landings(self):
        timeline,game,media=fixture();plan=qa.evidence_plan(timeline,game,qa.inspect_clock(timeline,game,media))
        self.assertEqual(len(plan),10)
        self.assertEqual(plan[9]['at'],216.65);self.assertTrue(all(item['yaw']==0 for item in plan))
    def test_output_must_stay_in_isolated_project(self):
        with self.assertRaisesRegex(ValueError,'isolated'):
            qa.paths(Path('/tmp'),Path('/tmp/no.mp4'),ROOT/'review/qa.json')

    @unittest.skipUnless(shutil.which('ffmpeg'),'FFmpeg is needed to check actual projection direction')
    def test_ffmpeg_yaw_matches_compositor_wall_direction(self):
        folder=ROOT/'.cache/digit_media_qa_tests';folder.mkdir(parents=True,exist_ok=True)
        with tempfile.TemporaryDirectory(dir=folder) as temporary:
            image=Path(temporary)/'longitude_chart.ppm';width=720;height=360
            colors=[]
            for x in range(width):
                longitude=(x/width-.5)*360
                if -45<=longitude<45:color=(0,255,0) # front
                elif 45<=longitude<135:color=(255,0,0) # right
                elif -135<=longitude<-45:color=(0,0,255) # left
                else:color=(255,255,0) # back
                colors.extend(color)
            image.write_bytes(f'P6\n{width} {height}\n255\n'.encode()+bytes(colors)*height)
            for yaw,expected in [(0,(0,255,0)),(90,(255,0,0)),(-90,(0,0,255)),(180,(255,255,0))]:
                result=subprocess.run(['ffmpeg','-hide_banner','-v','error','-i',str(image),
                    '-vf',qa.rectilinear_filter(yaw)+',format=rgb24,crop=1:1:480:270',
                    '-frames:v','1','-f','rawvideo','-pix_fmt','rgb24','-'],capture_output=True,check=True)
                self.assertEqual(tuple(result.stdout),expected,f'yaw {yaw} samples the wrong wall')

if __name__=='__main__':unittest.main()

"""Music timing cannot overrun narration or fill protected joke silences."""
import copy
import importlib.util
from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('score_plan',ROOT/'tools/score_plan.py')
score=importlib.util.module_from_spec(spec);spec.loader.exec_module(score)


def fixture():
    timeline={'duration':24,'audio_sha256':'a'*64,'words':[{'clip_id':'take','word':'hope,','start':1.0,'end':1.3}]}
    plan={'version':1,'title':'Original piano phrase','narration_sha256':'a'*64,
          'phrases':[{'id':'hope','at':1.25,'anchor':{'clip_id':'take','word':'hope','offset':.25},
                      'intent':'A brief hopeful musical thought','notes':[
                          {'offset':0,'midi':62,'duration':1.2,'velocity':.3},
                          {'offset':.6,'midi':66,'duration':1.1,'velocity':.25,'pan':.1}]}],
          'silent_ranges':[{'start':10,'end':12,'reason':'Leave the realization dry'}]}
    return plan,timeline


class ScorePlanTests(unittest.TestCase):
    def test_explicit_notes_resolve_on_the_final_word_clock(self):
        plan,timeline=fixture();notes=score.validated_plan_notes(plan,timeline)
        self.assertEqual([x['at'] for x in notes],[1.25,1.85])
        self.assertEqual([x['midi'] for x in notes],[62,66])
        self.assertEqual(notes[0]['pan'],0)

    def test_stale_narration_or_anchor_rejected(self):
        plan,timeline=fixture()
        for field,value in [('narration_sha256','b'*64),('at',1.3)]:
            bad=copy.deepcopy(plan)
            if field=='at':bad['phrases'][0][field]=value
            else:bad[field]=value
            with self.assertRaises(ValueError):score.validated_plan_notes(bad,timeline)
        for extra in [{'word':'missing'},{'clip_id':'gone'},{'occurrence':1},{'offset':float('nan')}]:
            bad=copy.deepcopy(plan);bad['phrases'][0]['anchor'].update(extra)
            with self.assertRaises(ValueError):score.validated_plan_notes(bad,timeline)

    def test_protected_silence_includes_note_tails(self):
        plan,timeline=fixture();p=plan['phrases'][0];p.pop('anchor');p['at']=9.5
        with self.assertRaisesRegex(ValueError,'protected comic silence'):score.validated_plan_notes(plan,timeline)

    def test_exact_silence_boundaries_are_allowed(self):
        plan,timeline=fixture();p=plan['phrases'][0];p.pop('anchor');p['at']=9;p['notes']=[{'offset':0,'midi':62,'duration':1,'velocity':.2}]
        score.validated_plan_notes(plan,timeline)
        p['at']=12;score.validated_plan_notes(plan,timeline)

    def test_note_overrun_is_rejected_instead_of_truncated(self):
        plan,timeline=fixture();p=plan['phrases'][0];p.pop('anchor');p['at']=23
        with self.assertRaisesRegex(ValueError,'fit the scene clock'):score.validated_plan_notes(plan,timeline)

    def test_invalid_pitch_velocity_pan_and_timing_rejected(self):
        plan,timeline=fixture()
        for extra in [{'midi':True},{'midi':62.5},{'midi':109},{'velocity':0},{'velocity':.9},
                      {'pan':2},{'duration':0},{'offset':-.1},{'duration':float('inf')}]:
            bad=copy.deepcopy(plan);bad['phrases'][0]['notes'][0].update(extra)
            with self.assertRaises(ValueError):score.validated_plan_notes(bad,timeline)

    def test_reversed_notes_and_duplicate_phrase_ids_rejected(self):
        plan,timeline=fixture();bad=copy.deepcopy(plan);bad['phrases'][0]['notes'].reverse()
        with self.assertRaisesRegex(ValueError,'ordered'):score.validated_plan_notes(bad,timeline)
        plan['phrases'].append(copy.deepcopy(plan['phrases'][0]))
        with self.assertRaisesRegex(ValueError,'unique'):score.validated_plan_notes(plan,timeline)

    def test_unknown_or_empty_music_fields_rejected(self):
        plan,timeline=fixture()
        for mutation in ['version','phrases','note','phrase']:
            bad=copy.deepcopy(plan)
            if mutation=='version':bad['version']=True
            if mutation=='phrases':bad['phrases']=[]
            if mutation=='note':bad['phrases'][0]['notes'][0]['randomize']=True
            if mutation=='phrase':bad['phrases'][0]['loop']=True
            with self.assertRaises(ValueError):score.validated_plan_notes(bad,timeline)


if __name__=='__main__':unittest.main()

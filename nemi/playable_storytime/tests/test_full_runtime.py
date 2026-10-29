"""A shorter full cut must keep the real percentage map and full-game checks."""
import copy
import importlib.util
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
module_spec = importlib.util.spec_from_file_location(
    'full_runtime_validation', ROOT / 'tools/validate_episode.py')
validation = importlib.util.module_from_spec(module_spec)
module_spec.loader.exec_module(validation)


def fixture(duration=220, fps=30):
    """A complete ten-entry movie with one honest authored choice."""
    interval = duration / 10
    navigation = {'mode': 'youtube_digits', 'key_targets': [
        {'key': key, 'chapter': f's{key}'} for key in range(10)]}
    scenes = []
    prompts = []
    for key in range(10):
        start, end = key * interval, (key + 1) * interval
        walls = [{'index': wall, 'objects': []} for wall in range(4)]
        walls[1]['objects'].append({
            'id': 'tear', 'kind': 'page_tear', 'author': 'nemi',
            'x': 500, 'y': 610, 'text': '2 TAKE THE TEAR'})
        scenes.append({'id': f's{key}', 'start': start, 'end': end,
                       'location': 'sketchbook', 'walls': walls})
        prompts.append({'id': f's{key}', 'start': start, 'end': end,
                        'objective': 'Help Nemi leave the drawing',
                        'choices': ([{'key': 2, 'label': 'Take the tear',
                                     'chapter': 's2'}] if key == 0 else [])})
    timeline = {'duration': duration, 'fps': fps, 'world_renderer': 'drawing',
                'scenes': scenes, 'navigation': copy.deepcopy(navigation),
                'interaction_scenes': prompts}
    challenge = {
        'id': 'paper_route', 'start': 0, 'end': interval,
        'state_tracking': False, 'objective': 'Find real paper',
        'instructions': 'Look around, then press the offered number',
        'visual_change': 'The authored tear route plays',
        'success': 'The paper route opens',
        'retry_method': 'Press 2 to take the tear',
        'do_nothing': 'The passive story continues',
        'wrong_answer': 'A comic wrong turn plays',
        'device_limitations': ['Desktop focus or numbered chapters'],
        'valid_destinations': [2 * interval],
        'alternative_outcomes': [interval],
        'solution_key': 2, 'retry_key': 2, 'alternative_keys': [1],
        'solution': '2 TAKE THE TEAR', 'clue_id': 'tear', 'hints': []}
    game = {'duration': duration, 'automatic_state': False,
            'navigation': navigation, 'challenges': [challenge],
            'interaction_scenes': copy.deepcopy(prompts),
            'routes': [{'id': 'main', 'times': [0, 2 * interval]},
                       {'id': 'passive', 'times': [key * interval
                                                 for key in range(10)]}]}
    return timeline, game


class FullRuntimeTests(unittest.TestCase):
    def test_220_second_cut_uses_22_second_native_landings(self):
        result = validation.check_data(*fixture())
        self.assertEqual([result['digit_map'][key]['at'] for key in range(10)],
                         [0, 22, 44, 66, 88, 110, 132, 154, 176, 198])
        self.assertEqual(result['routes'][0]['landings'], [0, 44])
        self.assertEqual(result['interaction_prompts'][0]['choice_keys'], [2])

    def test_runtime_bounds_and_prior_240_second_cut_remain_supported(self):
        for duration in [180, 220, 240, 360]:
            with self.subTest(duration=duration):
                self.assertTrue(validation.check_data(*fixture(duration))['pass_'])

    def test_full_cut_rejects_outside_runtime_and_unsupported_fps(self):
        for duration, fps in [(179.9, 30), (360.1, 30), (220, 25)]:
            with self.subTest(duration=duration, fps=fps):
                with self.assertRaisesRegex(ValueError, '3–6 minutes'):
                    validation.check_data(*fixture(duration, fps))

    def test_old_24_second_entries_cannot_pass_as_a_220_second_cut(self):
        timeline, game = fixture(240)
        timeline['duration'] = game['duration'] = 220
        timeline['scenes'][-1]['end'] = 220
        with self.assertRaisesRegex(ValueError, 'percentage landing'):
            validation.check_data(timeline, game)

    def test_shorter_cut_still_requires_exact_scene_coverage(self):
        timeline, game = fixture()
        timeline['scenes'][3]['start'] += 1
        with self.assertRaisesRegex(ValueError, 'gap, overlap'):
            validation.check_data(timeline, game)

    def test_shorter_cut_still_requires_matching_manifest_duration(self):
        timeline, game = fixture()
        game['duration'] = 240
        with self.assertRaisesRegex(ValueError, 'exact runtime'):
            validation.check_data(timeline, game)

    def test_shorter_cut_still_rejects_fake_state_and_wrong_answer_destination(self):
        for mutation in ['state', 'answer']:
            timeline, game = fixture()
            if mutation == 'state':
                game['automatic_state'] = True
                message = 'cannot track game state'
            else:
                game['challenges'][0]['valid_destinations'] = [66]
                message = 'Answer key disagrees'
            with self.subTest(mutation=mutation):
                with self.assertRaisesRegex(ValueError, message):
                    validation.check_data(timeline, game)


if __name__ == '__main__':
    unittest.main()

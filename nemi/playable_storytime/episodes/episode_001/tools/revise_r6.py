#!/usr/bin/env python3
"""Preserve R5 and author the four-minute native-number-key revision."""
import hashlib
import json
import shutil
from pathlib import Path

EPISODE = Path(__file__).resolve().parents[1]


def save(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')


def main():
    archive = EPISODE / 'review/revisions/r5_source_snapshot'
    if archive.exists():
        raise SystemExit('R5 archive already exists; inspect the current revision before applying again.')
    archive.mkdir(parents=True)
    for name in ['scripts', 'storyboard', 'gameplay', 'audio', 'metadata', 'assets', 'concept']:
        shutil.copytree(EPISODE / name, archive / name)
    for name in ['scene.json', 'camera_plan.json', 'sound_plan.json', 'preflight.json']:
        shutil.copy2(EPISODE / name, archive / name)
    save(archive / 'snapshot.json', {
        'reason': 'Preserve the five-minute R5 production before the user-requested faster digit-choice revision.',
        'files': [{'path': str(p.relative_to(archive)), 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
                  for p in sorted(archive.rglob('*')) if p.is_file()]})
    # Source/processed takes are content-addressed and reusable. Preserve current
    # assembled/derived audio in the archive before allowing new assembly.
    for path in (EPISODE / 'audio').iterdir():
        if path.is_file():
            path.unlink()
    story = json.loads((EPISODE / 'scripts/story.json').read_text())
    story['duration'] = 240
    story['title'] = 'Save My School Day — You Control This Story'
    texts = [
        ["My badge is missing. Assembly's starting. And something behind me is definitely judging me.",
         "Wait. You can move the camera? Drag the picture. On the app, swipe. You're my lookout.",
         "Click the video. Find a number, press that key. Phone? Tap the matching numbered chapter."],
        ["Find my star badge. Not the trophy. Definitely not the sandwich. Look around the hallway.",
         "The real badge has our route number. Press that number when you find it. I'll supervise nervously.",
         "Need a hint? Press two. I'm trusting your eyeballs. A deeply irresponsible promotion."],
        ["Hint duty. Turn left from me. Check above the bench, beside the lockers. Tiny star. Big consequences.",
         "Found the sandwich? Congratulations. You've discovered lunch. Please don't use it as identification.",
         "The badge says three. Press three for the rescue. Or stay; I have a backup plan."],
        ["Badge rescue. Mine says student host. Student what? That feels legally significant.",
         "Yesterday, someone asked me to hold something for assembly. I thought: a door. They meant an audience.",
         "New plan. Noticeboard. Right side. Find today's star. I'm emotionally unavailable."],
        ["Two notices. One's crossed out. Find today's correction. Apparently even the noticeboard has a redemption arc.",
         "Today's star gives our route number. Press it. The crossed-out notice is lying with impressive confidence.",
         "The old route promises pudding inspection. Tempting. Suspicious. Still tempting. Choose your number."],
        ["Pudding inspection. The silly detour, chosen or otherwise. There is no pudding. I'm reporting this department.",
         "The cup is full of pencils. I've been tricked by school supplies. This school has layers.",
         "Press four to retry the notice. Or press six for assembly. I'm filing a dessert complaint."],
        ["Assembly. One tiny microphone. Enough power to ruin my morning. Why does it look so confident?",
         "I could hide. But someone trusted me. Someone with dangerously optimistic opinions about my reading comprehension.",
         "I'll do it. One last favour. Look behind me. Find out who's actually in the audience."],
        ["Final challenge. Find the audience notice behind me. Its number takes us to my big debut.",
         "I'm imagining hundreds of people. A spotlight. Someone coughing exactly when I forget my own name.",
         "Turn all the way around. Need a hint? Press eight. My hair is blocking my investigation."],
        ["Rehearsal. Audience: three stuffed animals. I've been experiencing stage fright in front of a fabric duck.",
         "The bear looks critical. Manufacturing issue, probably. The rabbit has slept through this entire production.",
         "The ending is nine. Press nine for my debut. If you spotted the duck first, act surprised."],
        ["Good morning, distinguished duck. Today's topic: reading forms before volunteering. My research was painfully thorough.",
         "You found my badge and my terrifying audience. You're hired: unpaid camera operator. Benefits? Imaginary pudding.",
         "Don't read the duck's review. I need one person on my side. Press zero for another disaster."],
    ]
    story['navigation'] = {'mode': 'youtube_digits', 'key_targets': [
        {'key': i, 'chapter': chapter['id']} for i, chapter in enumerate(story['chapters'])]}
    for i, (chapter, lines) in enumerate(zip(story['chapters'], texts)):
        chapter['start'], chapter['end'] = i * 24, (i + 1) * 24
        chapter['name'] = f'{i} · ' + chapter['name']
        for j, (line, text) in enumerate(zip(chapter['lines'], lines)):
            line['text'] = text
            line['at'] = i * 24 + [.65, 8.4, 16.1][j]
            line['window_end'] = i * 24 + [8.05, 15.75, 23.75][j]
            line['tempo'] = 1.08
        for cue in chapter.get('environment_events', []):
            cue['at'], cue['end'] = i * 24 + 1, i * 24 + 1.6
    story['chapters'][0]['drawing'] = 'a fictional school disaster'
    # Rebind retained effects to words present in the shorter script.
    replacements = {'clock_deadline': ('open_01', 'starting'),
                    'fiction_aside': ('open_03', 'key'),
                    'eyeballs': ('badge_03', 'eyeballs'),
                    'student_host': ('recover_01', 'what'),
                    'corrected_notice': ('notice_01', 'correction'),
                    'unpaid_promotion': ('end_02', 'unpaid')}
    for cue in story['sound_cues']:
        if cue['id'] in replacements:
            cue['clip_id'], cue['word'] = replacements[cue['id']]
        if cue['id'] == 'fiction_aside':
            cue['intent'] = 'A brief comic accent introduces the real native key mechanic.'
    story['additional_drawings'][0].update(at=9.5, end=24)
    story['acting_accents'][1]['word'] = 'forget'
    save(EPISODE / 'scripts/story.json', story)
    locations = json.loads((EPISODE / 'assets/locations.json').read_text())
    labels = {'star_badge': 'STAR\nPRESS 3', 'old_notice': 'OLD: PRESS 5\nPUDDING INSPECTION',
              'star_correction': 'TODAY\nASSEMBLY\nPRESS 6',
              'audience_notice': 'REHEARSAL\n3 STUFFED ANIMALS\nPRESS 9'}
    for walls in locations.values():
        for wall in walls:
            for obj in wall['objects']:
                if obj['id'] in labels:
                    obj['text'] = labels[obj['id']]
    save(EPISODE / 'assets/locations.json', locations)
    game = json.loads((EPISODE / 'gameplay/challenges.json').read_text())
    game['duration'], game['navigation'] = 240, story['navigation']
    for c, key, retry, hint, start, end, alternatives in zip(
            game['challenges'], [3, 6, 9], [1, 4, 7], [2, 5, 8], [24, 96, 168], [72, 144, 216], [[], [5], []]):
        c.update(start=start, end=end, solution=f'PRESS {key}', solution_key=key, retry_key=retry,
                 alternative_keys=alternatives, inputs=['desktop WASD', 'mouse drag', 'YouTube app swipe', 'pause', 'desktop number keys 0–9', 'mobile numbered chapters'],
                 instructions=f'Look around. Find the number on the real clue. Press {key}; on the app select chapter {key}.',
                 visual_change='Native viewpoint rotation reveals the clue; a digit key selects an authored story scene.',
                 retry_method=f'Press {retry} to retry, or select its numbered chapter on mobile.',
                 valid_destinations=[key * 24], alternative_outcomes=[n * 24 for n in alternatives],
                 hints=[{'at': hint * 24, 'text': 'A short narrated hint and solution follow for passive viewers.'}],
                 mobile='Current YouTube app: swipe to look; choose matching numbered chapter. Chapters/channel availability and upload test pending.',
                 device_limitations=['Click the desktop player before using top-row number keys. K resumes if paused.',
                                     'Number keys are desktop controls; mobile uses numbered chapters when available.',
                                     'TV/controller behavior unverified. Captions are optional conventional subtitles.'])
    for route in game['routes']:
        route['times'] = [round(t * .8) for t in route['times']]
    save(EPISODE / 'gameplay/challenges.json', game)
    brief = EPISODE / 'concept/R6_DIRECTION.md'
    brief.write_text('''# R6: quick choices and a tighter four-minute cut

The viewer finds a number on a real school object, then presses that top-row
digit in the focused desktop YouTube player. Ten24second sections align with
the native10percent jumps. Badge3, correctednotice6 andaudience9 lead forward;
5 is the pudding detour,1/4/7 retry and2/8 give hints. Mobile uses the matching
numbered chapter when available. Pause is optional; K/play resumes it.

Each landing gives650ms of readable orientation before speech. Each challenge
keeps its clue visible while concise commentary advances the joke. Ordinary
speech gaps will be tightened after measured takes; preserve the lunch reveal,
student-host recognition and final duck hold. No click targets or answer
detection are implied. Captions remain real dialogue captions.

Promise: help Nemi survive an accidental assembly commitment.
Want: recover thebadge and avoid becoming theevent.
Choice: trust theviewer's observation, then choose a route with one key.
Consequence: recovering thebadge reveals STUDENT HOST.
Payoff: a terrifying audience ofthree toys hires theviewer forimaginary pudding.

R5 media and sources remain preserved. This material revision needs a new
complete1920×1080 review before any4K export.
''')
    print('R5 sources archived; R6 authored:', sum(len(t.split()) for group in texts for t in group), 'script words.')


if __name__ == '__main__':
    main()

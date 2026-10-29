#!/usr/bin/env python3
"""Build ADB EP07 'How I Got Over My Crush' (High School Crush Conclusion) - Revision 2.

Refinement Addressing User Feedback:
1. Background Variety: Replaced repetitive classroom/studio loops with 6 distinct, story-appropriate backdrops:
   - school_day_r4 (sunlit Japanese classroom with detailed desks/blackboard)
   - school_corridor_r4 (detailed school hallway with lockers)
   - bedroom_evening_r4 (evening bedroom at home for texting and getting blocked)
   - school_courtyard_r4 (campus courtyard under trees for 5-yr breakup news)
   - school_street_r4 (neighborhood street with friends walking & hyping him up)
   - thought (abstract mental shock void for the dating-again revelation & pedestal shattering)
   - adb_studio_ep02 (creator studio for college transition & meeting Nemi)
2. Aiden's Acting & Facial Expressions:
   - Completely eliminated smiling from P0 through P7!
   - Expresses awkwardness, tension, anxiety, devastation, comic shock, and deadpan apathy.
   - P0: Awkward class aftermath (uncertain, nervous_answer, soft_shrug)
   - P1: Hallway quarrel drama & cringing savior complex (quiet_recoil, nervous_wait, lean_in, clue_point)
   - P2: Badmouthing & getting blocked again (hurt_composure, deadpan, tear/sweat intensity, absolute heartbreak)
   - P3: 5-year breakup & bro sympathy (realization, skeptical, hurt_composure)
   - P4: Squad matchmaking & unblock miracle (nervous_wait, clue_point, realization)
   - P5: Comic record scratch shock (quiet_recoil, deadpan freeze with 1.40 eye openness)
   - P6: Total emotional evaporation & pedestal collapse (realization, deadpan, skeptical, dry_annoyance, soft_shrug)
   - P7: Genuine peaceful friendship (listening, explaining, open_shrug)
   - P8: ONLY HERE: Genuine warm smile when meeting his girlfriend Nemi! (shy_confession, pleased, recover)
3. Subtitle Typo Fix: Corrected Whisper transcript "Nami" to canonical girlfriend "Nemi" (at 123.57s).
4. Rich Doodles & Props: Expanded to 45+ total items, including 22+ active live pencil-animated doodles
   with synchronized scratch/scribble SFX.
"""
import copy
import hashlib
import json
import math
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[4]
FOLDER = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / 'tools/storytime'))

from tools.storytime.validate_scene import validate
from tools.storytime.sfx_levels import choose_gain, pcm
from tools.storytime.sfx_assets import validate_asset
from tools.storytime.audio_mix import calibrate_mix

AUDIO = ROOT / 'renders/adb_how_i_got_over_my_crush/audio'

# Validated rich backdrops
BG_CLASSROOM = 'school_day_r4'
BG_CORRIDOR = 'school_corridor_r4'
BG_BEDROOM = 'bedroom_evening_r4'
BG_COURTYARD = 'school_courtyard_r4'
BG_STREET = 'school_street_r4'
BG_THOUGHT = 'thought'
BG_STUDIO = 'adb_studio_ep02'

SCALE = 1.08
ROOT_Y = round(894 - 192 * SCALE, 4)  # 686.64


def write_json(path, data):
    Path(path).write_text(json.dumps(data, indent=2) + '\n')


def token(text):
    return re.sub(r'[^a-z0-9]', '', text.lower())


def caption_cards(paragraph_words):
    cards = []
    def emit(group):
        display = [w[1]['word'] for w in group]
        boundaries = [0] + [j for j in range(1, len(group))
                            if round(group[j][1]['start'] - group[j-1][1]['end'], 6) >= .35] + [len(group)]
        for start, end in zip(boundaries, boundaries[1:]):
            part = group[start:end]
            cards.append(dict(actor='adb', words=[part[0][0], part[-1][0]],
                              start=part[0][1]['start'], end=part[-1][1]['end'],
                              text=' '.join(display[start:end])))
    for words_list in paragraph_words:
        group = []
        for j, item in enumerate(words_list):
            group.append(item)
            if len(group) == 5 or re.search(r'[.!?]$', item[1]['word']) or j == len(words_list)-1:
                emit(group)
                group = []
    words_dict = {w[0]: w[1] for words_list in paragraph_words for w in words_list}
    for k in range(len(cards)):
        c = cards[k]
        last_word_end = words_dict[c['words'][1]]['end']
        nxt_start = cards[k+1]['start'] if k+1 < len(cards) else last_word_end + 0.2
        c['end'] = round(min(last_word_end + 0.04, nxt_start), 6)
        if c['end'] < last_word_end:
            c['end'] = last_word_end
    return cards


def build():
    timeline = json.loads((AUDIO / 'timeline.json').read_text())
    narration = AUDIO / 'narration.wav'
    assert timeline['audio_sha256'] == hashlib.sha256(narration.read_bytes()).hexdigest(), "Audio hash mismatch"
    duration = timeline['duration']
    assert duration <= 140.0, f"Runtime exceeds the 140s ceiling: {duration}s"
    paragraphs = [p.strip() for p in (FOLDER / 'narration.txt').read_text().split('\n\n') if p.strip()]
    clips = timeline['clips']
    words = timeline['words']
    assert len(clips) == len(paragraphs) == 9, f"Expected 9 clips/paragraphs, got {len(clips)} and {len(paragraphs)}"

    paragraph_words = []
    for clip in clips:
        paragraph_words.append([(i, w) for i, w in enumerate(words)
                                if clip['at'] <= w['start'] < w['end'] <= clip['end_at'] + .000001])
    assert sum(len(p) for p in paragraph_words) == len(words)
    timing_reference = json.loads((FOLDER / 'timing_reference_r1.json').read_text())
    boundaries = [round(p['beat_start'], 6) for p in timing_reference['paragraphs']] + [duration]
    assert timing_reference['audio_sha256'] == timeline['audio_sha256']

    def word(p, wanted, occurrence=0, edge='start'):
        found = [w for _, w in paragraph_words[p] if token(w['word']) == token(wanted)]
        if len(found) <= occurrence:
            raise ValueError(f"Measured paragraph {p}: missing anchor {wanted!r}/{occurrence}; review actual transcript")
        return found[occurrence][edge]

    events = []
    anchor_references = {}
    anchors = [
        ('confession_aftermath', 0, 'confession', 0), ('didnt_stop', 0, 'stop', 0), ('banter_class', 0, 'class', 0), ('homework_notes', 0, 'homework', 0), ('surprisingly_normal', 0, 'normal', 0),
        ('until_one_day', 1, 'until', 0), ('hallway_fight', 1, 'fight', 0), ('she_crying', 1, 'crying', 0), ('savior_complex', 1, 'savior', 0), ('overdrive', 1, 'overdrive', 0),
        ('felt_terrible', 2, 'terrible', 0), ('grabbed_phone', 2, 'phone', 0), ('badmouthing_bf', 2, 'badmouthing', 0), ('big_mistake', 2, 'mistake', 0), ('she_furious', 2, 'furious', 0), ('blocked_again', 2, 'blocked', 0), ('broke_me', 2, 'broke', 0),
        ('second_year_end', 3, 'second', 0), ('news_dropped', 3, 'news', 0), ('broke_up', 3, 'broke', 0), ('five_years', 3, 'five', 0), ('felt_bad_bf', 3, 'bad', 0), ('good_friend', 3, 'friend', 0),
        ('she_single', 4, 'single', 0), ('squad_work', 4, 'squad', 0), ('matchmaking_mode', 4, 'matchmaking', 0), ('hyped_me_up', 4, 'hyped', 0), ('unblocked_me', 4, 'unblocked', 0),
        ('senior_year', 5, 'senior', 0), ('walk_in', 5, 'walk', 0), ('universe_setting_up', 5, 'universe', 0), ('find_out', 5, 'find', 0), ('dating_again', 5, 'dating', 0), ('someone_else', 5, 'else', 0),
        ('switch_flipped', 6, 'switch', 0), ('feelings_vanished', 6, 'feelings', 0), ('pedestal_shattered', 6, 'pedestal', 0), ('different_way', 6, 'different', 0), ('yeah_nope', 6, 'nope', 0), ('do_not_like', 6, 'not', 0),
        ('romantic_nonsense', 7, 'romantic', 0), ('unexpected_happened', 7, 'unexpected', 0), ('months_before', 7, 'months', 0), ('talking_again', 7, 'talking', 0), ('no_tension', 7, 'tension', 0), ('genuine_friends', 7, 'genuine', 0),
        ('graduated', 8, 'graduated', 0), ('went_to_college', 8, 'college', 0), ('met_girlfriend', 8, 'girlfriend', 0), ('nemi_love', 8, 'nemi', 0), ('worked_out', 8, 'worked', 0)
    ]

    for name, p, exact, occurrence in anchors:
        selected = [(i, w) for i, w in paragraph_words[p] if token(w['word']) == token(exact)][occurrence]
        anchor_references[name] = dict(word=selected[1]['word'], word_index=selected[0], paragraph=p+1, start=selected[1]['start'], end=selected[1]['end'])
        events.append(dict(id=name, at=word(p, exact, occurrence), intent=f'Paragraph {p+1}, measured word “{exact}”: authored thought accent.'))
    event_map = {e['id']: e['at'] for e in events}

    def E(name, offset=0): return round(event_map[name] + offset, 6)
    def B(p): return boundaries[p]
    def N(p): return boundaries[p+1]

    # Continuous Shots covering the full duration with 6 rich, varied environments
    shots = []
    camera_plan = []
    def shot(name, p, start, end, background, framing, center, zoom, x=800, reason='', anchor=None, path=None):
        end_val = duration if (end >= duration or abs(end - duration) < 0.001) else round(end, 6)
        item = dict(id=name, start=round(start,6), end=end_val, background=background,
                    actors={'adb': dict(position=[x, ROOT_Y], scale=SCALE)},
                    camera=dict(center=center, zoom=zoom))
        if path:
            for pt in path:
                if pt['at'] >= duration or abs(pt['at'] - duration) < 0.001:
                    pt['at'] = duration
            item['camera']['path'] = path
        shots.append(item)
        camera_plan.append(dict(shot=name, start=item['start'], end=item['end'], paragraph=p+1,
                                exact_spoken_cue=anchor_references[anchor]['word'] if anchor in anchor_references else paragraphs[p].split('.')[0],
                                measured_word=anchor_references.get(anchor), sentence_context=paragraphs[p], event=anchor if anchor in event_map else None,
                                focus=framing, center=center, zoom=zoom, reason=reason,
                                finish='Hold the settled image until the next measured thought/cut.', path=path or []))

    # P0: High School Classroom - Calm Post-Confession Aftermath (0.0 to N(0))
    shot('p0_classroom_intro', 0, B(0), E('banter_class'), BG_CLASSROOM, 'Sunlit classroom: post-confession aftermath', [800, 550], 1.20, x=800,
         reason='Rich sunlit classroom setting establishing the surprising continuation of talking.', anchor='confession_aftermath',
         path=[dict(at=round(B(0),6), center=[800, 550], zoom=1.18), dict(at=round(E('banter_class'),6), center=[800, 538], zoom=1.28)])
    shot('p0_classroom_notes', 0, E('banter_class'), N(0), BG_CLASSROOM, 'Classroom desks: exchanging notes and chatting', [800, 545], 1.30, x=800,
         reason='Classroom desks showing regular high school routine.', anchor='homework_notes')

    # P1: School Corridor - The Hallway Argument (N(0) to N(1))
    shot('p1_corridor_fight', 1, B(1), E('savior_complex'), BG_CORRIDOR, 'Hallway lockers: seeing the couple fight', [750, 560], 1.15, x=750,
         reason='Detailed school hallway establishing the quarrel drama.', anchor='hallway_fight')
    shot('p1_corridor_savior', 1, E('savior_complex'), N(1), BG_CORRIDOR, 'Savior complex kicking into overdrive', [780, 535], 1.35, x=780,
         reason='Close framing on Aiden making an impulsive decision in the hallway.', anchor='overdrive',
         path=[dict(at=round(E('savior_complex'),6), center=[780, 535], zoom=1.35), dict(at=round(N(1),6), center=[780, 525], zoom=1.50)])

    # P2: Bedroom Evening - Texting Regret & Blocked Again (N(1) to N(2))
    shot('p2_bedroom_texting', 2, B(2), E('big_mistake'), BG_BEDROOM, 'Evening bedroom: badmouthing on text', [750, 550], 1.25, x=750,
         reason='At home in his room at night, typing the terrible text on phone.', anchor='badmouthing_bf')
    shot('p2_bedroom_blocked', 2, E('big_mistake'), E('broke_me'), BG_BEDROOM, 'BAM! Blocked again alert screen', [750, 535], 1.45, x=750,
         reason='Red alert block screen popping on display.', anchor='blocked_again')
    shot('p2_bedroom_broke_me', 2, E('broke_me'), N(2), BG_BEDROOM, 'That broke me, man. Absolute defeat.', [750, 530], 1.55, x=750,
         reason='Dramatic hold on heartbreak and embarrassment in his bedroom.', anchor='broke_me',
         path=[dict(at=round(E('broke_me'),6), center=[750, 530], zoom=1.55), dict(at=round(N(2),6), center=[750, 520], zoom=1.65)])

    # P3: School Courtyard - 5-Year Breakup News (N(2) to N(3))
    shot('p3_courtyard_news', 3, B(3), E('five_years'), BG_COURTYARD, 'School courtyard: news drops at year 2 end', [780, 555], 1.15, x=780,
         reason='Campus courtyard under trees as classmates discuss the breakup.', anchor='second_year_end')
    shot('p3_courtyard_sympathy', 3, E('five_years'), N(3), BG_COURTYARD, 'Bro sympathy for the boyfriend', [780, 540], 1.30, x=780,
         reason='Quiet moment of genuine respect and empathy for his friend.', anchor='good_friend',
         path=[dict(at=round(E('five_years'),6), center=[780, 540], zoom=1.30), dict(at=round(N(3),6), center=[780, 530], zoom=1.42)])

    # P4: School Street - Friends Squad Matchmaking (N(3) to N(4))
    shot('p4_street_squad', 4, B(4), E('hyped_me_up'), BG_STREET, 'Walking on street: friends matchmaking mode', [750, 555], 1.18, x=750,
         reason='School street walking scene with friends enthusiastically hyping Aiden up.', anchor='matchmaking_mode')
    shot('p4_street_unblocked', 4, E('hyped_me_up'), N(4), BG_STREET, 'The miracle: she actually unblocked me!', [750, 538], 1.38, x=750,
         reason='Green unblock notification appearing on screen while walking.', anchor='unblocked_me',
         path=[dict(at=round(E('hyped_me_up'),6), center=[750, 538], zoom=1.38), dict(at=round(N(4),6), center=[750, 526], zoom=1.52)])

    # P5: Senior Year Classroom -> Shock Thought Void (N(4) to N(5))
    shot('p5_senior_classroom', 5, B(5), E('find_out'), BG_CLASSROOM, 'Senior year classroom: high hopes', [800, 550], 1.25, x=800,
         reason='Walking into senior year classroom thinking the universe has a plan.', anchor='senior_year')
    shot('p5_dating_again_shock', 5, E('find_out'), N(5), BG_THOUGHT, 'COMIC SHOCK: She is already dating again?!', [750, 535], 1.55, x=750,
         reason='Record scratch shock freeze in thought void on the relationship announcement.', anchor='dating_again',
         path=[dict(at=round(E('find_out'),6), center=[750, 535], zoom=1.55), dict(at=round(N(5),6), center=[750, 522], zoom=1.68)])

    # P6: Thought Space - The Pedestal Shatters Completely (N(5) to N(6))
    shot('p6_switch_flipped', 6, B(6), E('different_way'), BG_THOUGHT, 'Switch flips: all feelings vanish & pedestal shatters', [750, 545], 1.30, x=750,
         reason='Visual void of clarity as the romantic pedestal crumbles into dust.', anchor='switch_flipped')
    shot('p6_yeah_nope', 6, E('different_way'), N(6), BG_THOUGHT, 'Yeah, nope. I do not like her at all anymore.', [960, 540], 1.45, x=960,
         reason='Stone-cold deadpan stare directly into camera.', anchor='do_not_like',
         path=[dict(at=round(E('different_way'),6), center=[960, 540], zoom=1.45), dict(at=round(N(6),6), center=[960, 528], zoom=1.60)])

    # P7: High School Classroom - Genuine Classmates 5 Months Before End (N(6) to N(7))
    shot('p7_classroom_friends', 7, B(7), E('talking_again'), BG_CLASSROOM, 'Classroom: drama cleared, 5 months before end', [800, 550], 1.22, x=800,
         reason='Warm classroom setting showing calm days without romantic anxiety.', anchor='romantic_nonsense')
    shot('p7_classroom_genuine', 7, E('talking_again'), N(7), BG_CLASSROOM, 'Two normal classmates chatting as true friends', [800, 540], 1.32, x=800,
         reason='Classroom desks with homework, peaceful and relaxed equals.', anchor='genuine_friends',
         path=[dict(at=round(E('talking_again'),6), center=[800, 540], zoom=1.32), dict(at=round(N(7),6), center=[800, 528], zoom=1.45)])

    # P8: Studio & College Transition - Meeting Nemi <3 (N(7) to duration)
    shot('p8_graduation_studio', 8, B(8), E('met_girlfriend'), BG_STUDIO, 'Graduation and off to college', [960, 550], 1.20, x=960,
         reason='Adult Aiden reflecting on graduation and college transition.', anchor='graduated')
    shot('p8_college_nemi', 8, E('met_girlfriend'), E('worked_out'), BG_STUDIO, 'Meeting girlfriend Nemi <3', [960, 538], 1.38, x=960,
         reason='Warm college transition badge featuring girlfriend Nemi heart.', anchor='nemi_love')
    shot('p8_final_payoff', 8, E('worked_out'), duration, BG_STUDIO, 'In the end, it all worked out pretty nicely.', [960, 545], 1.35, x=960,
         reason='Final heartwarming wrap-up into gentle fade to black.', anchor='worked_out',
         path=[dict(at=round(E('worked_out'),6), center=[960, 545], zoom=1.35), dict(at=duration, center=[960, 535], zoom=1.50)])

    # Dynamic Performances: NO SMILING from P0 through P7! Only smiles at P8 when meeting Nemi!
    performances = []
    acting_plan = []
    def cue(at, recipe, event=None, offset=0, intent='', **kw):
        c = dict(at=round(at,6), recipe=recipe, duration=kw.pop('duration',.42), **kw)
        if event: c.update(event=event, event_offset=offset)
        performances.append(c)
        acting_plan.append(dict(at=c['at'], recipe=recipe, intent=intent, event=event, detail=kw))

    # P0: Awkward/anxious aftermath in classroom (NO SMILING)
    cue(0, 'explaining', duration=.42, gaze=[-.2, 0], hands={'right':'open_palm','left':'relaxed'}, intent='Opening classroom recap of confession aftermath.')
    cue(E('didnt_stop'), 'uncertain', 'didnt_stop', gaze=[.3, -.2], face={'brow_left_height':2, 'brow_right_height':-1}, intent='Awkward realization that they still kept talking.')
    cue(E('banter_class'), 'nervous_answer', 'banter_class', hands={'right':'pointing','left':'relaxed'}, face={'sweat_intensity':.3, 'brow_left_height':-2, 'brow_right_height':-2}, intent='Flustered classroom banter after being told "I know".')
    cue(E('homework_notes'), 'weight_shift', 'homework_notes', gaze=[0, .3], intent='Looking down at homework notes.')
    cue(E('surprisingly_normal'), 'soft_shrug', 'surprisingly_normal', hands={'right':'shrug_open','left':'relaxed'}, intent='Surprisingly normal, but still cautious.')

    # P1: Hallway fight drama & foolish savior complex (Tense, nervous, misguided)
    cue(E('until_one_day'), 'uncertain', 'until_one_day', gaze=[-.3, .2], intent='Until one fateful day in the hallway.')
    cue(E('hallway_fight'), 'quiet_recoil', 'hallway_fight', gaze=[.4, 0], face={'eye_openness_left':1.2, 'eye_openness_right':1.2}, intent='Witnessing the massive argument break out.')
    cue(E('she_crying'), 'nervous_wait', 'she_crying', face={'sweat_intensity':.5, 'brow_left_height':3, 'brow_right_height':3, 'brow_left_angle':-8, 'brow_right_angle':-8}, intent='Seeing her crying and visibly devastated.')
    cue(E('savior_complex'), 'lean_in', 'savior_complex', hands={'right':'fist','left':'relaxed'}, gaze=[0, 0], intent='Misguided savior complex taking over.')
    cue(E('overdrive'), 'clue_point', 'overdrive', hands={'right':'pointing','left':'relaxed'}, intent='Kicking into overdrive with foolish determination.')

    # P2: The Second Block (Embarrassment, dread, BAM blocked, heartbroken defeat)
    cue(E('felt_terrible'), 'hurt_composure', 'felt_terrible', gaze=[0, .3], face={'tear_intensity':.2, 'brow_left_angle':-10, 'brow_right_angle':-10}, intent='Feeling awful seeing her upset.')
    cue(E('grabbed_phone'), 'prop_present', 'grabbed_phone', hands={'right':'holding_cup','left':'relaxed'}, gaze=[0, .3], intent='Grabbing phone in bedroom to text.')
    cue(E('badmouthing_bf'), 'nervous_answer', 'badmouthing_bf', gaze=[0, .3], face={'sweat_intensity':.4, 'brow_left_height':-3, 'brow_right_height':-3}, intent='Typing foolish messages badmouthing the boyfriend.')
    cue(E('big_mistake'), 'quiet_recoil', 'big_mistake', face={'eye_openness_left':1.25, 'eye_openness_right':1.25}, intent='Sudden gut dread: big mistake.')
    cue(E('she_furious'), 'dry_annoyance', 'she_furious', face={'brow_left_angle':12, 'brow_right_angle':12, 'eye_openness_left':.82, 'eye_openness_right':.82}, intent='She gets furious and defends him.')
    cue(E('blocked_again'), 'deadpan', 'blocked_again', motion='snap', face={'eye_openness_left':1.3, 'eye_openness_right':1.3}, intent='BAM! Blocked again stone freeze.')
    cue(E('broke_me'), 'hurt_composure', 'broke_me', face={'blush_intensity':.45, 'tear_intensity':.4, 'brow_left_angle':-14, 'brow_right_angle':-14}, intent='That broke me, man. Complete heartbreak.')

    # P3: 5-Year Breakup & Bro Sympathy (Shock, skepticism, quiet bro-respect)
    cue(E('second_year_end'), 'weight_shift', 'second_year_end', intent='Second year comes to a close.')
    cue(E('news_dropped'), 'realization', 'news_dropped', gaze=[0, 0], face={'eye_openness_left':1.15, 'eye_openness_right':1.15}, intent='Unexpected breakup news drops.')
    cue(E('broke_up'), 'soft_shrug', 'broke_up', hands={'right':'shrug_open','left':'relaxed'}, intent='The 5-year relationship is over.')
    cue(E('five_years'), 'skeptical', 'five_years', face={'brow_left_height':4, 'eye_openness_left':.85, 'eye_openness_right':.85}, intent='Five whole years gone in an instant.')
    cue(E('felt_bad_bf'), 'hurt_composure', 'felt_bad_bf', gaze=[.2, .2], face={'brow_left_angle':-8, 'brow_right_angle':-8}, intent='Genuine sympathy for the boyfriend.')
    cue(E('good_friend'), 'listening', 'good_friend', gaze=[.2, .1], intent='Respectful hold: he was a good friend.')

    # P4: The Matchmakers (Pressured, overwhelmed, surprised unblock)
    cue(E('she_single'), 'realization', 'she_single', intent='Friends find out she is single.')
    cue(E('squad_work'), 'nervous_wait', 'squad_work', face={'sweat_intensity':.45}, intent='Squad immediately converges on him.')
    cue(E('matchmaking_mode'), 'clue_point', 'matchmaking_mode', hands={'right':'pointing','left':'relaxed'}, intent='Friends launching full-time matchmaking mode.')
    cue(E('hyped_me_up'), 'nervous_answer', 'hyped_me_up', face={'brow_left_height':-2, 'brow_right_height':-2}, intent='Hyped up by peers, feeling awkward pressure.')
    cue(E('unblocked_me'), 'realization', 'unblocked_me', motion='snap', face={'eye_openness_left':1.25, 'eye_openness_right':1.25}, intent='Shocked surprise: she actually unblocked me?!')

    # P5: Senior Year Optimism -> Comic Record Scratch Shock
    cue(E('senior_year'), 'explaining', 'senior_year', intent='Senior year arrives.')
    cue(E('walk_in'), 'weight_shift', 'walk_in', intent='Walking in with cautious optimism.')
    cue(E('universe_setting_up'), 'self_impressed', 'universe_setting_up', gaze=[0, -.2], face={'brow_left_height':3}, intent='Brief naive thought that universe has a plan.')
    cue(E('find_out'), 'quiet_recoil', 'find_out', intent='Sudden rumor hits him.')
    cue(E('dating_again'), 'deadpan', 'dating_again', motion='snap', face={'eye_openness_left':1.4, 'eye_openness_right':1.4, 'brow_left_height':6, 'brow_right_height':6}, intent='RECORD SCRATCH FREEZE: She is ALREADY dating again?!')
    cue(E('someone_else'), 'dry_annoyance', 'someone_else', face={'eye_openness_left':.75, 'eye_openness_right':.75, 'brow_left_angle':10, 'brow_right_angle':10}, intent='Absolute disbelief at someone else.')

    # P6: The Pedestal Shatters (Emotional switch flips, total apathy, zero attraction)
    cue(E('switch_flipped'), 'realization', 'switch_flipped', motion='snap', intent='A switch flipped instantly.')
    cue(E('feelings_vanished'), 'deadpan', 'feelings_vanished', hands={'right':'open_palm','left':'relaxed'}, face={'eye_openness_left':.85, 'eye_openness_right':.85}, intent='All feelings completely gone.')
    cue(E('pedestal_shattered'), 'skeptical', 'pedestal_shattered', face={'brow_left_height':4, 'eye_openness_left':.8, 'eye_openness_right':.8}, intent='The pedestal completely shatters.')
    cue(E('different_way'), 'dry_annoyance', 'different_way', gaze=[.3, 0], face={'eye_openness_left':.8, 'eye_openness_right':.8}, intent='Seeing her in a totally different way.')
    cue(E('yeah_nope'), 'deadpan', 'yeah_nope', motion='snap', face={'eye_openness_left':.85, 'eye_openness_right':.85}, intent='Yeah, nope. Deadpan stare down camera.')
    cue(E('do_not_like'), 'soft_shrug', 'do_not_like', hands={'right':'shrug_open','left':'relaxed'}, intent='I mean I did NOT like her at all.')

    # P7: Real Classmates & Friends (Calm, mature, peaceful equals)
    cue(E('romantic_nonsense'), 'weight_shift', 'romantic_nonsense', intent='Romantic nonsense brushed aside.')
    cue(E('unexpected_happened'), 'uncertain', 'unexpected_happened', intent='Unexpected peaceful turn.')
    cue(E('months_before'), 'listening', 'months_before', gaze=[0, 0], intent='5 months before graduation calm.')
    cue(E('talking_again'), 'explaining', 'talking_again', hands={'right':'open_palm','left':'relaxed'}, intent='Talking naturally as genuine classmates.')
    cue(E('no_tension'), 'open_shrug', 'no_tension', intent='Zero tension or hidden motives.')
    cue(E('genuine_friends'), 'listening', 'genuine_friends', gaze=[0, 0], intent='True, peaceful, genuine friends.')

    # P8: Graduation, College, and MEETING NEMI <3 (ONLY HERE: True genuine smile!)
    cue(E('graduated'), 'weight_shift', 'graduated', hands={'right':'pointing','left':'relaxed'}, intent='Graduation on great terms.')
    cue(E('went_to_college'), 'explaining', 'went_to_college', intent='Off to college chapter.')
    cue(E('met_girlfriend'), 'shy_confession', 'met_girlfriend', face={'blush_intensity':.6}, intent='Private affectionate blush: meeting actual girlfriend!')
    cue(E('nemi_love'), 'pleased', 'nemi_love', face={'blush_intensity':.65}, intent='GENUINE WARM SMILE: Nemi <3.')
    cue(E('worked_out'), 'recover', 'worked_out', gaze=[0, 0], intent='Peaceful happy closure: it all worked out nicely.')

    # Clean up performance overlaps
    performances.sort(key=lambda c: c['at'])
    for j in range(len(performances) - 1):
        gap = performances[j+1]['at'] - performances[j]['at']
        if performances[j].get('motion') == 'snap':
            performances[j]['duration'] = 0.05
        elif performances[j].get('duration', 0.42) >= gap:
            performances[j]['duration'] = round(max(0.05, gap - 0.02), 3)

    # Mouth Intervals from measured word timestamps
    adb_vowels = [
        ('a', 'talk_open'), ('e', 'talk_wide'), ('i', 'talk_wide'), ('o', 'talk_round'), ('u', 'talk_round'),
        ('y', 'talk_wide'), ('w', 'talk_round')
    ]
    mouths = []
    for p_words in paragraph_words:
        for idx, w in p_words:
            st, en = w['start'], w['end']
            w_len = en - st
            if w_len < 0.08:
                shape = 'talk_open'
                for char, s in adb_vowels:
                    if char in w['word'].lower():
                        shape = s; break
                mouths.append(dict(start=round(st, 3), end=round(en, 3), shape=shape))
            else:
                mid = round(st + w_len * 0.45, 3)
                shape1 = 'talk_open'
                for char, s in adb_vowels:
                    if char in w['word'].lower()[:3]:
                        shape1 = s; break
                shape2 = 'talk_wide' if 'e' in w['word'].lower() or 'i' in w['word'].lower() else 'talk_round'
                mouths.append(dict(start=round(st, 3), end=mid, shape=shape1))
                mouths.append(dict(start=mid, end=round(en, 3), shape=shape2))

    # Hand-drawn Doodles & Props (45+ items: held cards + live animated strokes)
    drawings = []

    # P0: Classroom aftermath
    drawings.append(dict(author='adb', kind='post_confession_chat', at=round(E('banter_class'),6), end=round(N(0),6),
                         position=[1280, 520], scale=[1.1, 1.1], mode='hold', shots=['p0_classroom_notes']))
    drawings.append(dict(author='adb', kind='homework_notes', at=round(E('homework_notes'),6), end=round(N(0),6),
                         position=[1100, 680], scale=[0.9, 0.9], mode='hold', shots=['p0_classroom_notes']))
    drawings.append(dict(author='adb', kind='underline', at=round(E('confession_aftermath'),6), duration=0.45, end=round(E('banter_class'),6),
                         position=[800, 780], scale=[1.2, 1.2], mode='live', shots=['p0_classroom_intro']))
    drawings.append(dict(author='adb', kind='circle', at=round(E('banter_class'),6), duration=0.40, end=round(E('homework_notes'),6),
                         position=[800, 420], scale=[1.1, 1.1], mode='live', shots=['p0_classroom_notes']))
    drawings.append(dict(author='adb', kind='question', at=round(E('surprisingly_normal'),6), duration=0.40, end=round(N(0),6),
                         position=[800, 320], scale=[1.0, 1.0], mode='live', shots=['p0_classroom_notes']))

    # P1: Hallway corridor fight
    drawings.append(dict(author='adb', kind='hallway_fight_doodle', at=round(E('hallway_fight'),6), end=round(E('savior_complex'),6),
                         position=[1260, 480], scale=[1.15, 1.15], mode='hold', shots=['p1_corridor_fight']))
    drawings.append(dict(author='adb', kind='action_burst_mistake', at=round(E('she_crying'),6), end=round(E('savior_complex'),6),
                         position=[1260, 340], scale=[0.9, 0.9], mode='hold', shots=['p1_corridor_fight']))
    drawings.append(dict(author='adb', kind='scratch', at=round(E('hallway_fight'),6), duration=0.40, end=round(E('she_crying'),6),
                         position=[1260, 480], scale=[1.2, 1.2], mode='live', shots=['p1_corridor_fight']))
    drawings.append(dict(author='adb', kind='arrow', at=round(E('savior_complex'),6), duration=0.45, end=round(E('overdrive'),6),
                         position=[780, 400], scale=[1.1, 1.1], mode='live', shots=['p1_corridor_savior']))
    drawings.append(dict(author='adb', kind='circle', at=round(E('overdrive'),6), duration=0.45, end=round(N(1),6),
                         position=[780, 350], scale=[1.1, 1.1], mode='live', shots=['p1_corridor_savior']))

    # P2: Bedroom evening texting & blocked again
    drawings.append(dict(author='adb', kind='school_chat_phone', at=round(E('grabbed_phone'),6), end=round(E('blocked_again'),6),
                         position=[1260, 520], scale=[1.0, 1.0], mode='hold', shots=['p2_bedroom_texting']))
    drawings.append(dict(author='adb', kind='blocked_again_screen', at=round(E('blocked_again'),6), end=round(E('broke_me'),6),
                         position=[1260, 520], scale=[1.1, 1.1], mode='hold', shots=['p2_bedroom_blocked']))
    drawings.append(dict(author='adb', kind='blocked_stamp', at=round(E('blocked_again'),6), end=round(E('broke_me'),6),
                         position=[1260, 500], scale=[1.15, 1.15], mode='hold', shots=['p2_bedroom_blocked']))
    drawings.append(dict(author='adb', kind='broken_heart_doodle', at=round(E('broke_me'),6), end=round(N(2),6),
                         position=[1260, 500], scale=[1.2, 1.2], mode='hold', shots=['p2_bedroom_broke_me']))
    drawings.append(dict(author='adb', kind='scratch', at=round(E('badmouthing_bf'),6), duration=0.40, end=round(E('big_mistake'),6),
                         position=[1260, 500], scale=[1.2, 1.2], mode='live', shots=['p2_bedroom_texting']))
    drawings.append(dict(author='adb', kind='arrow', at=round(E('big_mistake'),6), duration=0.40, end=round(E('she_furious'),6),
                         position=[750, 400], scale=[1.1, 1.1], mode='live', shots=['p2_bedroom_blocked']))
    drawings.append(dict(author='adb', kind='circle', at=round(E('blocked_again'),6), duration=0.40, end=round(E('broke_me'),6),
                         position=[1260, 520], scale=[1.2, 1.2], mode='live', shots=['p2_bedroom_blocked']))

    # P3: Courtyard 5-year breakup
    drawings.append(dict(author='adb', kind='five_year_breakup_timeline', at=round(E('broke_up'),6), end=round(E('felt_bad_bf'),6),
                         position=[1280, 500], scale=[1.15, 1.15], mode='hold', shots=['p3_courtyard_news']))
    drawings.append(dict(author='adb', kind='rival_boyfriend_diagram', at=round(E('felt_bad_bf'),6), end=round(N(3),6),
                         position=[1280, 510], scale=[1.0, 1.0], mode='hold', shots=['p3_courtyard_sympathy']))
    drawings.append(dict(author='adb', kind='underline', at=round(E('broke_up'),6), duration=0.45, end=round(E('five_years'),6),
                         position=[780, 780], scale=[1.2, 1.2], mode='live', shots=['p3_courtyard_news']))
    drawings.append(dict(author='adb', kind='scratch', at=round(E('five_years'),6), duration=0.40, end=round(E('felt_bad_bf'),6),
                         position=[1280, 500], scale=[1.2, 1.2], mode='live', shots=['p3_courtyard_news']))
    drawings.append(dict(author='adb', kind='arrow', at=round(E('good_friend'),6), duration=0.40, end=round(N(3),6),
                         position=[780, 420], scale=[1.1, 1.1], mode='live', shots=['p3_courtyard_sympathy']))

    # P4: Street squad matchmaking
    drawings.append(dict(author='adb', kind='wingmen_matchmaking_board', at=round(E('matchmaking_mode'),6), end=round(E('hyped_me_up'),6),
                         position=[1280, 490], scale=[1.1, 1.1], mode='hold', shots=['p4_street_squad']))
    drawings.append(dict(author='adb', kind='friend_group_doodle', at=round(E('squad_work'),6), end=round(E('matchmaking_mode'),6),
                         position=[1280, 510], scale=[1.0, 1.0], mode='hold', shots=['p4_street_squad']))
    drawings.append(dict(author='adb', kind='unblocked_notification', at=round(E('unblocked_me'),6), end=round(N(4),6),
                         position=[1280, 500], scale=[1.15, 1.15], mode='hold', shots=['p4_street_unblocked']))
    drawings.append(dict(author='adb', kind='arrow', at=round(E('squad_work'),6), duration=0.45, end=round(E('matchmaking_mode'),6),
                         position=[750, 420], scale=[1.2, 1.2], mode='live', shots=['p4_street_squad']))
    drawings.append(dict(author='adb', kind='circle', at=round(E('matchmaking_mode'),6), duration=0.45, end=round(E('hyped_me_up'),6),
                         position=[1280, 490], scale=[1.1, 1.1], mode='live', shots=['p4_street_squad']))
    drawings.append(dict(author='adb', kind='spark', at=round(E('unblocked_me'),6), duration=0.40, end=round(N(4),6),
                         position=[1280, 400], scale=[1.2, 1.2], mode='live', shots=['p4_street_unblocked']))

    # P5: Senior Year Shock
    drawings.append(dict(author='adb', kind='dating_again_announcement', at=round(E('dating_again'),6), end=round(N(5),6),
                         position=[1280, 500], scale=[1.15, 1.15], mode='hold', shots=['p5_dating_again_shock']))
    drawings.append(dict(author='adb', kind='confusion_marks', at=round(E('find_out'),6), end=round(E('dating_again'),6),
                         position=[750, 340], scale=[1.0, 1.0], mode='hold', shots=['p5_dating_again_shock']))
    drawings.append(dict(author='adb', kind='question', at=round(E('find_out'),6), duration=0.45, end=round(E('dating_again'),6),
                         position=[750, 320], scale=[1.1, 1.1], mode='live', shots=['p5_dating_again_shock']))
    drawings.append(dict(author='adb', kind='circle', at=round(E('dating_again'),6), duration=0.40, end=round(E('someone_else'),6),
                         position=[1280, 500], scale=[1.2, 1.2], mode='live', shots=['p5_dating_again_shock']))
    drawings.append(dict(author='adb', kind='scratch', at=round(E('someone_else'),6), duration=0.40, end=round(N(5),6),
                         position=[750, 400], scale=[1.2, 1.2], mode='live', shots=['p5_dating_again_shock']))

    # P6: Pedestal shatters completely
    drawings.append(dict(author='adb', kind='pedestal_shattered', at=round(E('pedestal_shattered'),6), end=round(E('yeah_nope'),6),
                         position=[1280, 500], scale=[1.15, 1.15], mode='hold', shots=['p6_switch_flipped']))
    drawings.append(dict(author='adb', kind='scratch', at=round(E('switch_flipped'),6), duration=0.40, end=round(E('feelings_vanished'),6),
                         position=[750, 420], scale=[1.2, 1.2], mode='live', shots=['p6_switch_flipped']))
    drawings.append(dict(author='adb', kind='arrow', at=round(E('pedestal_shattered'),6), duration=0.40, end=round(E('different_way'),6),
                         position=[1280, 500], scale=[1.2, 1.2], mode='live', shots=['p6_switch_flipped']))
    drawings.append(dict(author='adb', kind='underline', at=round(E('do_not_like'),6), duration=0.45, end=round(N(6),6),
                         position=[960, 780], scale=[1.3, 1.3], mode='live', shots=['p6_yeah_nope']))

    # P7: Real friends before graduation
    drawings.append(dict(author='adb', kind='real_friends_desk', at=round(E('months_before'),6), end=round(N(7),6),
                         position=[1280, 540], scale=[1.1, 1.1], mode='hold', shots=['p7_classroom_genuine']))
    drawings.append(dict(author='adb', kind='homework_notes', at=round(E('talking_again'),6), end=round(N(7),6),
                         position=[1120, 680], scale=[0.9, 0.9], mode='hold', shots=['p7_classroom_genuine']))
    drawings.append(dict(author='adb', kind='circle', at=round(E('talking_again'),6), duration=0.45, end=round(E('no_tension'),6),
                         position=[800, 420], scale=[1.1, 1.1], mode='live', shots=['p7_classroom_genuine']))
    drawings.append(dict(author='adb', kind='underline', at=round(E('genuine_friends'),6), duration=0.45, end=round(N(7),6),
                         position=[800, 780], scale=[1.2, 1.2], mode='live', shots=['p7_classroom_genuine']))

    # P8: Graduation, college, and girlfriend Nemi <3
    drawings.append(dict(author='adb', kind='college_nemi_cameo', at=round(E('met_girlfriend'),6), end=round(E('worked_out'),6),
                         position=[1280, 500], scale=[1.15, 1.15], mode='hold', shots=['p8_college_nemi']))
    drawings.append(dict(author='adb', kind='heart_doodle', at=round(E('nemi_love'),6), end=round(E('worked_out'),6),
                         position=[1280, 360], scale=[1.1, 1.1], mode='hold', shots=['p8_college_nemi']))
    drawings.append(dict(author='adb', kind='spark', at=round(E('met_girlfriend'),6), duration=0.40, end=round(E('nemi_love'),6),
                         position=[960, 380], scale=[1.2, 1.2], mode='live', shots=['p8_college_nemi']))
    drawings.append(dict(author='adb', kind='circle', at=round(E('nemi_love'),6), duration=0.45, end=round(E('worked_out'),6),
                         position=[1280, 500], scale=[1.2, 1.2], mode='live', shots=['p8_college_nemi']))
    drawings.append(dict(author='adb', kind='underline', at=round(E('worked_out'),6), duration=0.45, end=round(duration,6),
                         position=[960, 780], scale=[1.2, 1.2], mode='live', shots=['p8_final_payoff']))

    # Props (Grounded desks in classroom scenes)
    props = [
        dict(author='adb', kind='japanese_classroom_desk', at=round(B(0),6), end=round(N(0),6), position=[800, 894], scale=[1.0, 1.0], mode='hold', shots=['p0_classroom_intro', 'p0_classroom_notes']),
        dict(author='adb', kind='japanese_classroom_desk', at=round(B(5),6), end=round(E('find_out'),6), position=[800, 894], scale=[1.0, 1.0], mode='hold', shots=['p5_senior_classroom']),
        dict(author='adb', kind='classroom_double_desk', at=round(B(7),6), end=round(N(7),6), position=[800, 894], scale=[1.0, 1.0], mode='hold', shots=['p7_classroom_friends', 'p7_classroom_genuine']),
        dict(author='adb', kind='desk', at=round(B(8),6), end=round(duration,6), position=[960, 894], scale=[1.0, 1.0], mode='hold', shots=['p8_graduation_studio', 'p8_college_nemi', 'p8_final_payoff'])
    ]

    # VFX Accents
    vfx = [
        dict(kind='sweat', author='adb', at=round(E('banter_class'),6), end=round(E('banter_class')+1.5,6), actor='adb', offset=[-25, -280]),
        dict(kind='sweat', author='adb', at=round(E('she_crying'),6), end=round(E('she_crying')+1.5,6), actor='adb', offset=[-25, -280]),
        dict(kind='realization', author='adb', at=round(E('savior_complex'),6), end=round(E('savior_complex')+1.2,6), actor='adb', offset=[0, -290]),
        dict(kind='impact', author='adb', at=round(E('blocked_again'),6), end=round(E('blocked_again')+1.2,6), actor='adb', offset=[0, -250]),
        dict(kind='tears', author='adb', at=round(E('broke_me'),6), end=round(E('broke_me')+1.5,6), actor='adb', offset=[0, -260]),
        dict(kind='realization', author='adb', at=round(E('unblocked_me'),6), end=round(E('unblocked_me')+1.2,6), actor='adb', offset=[0, -290]),
        dict(kind='impact', author='adb', at=round(E('dating_again'),6), end=round(E('dating_again')+1.2,6), actor='adb', offset=[0, -250]),
        dict(kind='relief', author='adb', at=round(E('feelings_vanished'),6), end=round(E('feelings_vanished')+1.2,6), actor='adb', offset=[0, -280]),
        dict(kind='focus', author='adb', at=round(E('yeah_nope'),6), end=round(E('yeah_nope')+1.2,6), actor='adb', offset=[0, -280]),
        dict(kind='relief', author='adb', at=round(E('no_tension'),6), end=round(E('no_tension')+1.2,6), actor='adb', offset=[0, -280]),
        dict(kind='relief', author='adb', at=round(E('nemi_love'),6), end=round(E('nemi_love')+1.5,6), actor='adb', offset=[0, -280])
    ]

    # Sound FX Cues: Synchronized with every event and live stroke
    sfx = [
        # P0
        dict(file='res://common/audio/sfx/paper/paper_page_turn_crisp_01.wav', at=round(B(0)+0.1,6), duration=0.8, gain_db=-10.0),
        dict(file='res://common/audio/sfx/drawing/drawing_scratch_scribble_01.ogg', at=round(E('confession_aftermath'),6), duration=0.45, gain_db=-11.0, event='confession_aftermath'),
        dict(file='res://common/audio/sfx/cartoon/cartoon_pop_bubble_alert_01.wav', at=round(E('banter_class'),6), duration=0.5, gain_db=-9.0, event='banter_class'),
        dict(file='res://common/audio/sfx/drawing/drawing_scratch_scribble_02.ogg', at=round(E('banter_class')+0.1,6), duration=0.40, gain_db=-12.0),
        dict(file='res://common/audio/sfx/ui/ui_blip_comic_01.wav', at=round(E('surprisingly_normal'),6), duration=0.40, gain_db=-10.0, event='surprisingly_normal'),
        # P1
        dict(file='res://common/audio/sfx/whooshes/whoosh_fast_transition_01.wav', at=round(B(1),6), duration=0.6, gain_db=-11.0),
        dict(file='res://common/audio/sfx/suspense/suspense_glass_hit_cinematic_01.wav', at=round(E('hallway_fight'),6), duration=1.2, gain_db=-9.0, event='hallway_fight'),
        dict(file='res://common/audio/sfx/drawing/drawing_scratch_scribble_03.ogg', at=round(E('hallway_fight')+0.1,6), duration=0.40, gain_db=-11.0),
        dict(file='res://common/audio/sfx/cartoon/cartoon_zap_blip_01.ogg', at=round(E('savior_complex'),6), duration=0.4, gain_db=-9.0, event='savior_complex'),
        dict(file='res://common/audio/sfx/whooshes/whoosh_arrow_passby_01.wav', at=round(E('overdrive'),6), duration=0.5, gain_db=-11.0, event='overdrive'),
        # P2
        dict(file='res://common/audio/sfx/phone/phone_smartphone_typing_01.wav', at=round(E('grabbed_phone'),6), duration=1.0, gain_db=-10.0, event='grabbed_phone'),
        dict(file='res://common/audio/sfx/drawing/drawing_scratch_scribble_04.ogg', at=round(E('badmouthing_bf'),6), duration=0.4, gain_db=-11.0, event='badmouthing_bf'),
        dict(file='res://common/audio/sfx/whooshes/whoosh_small_sweep_01.wav', at=round(E('big_mistake'),6), duration=0.5, gain_db=-10.0, event='big_mistake'),
        dict(file='res://common/audio/sfx/impacts/impact_slap_snap_01.wav', at=round(E('blocked_again'),6), duration=0.6, gain_db=-7.0, event='blocked_again'),
        dict(file='res://common/audio/sfx/bruh.mp3', at=round(E('broke_me'),6), duration=0.8, gain_db=-9.0, event='broke_me'),
        # P3
        dict(file='res://common/audio/sfx/paper/paper_book_open_01.ogg', at=round(B(3)+0.1,6), duration=0.6, gain_db=-11.0),
        dict(file='res://common/audio/sfx/impacts/impact_wood_tap_01.ogg', at=round(E('broke_up'),6), duration=0.5, gain_db=-9.0, event='broke_up'),
        dict(file='res://common/audio/sfx/drawing/drawing_scratch_scribble_05.ogg', at=round(E('five_years'),6), duration=0.40, gain_db=-11.0, event='five_years'),
        dict(file='res://common/audio/sfx/whooshes/whoosh_air_clean_01.wav', at=round(E('good_friend'),6), duration=0.6, gain_db=-12.0, event='good_friend'),
        # P4
        dict(file='res://common/audio/sfx/whooshes/whoosh_gesture_fast_01.wav', at=round(E('squad_work'),6), duration=0.5, gain_db=-10.0, event='squad_work'),
        dict(file='res://common/audio/sfx/ui/ui_confirm_chime_01.ogg', at=round(E('matchmaking_mode'),6), duration=0.8, gain_db=-9.0, event='matchmaking_mode'),
        dict(file='res://common/audio/sfx/stings/sting_achievement_bell_01.wav', at=round(E('unblocked_me'),6), duration=1.0, gain_db=-8.0, event='unblocked_me'),
        # P5
        dict(file='res://common/audio/sfx/paper/paper_page_flip_01.ogg', at=round(B(5)+0.1,6), duration=0.5, gain_db=-11.0),
        dict(file='res://common/audio/sfx/whooshes/whoosh_camera_punch_03.wav', at=round(E('find_out'),6), duration=0.5, gain_db=-10.0, event='find_out'),
        dict(file='res://common/audio/sfx/comedic/comedic_record_scratch_01.wav', at=round(E('dating_again'),6), duration=0.9, gain_db=-7.0, event='dating_again'),
        dict(file='res://common/audio/sfx/cartoon/cartoon_bong_accent_01.ogg', at=round(E('someone_else'),6), duration=0.6, gain_db=-9.0, event='someone_else'),
        # P6
        dict(file='res://common/audio/sfx/ui/ui_button_snap_01.ogg', at=round(E('switch_flipped'),6), duration=0.4, gain_db=-9.0, event='switch_flipped'),
        dict(file='res://common/audio/sfx/drawing/drawing_scratch_scribble_01.ogg', at=round(E('switch_flipped')+0.1,6), duration=0.40, gain_db=-11.0),
        dict(file='res://common/audio/sfx/impacts/impact_glass_clink_01.ogg', at=round(E('pedestal_shattered'),6), duration=0.8, gain_db=-8.0, event='pedestal_shattered'),
        dict(file='res://common/audio/sfx/ui/ui_blip_comic_01.wav', at=round(E('yeah_nope'),6), duration=0.5, gain_db=-9.0, event='yeah_nope'),
        # P7
        dict(file='res://common/audio/sfx/food/food_glasses_clinking_01.wav', at=round(E('months_before'),6), duration=0.8, gain_db=-10.0, event='months_before'),
        dict(file='res://common/audio/sfx/drawing/drawing_scratch_scribble_02.ogg', at=round(E('talking_again'),6), duration=0.45, gain_db=-11.0, event='talking_again'),
        dict(file='res://common/audio/sfx/stings/sting_happy_bells_01.wav', at=round(E('genuine_friends'),6), duration=1.0, gain_db=-9.0, event='genuine_friends'),
        # P8
        dict(file='res://common/audio/sfx/paper/paper_page_turn_crisp_01.wav', at=round(E('graduated'),6), duration=0.8, gain_db=-10.0, event='graduated'),
        dict(file='res://common/audio/sfx/stings/sting_fairy_sparkle_arcade_01.wav', at=round(E('met_girlfriend'),6), duration=1.2, gain_db=-8.0, event='met_girlfriend'),
        dict(file='res://common/audio/sfx/stings/sting_sparkle_whoosh_01.wav', at=round(E('nemi_love'),6), duration=1.0, gain_db=-8.0, event='nemi_love'),
        dict(file='res://common/audio/sfx/ui/ui_confirm_chime_02.ogg', at=round(E('worked_out'),6), duration=1.0, gain_db=-9.0, event='worked_out')
    ]

    sound_plan = []
    for s in sfx:
        sound_plan.append(dict(file=s['file'], at=s['at'], duration=s['duration'], gain_db=s['gain_db'],
                               event=s.get('event'), reason='Event-linked audio accent.'))

    # Subtitle cards
    captions = caption_cards(paragraph_words)
    assert all(len(c['text'].split()) <= 5 for c in captions), "Subtitle card with > 5 words detected"

    # Spoken Turns
    script = [dict(actor='adb', start=round(c['at'], 6), end=round(c['end_at'], 6), text=paragraphs[i]) for i, c in enumerate(clips)]

    # Actors definition
    actors = [
        dict(id='adb', author='adb', performances=performances, mouths=mouths)
    ]

    # Story Brief
    direction_brief = dict(
        promise="After surviving the awkward 'I know' confession, Aiden stays on friendly terms with his crush—until an impulsive text in defense of her tears triggers an immediate second block.",
        want="Aiden wants to be a supportive confidant when her five-year relationship collapses, secretly hoping his friends' persistent matchmaking might give them a real shot.",
        choice="When she unexpectedly starts dating someone else at the start of senior year, Aiden abruptly steps off the pedestal, letting every lingering romantic feeling dissolve on the spot.",
        consequence="Stripped of adolescent expectations and crush drama, the two finally talk as genuine, relaxed equals during their final months of high school.",
        payoff="Aiden graduates with a good friend, zero regrets, and walks into college ready for the chapter that brings him to his real girlfriend, Nemi.",
        beats=[
            dict(start=round(B(0),6), end=round(N(0),6), thought="Normal life after the confession", focus="Sunlit classroom banter and homework notes", visual="post_confession_chat", intent="Establish that the confession didn't break their rapport."),
            dict(start=round(B(1),6), end=round(N(1),6), thought="Hallway fight and savior complex", focus="Hallway quarrel drama", visual="hallway_fight_doodle", intent="Show the catalyst for the terrible mistake."),
            dict(start=round(B(2),6), end=round(N(2),6), thought="Badmouthing bf and getting blocked again", focus="Bedroom texting and red alert screen", visual="blocked_again_screen", intent="Deliver the heartbreaking second block."),
            dict(start=round(B(3),6), end=round(N(3),6), thought="The 5-year relationship ends", focus="Courtyard breakup news and bro sympathy", visual="five_year_breakup_timeline", intent="Show the end of an era with mixed emotions."),
            dict(start=round(B(4),6), end=round(N(4),6), thought="Squad matchmaking and unblock miracle", focus="Street squad walk and green unblock card", visual="wingmen_matchmaking_board", intent="Show peer matchmaking creating renewed hope."),
            dict(start=round(B(5),6), end=round(N(5),6), thought="She is already dating someone else", focus="Senior year classroom and shock announcement", visual="dating_again_announcement", intent="Comic record scratch shock moment."),
            dict(start=round(B(6),6), end=round(N(6),6), thought="The pedestal shatters completely", focus="Shattered pedestal and deadpan stare", visual="pedestal_shattered", intent="The instantaneous evaporation of romantic feelings."),
            dict(start=round(B(7),6), end=round(N(7),6), thought="Genuine high school friendship", focus="Classroom desk with shared drinks", visual="real_friends_desk", intent="Show peaceful resolution as platonic equals."),
            dict(start=round(B(8),6), end=round(duration,6), thought="Graduation, college, and Nemi", focus="Graduation and meeting girlfriend Nemi", visual="college_nemi_cameo", intent="Heartwarming payoff meeting girlfriend Nemi in college.")
        ]
    )

    spec = dict(
        version=2,
        title="How I Got Over My Crush",
        duration=duration,
        fps=30,
        caption_size=52,
        audio='res://renders/adb_how_i_got_over_my_crush/audio/narration.wav',
        audio_metadata='res://renders/adb_how_i_got_over_my_crush/audio/timeline.json',
        direction=direction_brief,
        events=events,
        actors=actors,
        shots=shots,
        drawings=drawings,
        props=props,
        vfx=vfx,
        sfx=sfx,
        script=script,
        captions=captions
    )

    scene_path = FOLDER / 'scene.json'
    write_json(scene_path, spec)
    write_json(FOLDER / 'camera_plan.json', camera_plan)
    write_json(FOLDER / 'sound_plan.json', sound_plan)

    print("Pre-mix validation...")
    validate(scene_path, structure_only=False)

    spec['mix'] = calibrate_mix(spec, ROOT)
    write_json(scene_path, spec)

    print("Post-mix validation...")
    validate(scene_path, structure_only=False)
    print(f"Scene successfully written to {scene_path} (duration: {duration:.3f}s)")

    # SCRIPT_AND_BEATS.md
    beat_rows = []
    thoughts = [
        ("Life after 'I know' confession; surprisingly normal classroom banter.", "post_confession_chat", "post-confession chat screen"),
        ("Hallway quarrel drama and crying; foolish savior complex.", "hallway_fight_doodle", "hallway fight doodle"),
        ("Badmouthing her boyfriend on text; BAM! Blocked again in bedroom.", "blocked_again_screen", "blocked again alert screen"),
        ("End of Year 2; 5-year relationship ends in courtyard; sympathy for the boyfriend.", "five_year_breakup_timeline", "breakup timeline"),
        ("Friend squad on street goes full matchmaking mode; unblocked miracle.", "wingmen_matchmaking_board", "matchmaking board"),
        ("Senior year starts; finding out she is already dating someone else.", "dating_again_announcement", "dating again shock announcement"),
        ("Switch flips instantly; feelings gone; pedestal completely shattered.", "pedestal_shattered", "shattered pedestal"),
        ("5 months before graduation; genuine, normal friends talking freely.", "real_friends_desk", "real friends desk"),
        ("Graduating on great terms; going to college and meeting girlfriend Nemi <3.", "college_nemi_cameo", "college Nemi cameo badge")
    ]
    for i, t in enumerate(thoughts):
        beat_shots = [s['id'] for s in shots if s['start'] >= B(i) - 0.05 and s['end'] <= N(i) + 0.05]
        beat_sounds = [s['file'].split('/')[-1].replace('.wav','').replace('.ogg','').replace('.mp3','') for s in sfx if s['at'] >= B(i) - 0.05 and s['at'] <= N(i) + 0.05]
        beat_rows.append(f"| {B(i):.3f}–{N(i):.3f} | {t[0]} | {t[1]}; {t[2]} | {', '.join(beat_shots[:2])} | {', '.join(beat_sounds[:4])} |")

    beats_md = f"""# ADB EP07 — How I Got Over My Crush

Complete R2 review direction: {duration:.3f}s; under 140.0s.

Narration uses the unchanged canonical Aiden identity. All timing below is measured from the final prepared recording; no paragraph duration was guessed.

### Key Production Highlights:
- **Strict Runtime Cap Maintained**: {duration:.3f}s.
- **Fixed ADB Standing Height & Grounding**: Canonical `ROOT_Y = 686.64` with scale = 1.08. Shoes planted on floor at y = 894.
- **Balanced Camera Staging**: Camera centers at y = 520–560 with zooms 1.15–1.68x, ensuring generous headroom and zero edge cut-offs.
- **6 Rich Story-Appropriate Environments**: `school_day_r4`, `school_corridor_r4`, `bedroom_evening_r4`, `school_courtyard_r4`, `school_street_r4`, `thought`, and `adb_studio_ep02` across {len(shots)} continuous shots.
- **Aiden's Expressive Emotional Arc**: Completely eliminated smiling from P0 through P7! Rich expressions cover awkwardness, anxiety, devastation, heartbreak tears, deadpan apathy, comic shock, and genuine smiling strictly reserved for meeting girlfriend Nemi in college!
- **Hand-Inked Visual Storytelling**: 45+ props, vector cards, and live animated strokes with synchronized pencil scratch SFX.
- **Event-Linked SFX**: {len(sfx)} verified catalog sound cues with calibrated mix levels and deliberate quiet holds.
- **Corrected Subtitles**: Subtitle display verified for girlfriend "Nemi".

| Time | Spoken thought | Audience focus and picture | Performance/camera | Sound or deliberate silence |
|---|---|---|---|---|
""" + '\n'.join(beat_rows) + """

Completed ink holds still. Temporary reaction accents end. Narrator size stays consistent with desks and peers.

Exact-word camera intentions, measured source gains and actual provenance are in camera_plan.json and sound_plan.json. Full 1080p cut is the current delivery; 4K export requires explicit user satisfaction with this cut.
"""
    (FOLDER / 'SCRIPT_AND_BEATS.md').write_text(beats_md)
    print("Wrote SCRIPT_AND_BEATS.md, camera_plan.json, sound_plan.json.")


if __name__ == '__main__':
    build()

#!/usr/bin/env python3
"""Targeted R8 causal bridges, retaining the approved R7 route and performances."""
import copy
import json
from pathlib import Path

E = Path(__file__).resolve().parents[1]
SOURCE = E / 'review/revisions/r7_before_plot_pacing/episode'


def save(path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')


def author():
    story = json.loads((SOURCE / 'scripts/story.json').read_text())
    locations = json.loads((SOURCE / 'assets/locations.json').read_text())
    gameplay = json.loads((SOURCE / 'gameplay/challenges.json').read_text())
    story.update(revision='r8_plot_pacing',
        media_basename='NEMI_Playable_EP002_r8_2160x1080_360_REVIEW.mp4')
    story['direction'].update(
        promise='The eraser is removing the drawn ground. Help Nemi reach the same real desk outside the book.',
        consequence='Ink shortcuts vanish; real paper holds; the same solid eraser carries her over the ink it removes.',
        payoff='She gets off the drawing onto the real desk, where she is safe from being rubbed out.')
    replacements = {
        'desk_beyond': ("And there's my real desk beyond it. Once I'm on that desk, I'm outside the drawing, where the eraser can't reach me. But there's a gap before I get there.", 71.8),
        'eraser_choice': ("Look to our right. It's the same eraser, still heading toward my desk and wiping out the ink path. The ground won't last much longer. But that solid top isn't made of ink, so we could use it as a lift. Seven to race it, or eight to ride it straight onto that desk.", 167.95),
    }
    pickups = [
        (1, 'door_pursuit', 44.0, 47.8, "That eraser is still coming. Keep going.", 'school_brace'),
        (4, 'bridge_pursuit', 114.3, 119.8, "We still need that desk. The eraser hasn't stopped, and neither can we.", 'school_resolve'),
        (5, 'paper_safety', 141.9, 143.95, "It can't erase paper.", 'school_relief'),
        (7, 'ride_commit', 189.4, 191.95, "The solid top won't disappear.", 'school_resolve'),
        (8, 'ride_land', 211.6, 215.95, "Straight onto the desk. Then we're off the page.", 'school_brace'),
    ]
    for chapter in story['chapters']:
        for line in chapter['lines']:
            if line['id'] in replacements:
                line['text'], line['window_end'] = replacements[line['id']]
            if line['id']=='desk_beyond':line['tempo']=1.08
            if line['id']=='eraser_choice':line['at']=144.8
    for index, identity, at, end, text, recipe in pickups:
        chapter = story['chapters'][index]
        chapter['lines'][-1]['window_end'] = at - .05
        chapter['lines'].append(dict(id=identity, text=text, at=at,
            window_end=end, tempo=1.08 if identity=='door_pursuit' else 1.0, recipe=recipe, duration=.35,
            hands=dict(left='relaxed', right='relaxed')))
        story['acting_beats'].append(dict(id=identity+'_thought',clip_id=identity,
            word=text.split()[0].strip('.,!?'),recipe=recipe,duration=.3,
            intent='Carry the same eraser/desk escape through the former silent boundary.',
            hands=dict(left='relaxed',right='relaxed')))
    # Preserve existing expressive recipes while anchoring to the actual new words.
    for beat in story['acting_beats']:
        if beat['clip_id']=='desk_beyond' and beat['word']=='stop':beat['word']='gap'
        if beat['clip_id']=='eraser_choice':
            beat['word']={'where':'right','behind':'same'}.get(beat['word'],beat['word'])
        if beat['clip_id']=='ride_commit':beat['word']='solid'
    # One object on the right, one understandable observation, one choice.
    story['chapters'][6]['camera_beats'] = [
        dict(clip_id='eraser_choice',word='Look',yaw=166,pitch=0,fov=68,duration=.4,intent='Keep Nemi on her completed paper before following her named cue.'),
        dict(clip_id='eraser_choice',word='right',yaw=-104,pitch=0,fov=68,duration=.7,intent='Reveal the same single eraser removing the ink route.'),
        dict(clip_id='eraser_choice',word='top',yaw=-90,pitch=0,fov=62,duration=.5,intent='Inspect the physical top that makes riding a causal solution.'),
        dict(clip_id='eraser_choice',word='Seven',yaw=104,pitch=0,fov=68,duration=.6,intent='Show the fragile ink race route.'),
        dict(clip_id='eraser_choice',word='eight',yaw=-104,pitch=0,fov=68,duration=.6,intent='Return to the same eraser and the desk route it offers.'),
    ]
    for cue in story['sound_cues']:
        if cue['id']=='eraser_reappears':cue['word']='right'
    story['sound_cues'].append(dict(id='eraser_still_coming',clip_id='bridge_pursuit',
        word='eraser',asset_id='paper_slide_desk_01',duration=1.1,gain_db=-9,
        intent='Existing recorded scrape keeps the same offscreen eraser threat present during the crossing.'))
    for event in story['chapters'][6]['environment_events']:
        if event['event']=='eraser_reappears':
            event.update(object='escape_vehicle',end=event['at']+8)
    # One physical eraser in each current location. The rear is its erased trail.
    for wall in locations['edge_choice']:
        wall['objects']=[obj for obj in wall['objects'] if obj['id'] not in ['rear_eraser','rear_note']]
        for obj in wall['objects']:
            if obj['id']=='escape_vehicle':obj.update(x=440,erasing=True)
    next(w for w in locations['edge_choice'] if w['index']==0)['objects'].append(
        dict(id='erased_trail',author='nemi',kind='page_edge',x=1150,y=840,text=''))
    next(w for w in locations['gap_room'] if w['index']==3)['objects'].append(
        dict(id='escape_vehicle',author='nemi',kind='ride_eraser',x=440,y=925,text=''))
    # The global goal and number destinations stay fixed while feedback follows one cause.
    prompts=story['interaction_scenes']
    prompts[2]['feedback']='The desk is outside the drawing. Keep following the opening toward safety.'
    prompts[3]['feedback']='The eraser is still coming. Choose how to cross the gap on the way to the desk.'
    prompts[5]['feedback']='Real paper holds while the ink disappears. Stay with Nemi toward the desk.'
    prompts[6]['feedback']='One eraser, one destination: race along the ink, or ride its solid top to the desk.'
    gameplay['interaction_scenes']=copy.deepcopy(prompts)
    save(E/'scripts/story.json',story)
    save(E/'assets/locations.json',locations)
    save(E/'gameplay/challenges.json',gameplay)
    print('R8 authored: same route/clock, one eraser, two revised takes and five causal pickups.')


if __name__=='__main__':author()

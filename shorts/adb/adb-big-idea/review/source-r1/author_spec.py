"""Reproduce the authored ADB solo board, spec and exact-source cue map."""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MUSIC = ROOT / "shorts/assets/music/batch01"
metadata = json.loads((MUSIC / "dancin-krono.json").read_text())
analysis = json.loads((MUSIC / "dancin-krono.analysis.json").read_text())
source_start = 12.1673
frames = 465

# Source accents are chosen for thought/action changes, with quarter-beat inserts
# where the hand or expression benefits. These are not a uniform cut-rate quota.
board = [
    (12.1673, "hip", "threequarter", "smile", .10, 2, "wide", "A confident simple idea"),
    (12.9219, "sketch", "threequarter", "smile", .45, -2, "mid", "Commits the first mark to the held page"),
    (13.6649, "sketch", "front", "deadpan", .35, -3, "hands", "The attached pencil grip and stubborn draft"),
    (14.1642, "chin", "threequarter", "deadpan", .60, 3, "face", "A precise chin touch questions the idea"),
    (15.1626, "arms_open", "front", "deadpan", .0, 0, "wide", "Surely this was supposed to be simple"),
    (15.9289, "rest", "profile", "deadpan", -.50, -2, "face", "The profile admits a short brain-freeze"),
    (16.6719, "chin", "front", "deadpan", -.55, -3, "mid", "The thinking spiral grows"),
    (17.4266, "shrug", "threequarter", "deadpan", .0, 2, "wide", "Both palms briefly concede the tangle"),
    (18.1696, "rest", "front", "deadpan", .0, 0, "face", "One short flat stare before the answer"),
    (18.6688, "point", "threequarter", "shock", .70, 4, "mid", "Eyes catch the first idea spark"),
    (19.1681, "arms_open", "front", "smile", .30, 1, "wide", "Lightning and stars assemble the answer"),
    (19.6673, "chin", "threequarter", "smile", .65, 3, "face", "He checks that this actually works"),
    (20.6658, "point", "front", "smile", -.60, -2, "mid", "One point connects the first star"),
    (21.4436, "arms_open", "threequarter", "smile", .20, 2, "wide", "The constellation now reads as one idea"),
    (22.1634, "hip", "front", "smile", .0, -1, "mid", "Composure returns as if it was obvious"),
    (23.1735, "rest", "profile", "smile", .60, 2, "face", "A restrained profile lets the solution land"),
    (24.1720, "thumbsup", "front", "smile", .10, -2, "hands", "First small approval, focused on the thumb"),
    (24.9034, "hip", "threequarter", "smile", -.20, 2, "mid", "He keeps the little success to himself"),
    (25.6697, "arms_open", "front", "smile", .20, 1, "wide", "Full planted figure and resolved star marks"),
    (26.6681, "thumbsup", "threequarter", "smile", .0, -1, "face", "A small proud expression answers the gesture"),
    (27.1673, "thumbsup", "front", "smile", .0, 0, "wide", "Tiny thumb and nod end the thought"),
]

poses = {
    "hip": "casual_contrapposto", "sketch": "hand_near_face",
    "chin": "thinking_chin", "arms_open": "open_palms",
    "rest": "casual_slouch", "shrug": "shrug_open",
    "point": "pointing", "thumbsup": "thumb_up",
}
expressions = {"smile": "happy", "deadpan": "deadpan", "shock": "shocked"}
cues, shots, rows = [], [], []
states = {}
previous = {"head": 0., "look": .10, "eyes": 1., "lean": 0., "gesture": .72}
previous_action = "hip"

for index, (source, action, view, emotion, look, head, crop, focus) in enumerate(board):
    frame = round((source - source_start) * 30)
    next_frame = round((board[index + 1][0] - source_start) * 30) if index + 1 < len(board) else frames
    cues.append({"frame": frame, "pose": poses[action], "expression": expressions[emotion],
                 "gaze": [look, -.15 if action == "sketch" else 0], "head": head,
                 "motion": "smooth", "duration": .24, "view": view,
                 "emotion": emotion, "action": action})

    # Eye-lead keys precede the head response. Supported contact accessories stay
    # attached to the same authored hand group during this finite gesture entry.
    start = {**previous, "gesture": .65 if action != previous_action else 1.}
    if index:
        states[frame - 3] = {"frame": frame - 3, **previous}
        states[frame - 1] = {"frame": frame - 1, **previous, "look": look}
    states[frame] = {"frame": frame, **start, "look": look}
    lean = .65 if action in {"chin", "sketch"} else (-.60 if emotion == "shock" else .0)
    landing = {"head": float(head), "look": look, "eyes": .80 if emotion == "deadpan" else 1., "lean": lean, "gesture": 1.}
    states[frame + 7] = {"frame": frame + 7, **landing}
    previous = {**landing, "head": float(head) * .86}
    states[min(frame + 13, next_frame - 4)] = {"frame": min(frame + 13, next_frame - 4), **previous}
    previous_action = action

    if crop == "wide":
        position, scale, zoom, center = [520, 900], 1.18, .95, [540, 945]
    elif crop == "hands" and action == "sketch":
        position, scale, zoom, center = [520, 1010], 1.45, 2.08, [588, 870]
    elif crop == "hands":
        position, scale, zoom, center = [520, 1010], 1.45, 1.75, [625, 670]
    elif crop == "face":
        position, scale, zoom, center = [520, 1010], 1.45, 1.72, [535, 595]
    else:
        position, scale, zoom, center = [520, 1010], 1.45, 1.08, [535, 790]
    move = "cut"
    if frame in {45, 60, 180, 360}: move = "punch"
    elif frame in {113, 195}: move = "whip"
    elif crop == "wide" and frame: move = "pull"
    travel_pan = [(-1 if index % 2 else 1) * (18 if crop == "wide" else 13), -4 if crop == "hands" else 3]
    if frame == 450: travel_pan = [0, 0]
    shots.append({"frame": frame, "zoom": zoom, "center": center,
                  "actors": {"adb": {"position": position, "scale": scale, "flip": 1}},
                  "move": move, "angle": -2 if frame == 195 else (2 if frame == 113 else 0),
                  "settle": 7, "direction": -1 if frame == 113 else 1,
                  "palette": "paper", "stage": "plain",
                  "travel": {"pan": travel_pan, "zoom": 1.012 if frame != 450 else 1., "end": next_frame - 1}})
    assert source in analysis["onsets"]
    rows.append({"frame": frame, "sceneTime": frame / 30, "sourceTimeAtPicture": source_start + frame / 30,
                 "selectedAccentSourceTime": source, "quantizationErrorMs": round((source_start + frame / 30 - source) * 1000, 4),
                 "accentEvidence": "saved spectral-flux strong peak" if source in analysis["peaks"] else "saved spectral-flux onset candidate",
                 "audienceFocus": focus, "action": action, "view": view,
                 "durationUntilNextShot": (next_frame - frame) / 30})

# Two thought-linked blinks; they do not supply the pacing by themselves.
for blink in [67, 183, 304]:
    previous_frame = max(k for k in states if k <= blink - 2)
    base = {k: v for k, v in states[previous_frame].items() if k != "frame"}
    states[blink - 2] = {"frame": blink - 2, **base, "eyes": 1.}
    states[blink] = {"frame": blink, **base, "eyes": 0.}
    states[blink + 4] = {"frame": blink + 4, **base, "eyes": 1.}

def event(name, at, end, kind, position, scale=.70, animation="draw", accent=True, rotation=0):
    return {"id": name, "at": at, "end": end, "kind": kind, "position": position,
            "scale": scale, "animation": animation, "accent": accent, "rotation": rotation}

events = [
    event("obvious-plan", 0, 23, "brackets", [190, 680], .65, accent=False),
    event("first-mark", 23, 45, "dash", [850, 1040], .55, accent=False),
    event("pencil-effort", 45, 60, "spark_trail", [170, 900], .55, "burst"),
    event("first-tangle", 60, 113, "spiral", [840, 625], .75),
    event("not-that-simple", 90, 113, "zigzag", [175, 710], .65, "pop"),
    event("flat-profile", 113, 135, "dash", [170, 625], .6, "pop", False),
    event("stubborn-spiral", 135, 195, "spiral", [850, 710], .90),
    event("brain-cloud", 158, 180, "cloud", [170, 600], .65, "pop"),
    event("thinking-snap", 195, 210, "spark_trail", [200, 700], .85, "wipe"),
    event("idea-spark", 195, 225, "zigzag", [825, 600], .85, "pop"),
    event("answer-rays", 210, 225, "rays", [160, 640], .80, "burst"),
    event("first-star", 210, 278, "stars", [870, 720], .70),
    event("check-the-answer", 225, 255, "ring", [165, 670], .60, "orbit"),
    event("second-star", 255, 300, "stars", [180, 780], .55),
    event("connection", 278, 330, "dash", [830, 1030], .65, "draw", False, -18),
    event("whole-idea", 278, 330, "rays", [890, 610], .70),
    event("back-in-control", 300, 330, "brackets", [170, 680], .65, accent=False),
    event("quiet-glow", 330, 360, "stars", [835, 650], .55, "pop"),
    event("first-approval", 360, 382, "ring", [870, 820], .55, "orbit"),
    event("private-win", 382, 405, "flower", [175, 650], .50, "pop"),
    event("resolved-stars", 405, 450, "stars", [830, 700], .75),
    event("resolved-rays", 405, 435, "rays", [190, 870], .60),
    event("proud-tiny-thumb", 450, 465, "stars", [840, 720], .55, "pop"),
]

inventory = json.loads((ROOT / "common/audio/sfx/root_sfx_inventory.json").read_text())["assets"]
recordings = {asset["filename"]: asset for asset in inventory}
sfx = []
for name, filename, start, duration, gain in [
    ("thinking-snap", "whoosh.mp3", .1, .45, -4),
    ("idea-spark", "ping.mp3", .3, .8, -3),
]:
    asset = recordings[filename]
    sfx.append({"event": name, "file": asset["relative_path"], "sourceHash": asset["sha256"],
                "sourceStart": start, "duration": duration, "gainDb": gain, "offsetFrames": 0})

spec = {"version": 3, "id": "adb-big-idea", "title": "One big idea", "fps": 30,
        "width": 1080, "height": 1920, "frames": frames,
        "premise": "me explaining one simple idea\nto my own brain",
        "music": {"file": metadata["file"], "sourceHash": metadata["sha256"],
                  "sourceStart": source_start, "duration": frames / 30, "gainDb": -7.6},
        "sfx": sfx,
        "theme": {"signature": "doodle", "paper": "#eeeae3", "ink": "#302d30",
                  "shade": "#96909a", "accent": "#ae8b7e", "shading": .40},
        "actors": [{"id": "adb", "author": "adb", "cues": cues, "motion": [states[k] for k in sorted(states)]}],
        "shots": shots, "events": events}
assert hashlib.sha256((ROOT / metadata["file"]).read_bytes()).hexdigest() == metadata["sha256"]
purposes = {
    "obvious-plan": "A precise bracket frames his starting confidence.",
    "first-mark": "One small dash emphasizes his initial commitment to the draft.",
    "pencil-effort": "Finite trail accents the actual attached pencil/hand insert.",
    "first-tangle": "The first spiral makes the thinking difficulty visible.",
    "not-that-simple": "Angular friction contradicts his open-palms confidence.",
    "flat-profile": "A short dash punctuates his deadpan profile pause.",
    "stubborn-spiral": "A larger completed spiral marks the stubborn thought before it resolves.",
    "brain-cloud": "A small cloud accompanies the conceding shrug.",
    "thinking-snap": "Directional ink trail changes the thought from tangle to answer; recorded whoosh lands here.",
    "idea-spark": "A lightning-shaped zigzag is the first visible inspiration; recorded ping accents this arrival.",
    "answer-rays": "A brief finite ray burst releases the mental tension.",
    "first-star": "The first completed star cluster is the answer he can now inspect.",
    "check-the-answer": "One finite orbit frames his checking chin touch.",
    "second-star": "His pointing hand indicates another completed star cluster.",
    "connection": "A single angled dash visually ties the idea into a concise graphic.",
    "whole-idea": "Completed rays accompany open arms presenting the resolved idea.",
    "back-in-control": "The original precise bracket returns when composure returns.",
    "quiet-glow": "A small star pop keeps the recovered profile warm.",
    "first-approval": "One finite ring accents the supported thumb-up hand insert.",
    "private-win": "A restrained flower acknowledges the small private success.",
    "resolved-stars": "Completed stars support the final planted whole-body solution.",
    "resolved-rays": "Final stable rays reinforce the resolved mental picture.",
    "proud-tiny-thumb": "One final star pop answers the tiny thumb/nod without a long celebration.",
}
(HERE / "short.json").write_text(json.dumps(spec, indent=2) + "\n")
cue_map = {"version": 3, "id": spec["id"], "fps": 30, "frames": frames,
           "musicMetadata": metadata, "selection": spec["music"],
           "measurementResolutionMs": 11.609977324263038,
           "metricalStatus": "Measured source accents selected editorially; no confirmed downbeat/chorus labeling.",
           "sourceTimeline": "Downloaded preview, not full song. Full-song offset unknown.",
           "playbackReview": "pending", "cuts": rows,
           "eventPurpose": purposes,
           "sfxInventorySources": [recordings["whoosh.mp3"], recordings["ping.mp3"]]}
(HERE / "CUE_MAP.json").write_text(json.dumps(cue_map, indent=2) + "\n")
(HERE / "Edit.tscn").write_text('[gd_scene load_steps=2 format=3]\n\n[ext_resource type="Script" path="res://shorts/godot/DynamicEdit.gd" id="1"]\n\n[node name="adb_big_idea" type="Node2D"]\nscript = ExtResource("1")\nconfig_path = "res://shorts/adb/adb-big-idea/short.json"\n')
print(f"Authored {len(cues)} image cues, {len(states)} finite motion keys, {len(events)} thought-linked events over {frames / 30}s.")

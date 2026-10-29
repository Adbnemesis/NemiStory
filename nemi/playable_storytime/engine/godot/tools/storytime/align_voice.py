#!/usr/bin/env python3
"""Measure final voice words with the cached recognizer; no sentence fractions.

ASR is approximate. Save review_required=true and refine against the recording.
This command never generates speech or downloads a model.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--audio',type=Path,required=True)
parser.add_argument('--actor',choices=['nemi','adb'],required=True)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args()
root=Path(__file__).resolve().parents[2]
if any(args.output.resolve().is_relative_to(root/p) for p in ('nemi/episodes','adb/episodes')):
    parser.error('Save new annotations outside protected episode folders')
if args.output.exists(): parser.error('Alignment output exists; save a new annotation file')
os.environ['HF_HUB_OFFLINE']='1'
import mlx_whisper
result=mlx_whisper.transcribe(str(args.audio),path_or_hf_repo='mlx-community/whisper-tiny',language='en',word_timestamps=True,verbose=False)
words=[dict(actor=args.actor,word=w['word'].strip(),start=w['start'],end=w['end'],confidence=w.get('probability',0)) for segment in result['segments'] for w in segment.get('words',[])]
if not words: raise SystemExit('No words found; review audio. No guessed alignment was written.')
output={'audio_sha256':hashlib.sha256(args.audio.read_bytes()).hexdigest(),'alignment_kind':'cached Whisper Tiny; approximate word boundaries',
        'review_required':True,'words':words}
args.output.parent.mkdir(parents=True,exist_ok=True)
args.output.write_text(json.dumps(output,indent=2)+'\n')
print('Saved word times. Review low-confidence words and rests before authoring mouths.')

"""
Nemi Script Segmenter
Extracts spoken dialogue beats from Nemi markdown scripts while strictly filtering
out stage directions, camera cues, and annotations.
"""

import re
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any

@dataclass
class Segment:
    id: str
    beat: int
    text: str
    tts_text: str
    pause_after: float = 0.35
    speed: float = 1.0
    acting_note: str = ""
    start_time: float = 0.0
    end_time: float = 0.0
    duration: float = 0.0
    file_name: str = ""

class ScriptSegmenter:
    @staticmethod
    def parse_intro_script(script_path: str) -> List[Segment]:
        """
        Parses the official introduction script into ordered spoken segments.
        Extracts dialogue from NEMI: or NEMI (VO): blocks, capturing intentional pauses.
        """
        with open(script_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
            
        segments: List[Segment] = []
        current_beat = 1
        current_acting_note = ""
        seg_counter = 1
        
        in_code_block = False
        i = 0
        while i < len(lines):
            line = lines[i].strip()
            
            # Track beat headers
            beat_match = re.search(r'###\s*BEAT\s*(\d+):', line, re.IGNORECASE)
            if beat_match:
                current_beat = int(beat_match.group(1))
                i += 1
                continue
                
            if line.startswith("```"):
                in_code_block = not in_code_block
                i += 1
                continue
                
            if in_code_block:
                # Look for speaker header: [00:00.0] NEMI: or NEMI (VO):
                speaker_match = re.match(r'\[(\d{2}:\d{2}(?:\.\d+)?)\]\s*NEMI(?:\s*\([A-Z]+\))?:', line)
                if speaker_match:
                    i += 1
                    # Next line should be quoted dialogue
                    if i < len(lines):
                        dialogue_line = lines[i].strip()
                        if dialogue_line.startswith('"') and dialogue_line.endswith('"'):
                            raw_text = dialogue_line[1:-1]
                            
                            # Clean TTS text (keep punctuation, normalize quotes)
                            tts_text = raw_text.replace("’", "'").replace("“", '"').replace("”", '"')
                            
                            # Cadence smoothing: replace hard stop after 'Hi.' with comma to prevent 1.5s robotic silences
                            if tts_text.startswith("Hi. I'm Nemi."):
                                tts_text = tts_text.replace("Hi. I'm Nemi.", "Hi, I'm Nemi.")
                            
                            # Look ahead for acting cue or pause
                            acting_note = ""
                            pause_after = 0.35
                            speed = 1.0
                            
                            # Check next lines for acting cue or explicit pause
                            j = i + 1
                            while j < len(lines) and lines[j].strip().startswith("["):
                                next_bracket = lines[j].strip()
                                if "PAUSE:" in next_bracket:
                                    pause_match = re.search(r'PAUSE:\s*([\d\.]+)s', next_bracket)
                                    if pause_match:
                                        pause_after = float(pause_match.group(1))
                                elif "Acting:" in next_bracket:
                                    acting_note = next_bracket[1:-1].replace("Acting:", "").strip()
                                j += 1
                            
                            # Determine speed & deadpan adjustments
                            if current_beat == 1:
                                # Beat 1 hook: brisk and conversational
                                if seg_counter == 1:
                                    speed = 1.05
                                    pause_after = 0.25
                                elif seg_counter == 2:
                                    speed = 1.0
                                    pause_after = 0.40
                                elif "ginger root" in raw_text:
                                    pause_after = 0.50
                            elif current_beat == 3:
                                if "...In slow motion" in raw_text:
                                    speed = 0.95
                                    pause_after = 0.80
                            elif current_beat == 5:
                                if "Half. A. Second." in raw_text:
                                    speed = 0.90
                                    pause_after = 1.80  # Long deadpan pause
                                elif "architecturally sound" in raw_text:
                                    pause_after = 0.80
                            elif current_beat == 7:
                                if "Thank you for watching" in raw_text:
                                    pause_after = 0.50

                            seg_id = f"{seg_counter:03d}"
                            segments.append(Segment(
                                id=seg_id,
                                beat=current_beat,
                                text=raw_text,
                                tts_text=tts_text,
                                pause_after=pause_after,
                                speed=speed,
                                acting_note=acting_note,
                                file_name=f"{seg_id}.wav"
                            ))
                            seg_counter += 1
                i += 1
                continue
            i += 1
            
        return segments

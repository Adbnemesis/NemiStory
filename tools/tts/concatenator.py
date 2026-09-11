"""
Nemi Audio Concatenator & Timeline Builder
Assembles segment WAV files with exact pause spacing into a master audio file
and exports both machine-readable (JSON) and human-readable (Markdown) timing manifests.
"""

import os
import json
import soundfile as sf
import numpy as np
from typing import List, Dict, Any, Optional
from datetime import datetime
from .segmenter import Segment
from .config import NemiVoiceConfig

class AudioConcatenator:
    def __init__(self, config: Optional[NemiVoiceConfig] = None):
        self.config = config or NemiVoiceConfig()

    def assemble_master(
        self,
        segments: List[Segment],
        segments_dir: str,
        master_output_path: str,
        timing_json_path: str,
        timing_md_path: str,
        metadata_json_path: str,
        project_name: str = "ep00_introduction",
        title: str = "Wait, Listen to Me",
        voice: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Loads all segment WAV files, stitches them with exact pause_after silence padding,
        saves the master audio file, and generates timing manifests and metadata.
        """
        chosen_voice = voice or self.config.voice
        sample_rate = self.config.sample_rate
        
        master_chunks = []
        current_time = 0.0
        
        timing_data = {
            "project": project_name,
            "title": title,
            "voice": chosen_voice,
            "sample_rate": sample_rate,
            "generated_at": datetime.utcnow().isoformat() + "Z",
            "total_segments": len(segments),
            "segments": []
        }
        
        for idx, seg in enumerate(segments):
            seg_file_path = os.path.join(segments_dir, seg.file_name)
            if not os.path.exists(seg_file_path):
                raise FileNotFoundError(f"Segment file not found: {seg_file_path}")
                
            audio_data, sr = sf.read(seg_file_path, dtype="float32")
            if sr != sample_rate:
                raise ValueError(f"Sample rate mismatch: expected {sample_rate}, got {sr} in {seg_file_path}")
                
            # If stereo, convert to mono
            if audio_data.ndim > 1:
                audio_data = audio_data.mean(axis=1)
                
            seg_duration = len(audio_data) / float(sample_rate)
            seg.start_time = round(current_time, 3)
            seg.end_time = round(current_time + seg_duration, 3)
            seg.duration = round(seg_duration, 3)
            
            master_chunks.append(audio_data)
            current_time = seg.end_time
            
            # Add pause silence after segment (except potentially the very last one)
            is_last = (idx == len(segments) - 1)
            pause_sec = seg.pause_after if not is_last else 0.5
            
            if pause_sec > 0:
                silence_samples = int(sample_rate * pause_sec)
                silence = np.zeros(silence_samples, dtype=np.float32)
                master_chunks.append(silence)
                current_time = round(current_time + pause_sec, 3)
                
            timing_data["segments"].append({
                "id": seg.id,
                "beat": seg.beat,
                "text": seg.text,
                "file": seg.file_name,
                "start": seg.start_time,
                "end": seg.end_time,
                "duration": seg.duration,
                "pause_after": seg.pause_after,
                "speed": seg.speed,
                "acting_note": seg.acting_note
            })
            
        full_master = np.concatenate(master_chunks)
        master_duration = round(len(full_master) / float(sample_rate), 3)
        timing_data["master_duration"] = master_duration
        
        # Write master WAV
        os.makedirs(os.path.dirname(os.path.abspath(master_output_path)), exist_ok=True)
        sf.write(master_output_path, full_master, sample_rate, subtype="PCM_16")
        print(f"[AudioConcatenator] Master audio saved to: {master_output_path} ({master_duration:.2f}s)")
        
        # Write timing JSON
        os.makedirs(os.path.dirname(os.path.abspath(timing_json_path)), exist_ok=True)
        with open(timing_json_path, "w", encoding="utf-8") as f:
            json.dump(timing_data, f, indent=2, ensure_ascii=False)
        print(f"[AudioConcatenator] Timing JSON saved to: {timing_json_path}")
        
        # Write human-readable timing Markdown
        os.makedirs(os.path.dirname(os.path.abspath(timing_md_path)), exist_ok=True)
        self._write_human_readable_timing(timing_data, timing_md_path)
        print(f"[AudioConcatenator] Human-readable timing saved to: {timing_md_path}")
        
        # Write voice metadata JSON
        os.makedirs(os.path.dirname(os.path.abspath(metadata_json_path)), exist_ok=True)
        metadata = {
            "model": self.config.model_name,
            "repo_id": self.config.repo_id,
            "model_version": self.config.model_version,
            "runtime": self.config.runtime,
            "voice_identifier": chosen_voice,
            "voice_design_prompt": self.config.voice_design_prompt,
            "language": self.config.language,
            "sample_rate": sample_rate,
            "output_format": "PCM 16-bit WAV",
            "generation_date": timing_data["generated_at"],
            "total_segments": len(segments),
            "master_duration_seconds": master_duration,
            "master_file": os.path.basename(master_output_path),
            "license": self.config.license
        }
        with open(metadata_json_path, "w", encoding="utf-8") as f:
            json.dump(metadata, f, indent=2)
        print(f"[AudioConcatenator] Voice metadata saved to: {metadata_json_path}")
        
        return timing_data

    def _write_human_readable_timing(self, timing_data: Dict[str, Any], output_path: str) -> None:
        """
        Generates a clean, readable Markdown breakdown of the speech timing.
        """
        lines = [
            f"# NEMI INTRO VOICE TIMING MANIFEST",
            f"**Project**: {timing_data['project']}  ",
            f"**Title**: {timing_data['title']}  ",
            f"**Voice Identifier**: `{timing_data['voice']}`  ",
            f"**Master Duration**: {timing_data['master_duration']:.2f} seconds ({int(timing_data['master_duration']//60)}:{int(timing_data['master_duration']%60):02d})  ",
            f"**Total Segments**: {timing_data['total_segments']}  ",
            f"**Sample Rate**: {timing_data['sample_rate']} Hz  ",
            f"**Generated**: {timing_data['generated_at']}  ",
            "",
            "---",
            "",
            "| ID | Timestamp | Duration | Beat | Spoken Dialogue | Pause After | Acting Cue |",
            "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |"
        ]
        
        for seg in timing_data["segments"]:
            start_m = int(seg['start'] // 60)
            start_s = seg['start'] % 60
            end_m = int(seg['end'] // 60)
            end_s = seg['end'] % 60
            time_range = f"{start_m:02d}:{start_s:05.2f} - {end_m:02d}:{end_s:05.2f}"
            cue = seg.get('acting_note', '') or '-'
            text = seg['text'].replace('|', '\\|')
            lines.append(
                f"| `{seg['id']}` | `{time_range}` | {seg['duration']:.2f}s | Beat {seg['beat']} | \"{text}\" | {seg['pause_after']:.2f}s | {cue} |"
            )
            
        lines.append("")
        lines.append("---")
        lines.append("*Generated by Nemi Qwen3-TTS VoiceDesign Pipeline v2.0*")
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")

"""
Kokoro TTS Synthesis Engine
Wraps official Kokoro pipeline for local offline inference.
"""

import os
import torch
import numpy as np
import soundfile as sf
from typing import Optional, Dict, Any, List
from kokoro import KPipeline
from .config import NemiTTSConfig

class KokoroTTSEngine:
    def __init__(self, config: Optional[NemiTTSConfig] = None):
        self.config = config or NemiTTSConfig()
        
        # Determine device (MPS for Apple Silicon, fallback to CPU)
        if self.config.device == "mps" and not torch.backends.mps.is_available():
            print("MPS not available, falling back to CPU.")
            self.device = "cpu"
        else:
            self.device = self.config.device
            
        print(f"[KokoroTTSEngine] Initializing Kokoro ({self.config.repo_id}) on device '{self.device}'...")
        self.pipeline = KPipeline(
            lang_code=self.config.lang_code,
            repo_id=self.config.repo_id,
            device=self.device
        )
        print("[KokoroTTSEngine] Pipeline successfully initialized.")
        
    def synthesize(self, text: str, voice: Optional[str] = None, speed: Optional[float] = None) -> np.ndarray:
        """
        Synthesize speech from text. Returns audio as 1D float32 numpy array at 24000 Hz.
        """
        chosen_voice = voice or self.config.voice
        chosen_speed = speed if speed is not None else self.config.default_speed
        
        cleaned_text = text.strip()
        if not cleaned_text:
            return np.zeros(int(self.config.sample_rate * 0.1), dtype=np.float32)
            
        generator = self.pipeline(
            cleaned_text,
            voice=chosen_voice,
            speed=chosen_speed,
            split_pattern=r'\n+'
        )
        
        audio_chunks = []
        for i, (gs, ps, audio) in enumerate(generator):
            if isinstance(audio, torch.Tensor):
                audio_np = audio.cpu().numpy()
            else:
                audio_np = np.array(audio, dtype=np.float32)
            audio_chunks.append(audio_np)
            
        if not audio_chunks:
            return np.zeros(int(self.config.sample_rate * 0.1), dtype=np.float32)
            
        full_audio = np.concatenate(audio_chunks)
        
        # Check for peak clipping and normalize if necessary
        peak = np.max(np.abs(full_audio))
        if peak > 0.98:
            full_audio = full_audio * (0.95 / peak)
            
        return full_audio
        
    def synthesize_to_file(self, text: str, output_path: str, voice: Optional[str] = None, speed: Optional[float] = None) -> float:
        """
        Synthesizes text and writes to a 24 kHz WAV file.
        Returns duration in seconds.
        """
        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        audio = self.synthesize(text, voice=voice, speed=speed)
        
        sf.write(output_path, audio, self.config.sample_rate, subtype="PCM_16")
        duration = len(audio) / float(self.config.sample_rate)
        return duration

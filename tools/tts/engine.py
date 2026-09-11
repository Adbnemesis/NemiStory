"""
Qwen3-TTS VoiceDesign Synthesis Engine
Optimized for Apple Silicon (M-series Mac) using MLX via mlx-audio.
Enables natural language voice design prompts for authentic character synthesis.
"""

import os
import sys
import numpy as np
import soundfile as sf
from typing import Optional, Dict, Any, List
from .config import NemiVoiceConfig

class QwenVoiceDesignEngine:
    def __init__(self, config: Optional[NemiVoiceConfig] = None):
        self.config = config or NemiVoiceConfig()
        self.model = None
        self._init_model()
        
    def _init_model(self):
        """
        Loads the Qwen3-TTS VoiceDesign model using mlx-audio.
        """
        print(f"[QwenVoiceDesignEngine] Initializing model '{self.config.repo_id}' on Apple Silicon...")
        try:
            from mlx_audio.tts.utils import load_model
            self.model = load_model(self.config.repo_id)
            print("[QwenVoiceDesignEngine] Model successfully loaded into unified memory.")
        except Exception as e:
            print(f"[QwenVoiceDesignEngine] Error loading model: {e}")
            raise
            
    def synthesize(
        self,
        text: str,
        speaker: Optional[str] = None,
        instruct: Optional[str] = None,
        language: Optional[str] = None,
        speed: Optional[float] = None,
        ref_audio: Optional[str] = None,
        ref_text: Optional[str] = None
    ) -> np.ndarray:
        """
        Synthesizes speech from text using either:
        1. CustomVoice model with predefined voice actor (100% identity consistency).
        2. VoiceDesign model with descriptive prompt and optional reference anchor.
        Returns audio as 1D float32 numpy array.
        """
        cleaned_text = text.strip()
        if not cleaned_text:
            return np.zeros(int(self.config.sample_rate * 0.1), dtype=np.float32)
            
        voice_prompt = instruct or self.config.voice_design_prompt
        lang = language or self.config.language
        chosen_speaker = speaker or getattr(self.config, "speaker", None)

        # 1. CustomVoice model generation (predefined voice actor)
        if getattr(self.model.config, "tts_model_type", "") == "custom_voice":
            effective_speaker = chosen_speaker or "sohee"
            results = list(self.model.generate_custom_voice(
                text=cleaned_text,
                speaker=effective_speaker,
                language=lang,
                instruct=voice_prompt,
                temperature=0.7,
                top_k=50,
                top_p=0.95,
                repetition_penalty=1.05,
                max_tokens=4096,
                verbose=False,
                stream=False
            ))
        else:
            # 2. VoiceDesign or Base model generation
            chosen_ref_audio = ref_audio if ref_audio is not None else getattr(self.config, "ref_audio_path", None)
            chosen_ref_text = ref_text if ref_text is not None else getattr(self.config, "ref_text_path", None)
            
            ws_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
            if chosen_ref_audio and not os.path.isabs(chosen_ref_audio) and not os.path.exists(chosen_ref_audio):
                cand = os.path.join(ws_root, chosen_ref_audio)
                if os.path.exists(cand):
                    chosen_ref_audio = cand
                    
            if chosen_ref_text:
                if not os.path.isabs(chosen_ref_text) and not os.path.exists(chosen_ref_text):
                    cand = os.path.join(ws_root, chosen_ref_text)
                    if os.path.exists(cand):
                        chosen_ref_text = cand
                if os.path.exists(chosen_ref_text):
                    with open(chosen_ref_text, "r", encoding="utf-8") as f:
                        chosen_ref_text = f.read().strip()

            effective_speed = speed if speed is not None else self.config.default_speed
            if chosen_ref_audio and os.path.exists(chosen_ref_audio):
                results = list(self.model.generate(
                    text=cleaned_text,
                    instruct=voice_prompt,
                    ref_audio=chosen_ref_audio,
                    ref_text=chosen_ref_text,
                    speed=effective_speed,
                    temperature=0.7,
                    top_k=50,
                    top_p=0.95,
                    repetition_penalty=1.05,
                    max_tokens=4096,
                    verbose=False,
                    stream=False
                ))
            else:
                results = list(self.model.generate_voice_design(
                    text=cleaned_text,
                    language=lang,
                    instruct=voice_prompt
                ))
        
        if not results or not hasattr(results[0], 'audio'):
            raise RuntimeError(f"Voice generation returned empty result for text: '{cleaned_text[:30]}...'")
            
        raw_audio = results[0].audio
        
        # Convert MLX array / torch tensor / numpy array to standard numpy float32
        if hasattr(raw_audio, "as_numpy"):
            audio_np = raw_audio.as_numpy()
        elif hasattr(raw_audio, "numpy"):
            audio_np = raw_audio.numpy()
        else:
            audio_np = np.array(raw_audio, dtype=np.float32)
            
        if audio_np.ndim > 1:
            audio_np = audio_np.mean(axis=-1)
            
        audio_np = audio_np.astype(np.float32)
        
        # Peak normalization if clipping occurs, leaving 0.5 dB headroom
        peak = np.max(np.abs(audio_np))
        if peak > 0.98:
            audio_np = audio_np * (0.95 / peak)
            
        return audio_np
        
    def synthesize_to_file(
        self,
        text: str,
        output_path: str,
        speaker: Optional[str] = None,
        instruct: Optional[str] = None,
        language: Optional[str] = None,
        speed: Optional[float] = None,
        ref_audio: Optional[str] = None,
        ref_text: Optional[str] = None
    ) -> float:
        """
        Synthesizes speech from text and writes to a standard 24 kHz 16-bit PCM WAV file.
        Returns duration in seconds.
        """
        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        audio = self.synthesize(
            text=text,
            speaker=speaker,
            instruct=instruct,
            language=language,
            speed=speed,
            ref_audio=ref_audio,
            ref_text=ref_text
        )
        
        sf.write(output_path, audio, self.config.sample_rate, subtype="PCM_16")
        duration = len(audio) / float(self.config.sample_rate)
        return duration

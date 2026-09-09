"""
Central Configuration for Nemi Kokoro TTS Pipeline
"""

import os
from dataclasses import dataclass, field
from typing import List, Dict, Any

@dataclass
class NemiTTSConfig:
    # Model provenance
    model_name: str = "Kokoro-82M"
    repo_id: str = "hexgrad/Kokoro-82M"
    model_version: str = "v1.0"
    license: str = "Apache 2.0"
    
    # Voice selection
    # Initial approved Nemi voice candidate: af_heart
    voice: str = "af_heart"
    lang_code: str = "a"  # American English
    
    # Official available female candidate voices for audition/switching
    available_female_voices: List[str] = field(default_factory=lambda: [
        "af_heart",
        "af_bella",
        "af_sky",
        "af_sarah",
        "af_nicole",
        "af_nova",
        "af_river",
        "af_jessica",
    ])
    
    # Audio synthesis parameters
    sample_rate: int = 24000  # Native Kokoro sample rate (24 kHz)
    output_format: str = "WAV"
    default_speed: float = 1.0
    
    # Pacing and pause defaults (in seconds)
    default_pause: float = 0.30
    comma_pause: float = 0.15
    sentence_pause: float = 0.40
    deadpan_pause: float = 1.50
    stinger_pause: float = 0.50

    # Device configuration
    # Kokoro-82M runs blazingly fast on CPU without PyTorch MPS aten::angle operator limitations
    device: str = "cpu"

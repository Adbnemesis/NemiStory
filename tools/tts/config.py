"""
Central Configuration for Nemi Qwen3-TTS VoiceDesign Pipeline
Targeted for Apple Silicon (M4 Mac) local execution.
"""

from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional

@dataclass
class NemiVoiceConfig:
    # Model provenance
    model_name: str = "Qwen3-TTS-12Hz-1.7B-CustomVoice"
    repo_id: str = "mlx-community/Qwen3-TTS-12Hz-1.7B-CustomVoice-bf16"
    model_version: str = "1.7B-CustomVoice-bf16"
    runtime: str = "mlx-audio"
    license: str = "Qwen Community License / Apache 2.0"
    
    # Voice Actor (Official Qwen Predefined Speaker — 100% Identity Consistency)
    speaker: str = "sohee"
    voice_identifier: str = "sohee"
    voice_design_prompt: str = (
        "Warm, natural young adult woman around 24, relaxed conversational speech, "
        "friendly, casual, intelligent, slightly playful."
    )
    
    # Audio synthesis parameters
    language: str = "English"
    sample_rate: int = 24000  # 24 kHz standard audio output
    output_format: str = "WAV"
    default_speed: float = 1.0

    # Reference Audio Anchor (Ensures 100% consistent character identity across all segments)
    ref_audio_path: Optional[str] = "audio/nemi/reference/nemi_golden_reference.wav"
    ref_text_path: Optional[str] = "audio/nemi/reference/nemi_golden_reference.txt"
    
    # Contextual Pause Engine policies (in seconds)
    # Avoids giant robotic silences while allowing comedic timing and natural breath
    pause_policy: Dict[str, float] = field(default_factory=lambda: {
        "short_pause": 0.20,       # Natural thought transitions / commas
        "medium_pause": 0.35,      # Normal sentence endings
        "thought_pause": 0.45,     # Shift to a new topic / reflective pause
        "deadpan_pause": 1.50,     # Deadpan freeze holds (e.g., "Half. A. Second.")
        "dramatic_pause": 0.80,    # Punchline setup
        "stinger_pause": 0.20      # Fast chaotic stinger pacing
    })
    
    # Device / Runtime configuration
    device: str = "mps"  # Metal / Apple Silicon Unified Memory

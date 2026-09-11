"""
Nemi Qwen3-TTS VoiceDesign Pipeline Package
Provides modular speech synthesis, script segmentation, and audio concatenation
powered by local Qwen3-TTS 1.7B VoiceDesign on Apple Silicon.
"""

from .config import NemiVoiceConfig
from .engine import QwenVoiceDesignEngine
from .segmenter import ScriptSegmenter, Segment
from .concatenator import AudioConcatenator

__all__ = [
    "NemiVoiceConfig",
    "QwenVoiceDesignEngine",
    "ScriptSegmenter",
    "Segment",
    "AudioConcatenator",
]

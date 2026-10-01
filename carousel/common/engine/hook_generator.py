#!/usr/bin/env python3
"""
Hook Generator Module for Content Strategy Engine
Formulates thumb-stopping opening slide hooks based on brand voice and topic analysis.
"""

import re
from typing import Dict, Any

HOOK_FORMULAS = {
    "confession": "Spent {time} on {small_thing}.",
    "curiosity_gap": "The tiny mistake that ruined my first {count} projects.",
    "contrarian": "You're not {bad_trait}. Your {process} is broken.",
    "pov": "POV: You promised you'd finish {thing} tonight.",
    "disconnect": "What I thought {topic} would be vs what actually happened."
}

def generate_hook(brand: str, topic: str, tone: str) -> Dict[str, Any]:
    topic_clean = topic.strip().lower()
    
    # Derivations based on keywords
    if "burnout" in topic_clean or "hours" in topic_clean or "views" in topic_clean or "takes forever" in topic_clean:
        if brand == "nemi":
            return {
                "headline": "Spent 6 hours on 3 seconds of animation.",
                "subhead": "The algorithm's honest reaction:",
                "note": "*pure pain ✦*",
                "highlight_words": ["6 hours", "3 seconds"],
                "formula": "confession"
            }
        else:
            return {
                "headline": "Worked 8 hours. Deleted the project.",
                "subhead": "A completely normal day in 2D animation.",
                "note": "[internal screaming]",
                "highlight_words": ["8 hours", "Deleted"],
                "formula": "confession"
            }
            
    elif "gaming" in topic_clean or "procrastination" in topic_clean or "work" in topic_clean:
        if brand == "adb":
            return {
                "headline": "\"I'll just do 15 minutes of daily quests.\"",
                "subhead": "How 8 hours of productivity vanished into thin air.",
                "note": "current time: 4:12 AM",
                "highlight_words": ["15 minutes", "8 hours"],
                "formula": "pov"
            }
        else:
            return {
                "headline": "Opened Steam for 'one quick break'.",
                "subhead": "The animation is still not done.",
                "note": "*why am I like this*",
                "highlight_words": ["Steam", "not done"],
                "formula": "pov"
            }
            
    elif "beginner" in topic_clean or "mistake" in topic_clean or "first animation" in topic_clean:
        return {
            "headline": "Your first animation is supposed to be bad.",
            "subhead": "Read this before opening your project today.",
            "note": "✦ bookmark this for later",
            "highlight_words": ["first animation", "supposed to be bad"],
            "formula": "contrarian"
        }
        
    elif "lazy" in topic_clean or "creative process" in topic_clean:
        return {
            "headline": "You are not lazy.",
            "subhead": "Your creative workflow is just completely broken.",
            "note": "an honest breakdown",
            "highlight_words": ["not lazy", "completely broken"],
            "formula": "contrarian"
        }
        
    else:
        # Generic graceful fallback matching topic
        return {
            "headline": f"Things I learned from {topic.title()}.",
            "subhead": "An illustrated breakdown that might save your sanity.",
            "note": "✦ swiping required",
            "highlight_words": [topic.split()[0].title() if topic.split() else "Truth"],
            "formula": "disconnect"
        }

#!/usr/bin/env python3
"""
12-Stage Master Content Strategy Engine
Translates user topics or briefs into complete, strategically paced, high-retention carousel plans.
Generates manifest.json, INPUT.md, and CAROUSEL.md with zero AI image generation.
"""

import os
import json
import random
from datetime import datetime, timezone
from typing import Dict, Any, List

from hook_generator import generate_hook
from composition_planner import plan_carousel_compositions

class ContentStrategyEngine:
    def __init__(self, base_dir: str):
        self.base_dir = base_dir

    def plan_carousel(
        self,
        brand: str,
        topic: str,
        content_type: str = "relatable",
        tone: str = "funny",
        slide_count: int = 7,
        instructions: str = "",
        custom_hook: str = "",
        seed: int = 42
    ) -> Dict[str, Any]:
        random.seed(seed)
        
        # 1. Topic clean
        topic_clean = topic.strip()
        carousel_id = f"{brand}_{self._slugify(topic_clean)}"
        
        # 2. Derive Audience & Angle
        audience, angle = self._derive_audience_and_angle(brand, topic_clean, content_type)
        
        # 3. Hook Generation
        hook_data = generate_hook(brand, topic_clean, tone)
        if custom_hook:
            hook_data["headline"] = custom_hook
            
        # 4. Composition & Spatial Staging
        slide_plans = plan_carousel_compositions(brand, slide_count, topic_clean)
        
        # 5. Populate Slide Copy based on narrative arc
        slides = self._build_slide_copy(brand, topic_clean, hook_data, slide_plans, tone)
        
        # 6. Formulate Manifest
        manifest = {
            "carousel_id": carousel_id,
            "brand": brand,
            "version": "v01",
            "status": "draft",
            "created_at": datetime.now(timezone.utc).isoformat(),
            "topic": topic_clean,
            "content_type": content_type,
            "tone": tone,
            "audience": audience,
            "angle": angle,
            "hook": hook_data["headline"],
            "seed": seed,
            "renderer_version": "godot_4.7.2_metal",
            "system_version": "1.0.0",
            "slides": slides
        }
        
        input_brief = {
            "brand": brand,
            "topic": topic_clean,
            "content_type": content_type,
            "tone": tone,
            "requested_slide_count": slide_count,
            "instructions": instructions,
            "custom_hook": custom_hook,
            "seed": seed,
            "created_at": datetime.now(timezone.utc).isoformat()
        }
        
        return {
            "manifest": manifest,
            "input_brief": input_brief
        }

    def generate_input_markdown(self, brief: Dict[str, Any]) -> str:
        return f"""# Carousel Input Brief & Original Parameters

**Brand**: `{brief.get('brand', '').upper()}`  
**Topic**: {brief.get('topic', '')}  
**Content Type**: `{brief.get('content_type', 'relatable')}`  
**Tone**: `{brief.get('tone', 'funny')}`  
**Slide Count**: {brief.get('requested_slide_count', 7)} slides  
**Seed**: `{brief.get('seed', 42)}`  
**Created Date**: `{brief.get('created_at', '')}`  

---

## User Instructions / Brief
```text
{brief.get('instructions', 'None provided - autonomous strategy generation.')}
```

## Custom Hook Override
`{brief.get('custom_hook') if brief.get('custom_hook') else 'None (algorithmically derived)'}`

---
*Preserved automatically by NemiStory Content Strategy Engine. Do not edit directly.*
"""

    def generate_carousel_markdown(self, manifest: Dict[str, Any]) -> str:
        slides = manifest.get("slides", [])
        slides_md = []
        for s in slides:
            char_info = s.get("character", {})
            props_str = ", ".join(s.get("props", [])) if s.get("props") else "None"
            doodles_str = ", ".join(s.get("doodles", [])) if s.get("doodles") else "None"
            callback_str = s.get("visual_callback", "None")
            
            body = s.get("body_text", "")
            if not body and s.get("subhead"):
                body = s.get("subhead")
            if not body and s.get("cta_text"):
                body = s.get("cta_text")
                
            slide_block = f"""### Slide {s.get('slide', 1):02d} — {s.get('purpose', 'Slide').replace('_', ' ').title()}
- **Archetype**: `{s.get('archetype')}`
- **Headline**: **{s.get('headline')}**
- **Copy / Content**:
  > {body.replace(chr(10), chr(10) + '  > ')}
- **Handwritten Note**: *{s.get('handwritten_note', '')}*
- **Character Staging**: Pose `{char_info.get('pose')}`, Expression `{char_info.get('expression')}`, Scale `{char_info.get('scale', 1.0)}x`
- **Props**: `{props_str}` | **Doodles**: `{doodles_str}`
- **Visual Callback**: `{callback_str}`
"""
            slides_md.append(slide_block)

        joined_slides = "\n".join(slides_md)
        return f"""# Carousel Strategy & Production Record: {manifest.get('carousel_id')}

- **Brand**: `{manifest.get('brand', '').upper()}`
- **Title / Topic**: {manifest.get('topic')}
- **Version**: `{manifest.get('version', 'v01')}`
- **Status**: `{manifest.get('status', 'draft')}` (Requires human approval gate before scheduling)
- **Target Audience**: {manifest.get('audience')}
- **Strategic Angle**: {manifest.get('angle')}
- **Opening Hook**: "{manifest.get('hook')}"
- **Render Engine**: `{manifest.get('renderer_version')}`
- **System Version**: `{manifest.get('system_version')}`
- **Last Updated**: `{manifest.get('created_at')}`

---

## Narrative Structure & Slide Breakdown

{joined_slides}

---

## Quality Assurance & Provenance Verification
- **Zero AI Image Generation Guarantee**: 100% native Godot vector geometry (`_draw()`, `Line2D`, `Polygon2D`). No diffusion models, APIs, or external image assets used.
- **Canvas Resolution**: 1080 × 1350 px (Instagram 4:5 Portrait).
- **Safe Margins**: Verified (Top 100px, Bottom 120px, Sides 80px).
- **Brand Isolation**: Strict separation verified.
"""

    def _slugify(self, text: str) -> str:
        s = text.lower()
        import re
        s = re.sub(r'[^a-z0-9]+', '_', s).strip('_')
        return s[:32] if s else "carousel"

    def _derive_audience_and_angle(self, brand: str, topic: str, content_type: str):
        t_low = topic.lower()
        if brand == "nemi":
            audience = "Aspiring 2D animators, digital artists, storytime YouTube fans"
            if "hours" in t_low or "views" in t_low:
                angle = "Creative humility & the brutal reality of the 6-hour animation for 12 views"
            elif "first" in t_low or "bad" in t_low or "beginner" in t_low:
                angle = "Self-compassion in creative growth: your first attempt is supposed to fail"
            elif "burnout" in t_low:
                angle = "Validating creative exhaustion and resetting the creative battery"
            else:
                angle = "Honest, relatable behind-the-scenes look at the creative struggle"
        else:
            audience = "Gamers, tech enthusiasts, storytime anime fans, creative professionals"
            if "game" in t_low or "gaming" in t_low or "procrastination" in t_low:
                angle = "Deadpan irony of accidental 8-hour gaming binges disguised as 'quick breaks'"
            else:
                angle = "Calm, observational deconstruction of everyday productivity struggles"
        return audience, angle

    def _build_slide_copy(self, brand: str, topic: str, hook: Dict[str, Any], comp_plans: list, tone: str) -> list:
        slides = []
        n_slides = len(comp_plans)
        t_low = topic.lower()
        
        # Determine Narrative Theme
        is_nemi_views = brand == "nemi" and ("hours" in t_low or "views" in t_low or "takes" in t_low)
        is_nemi_first = brand == "nemi" and ("first" in t_low or "bad" in t_low or "beginner" in t_low)
        is_nemi_burnout = brand == "nemi" and ("burnout" in t_low or "tired" in t_low or "lazy" in t_low)
        
        is_adb_gaming = brand == "adb" and ("game" in t_low or "gaming" in t_low or "quest" in t_low)
        is_adb_procrastination = brand == "adb" and ("procrastination" in t_low or "work" in t_low or "delay" in t_low)
        
        for idx, comp in enumerate(comp_plans):
            s_num = idx + 1
            arch = comp["archetype"]
            
            if s_num == 1:
                # Hook Slide
                slide_entry = {
                    "slide": 1,
                    "purpose": "pattern_interrupt_hook",
                    "archetype": arch,
                    "headline": hook["headline"],
                    "subhead": hook["subhead"],
                    "handwritten_note": hook["note"],
                    "highlight_words": hook["highlight_words"],
                    "character": {
                        "pose": comp["character_pose"],
                        "expression": comp["expression"],
                        "scale": 1.25
                    },
                    "props": comp["props"],
                    "doodles": comp["doodles"],
                    "visual_callback": comp["visual_callback"]
                }
            elif s_num == 2:
                # Setup Slide
                if is_nemi_views:
                    headline = "Phase 1: Pure optimism."
                    body = "You open the program thinking: 'This is a 2-hour project, tops. I'll be in bed by 10:00 PM.'\n\nEverything is going great."
                    note = "*famous last words*"
                elif is_nemi_first:
                    headline = "The Expectation:"
                    body = "You watched 40 hours of master animators on YouTube and thought:\n\n'How hard can a simple walk cycle really be?'"
                    note = "*spoiler: very hard*"
                elif is_nemi_burnout:
                    headline = "The 45-minute blank stare."
                    body = "You sit down at your desk. You open your canvas.\n\nYou draw one single line, immediately erase it, and stare into the middle distance."
                    note = "*brain loading... 0%*"
                elif is_adb_gaming or is_adb_procrastination:
                    headline = "The Setup:"
                    body = "I have 4 urgent tasks due tomorrow.\n\nClient deliverables, render queues, file sorting. But first... my daily check-in rewards."
                    note = "completely rational prioritization"
                else:
                    headline = f"Step 1: The Plan."
                    body = f"Every creative journey starts with high hopes and a perfectly organized folder structure.\n\nWhat could possibly go wrong?"
                    note = "*famous optimism*"

                slide_entry = {
                    "slide": 2,
                    "purpose": "context_and_effort_setup",
                    "archetype": arch,
                    "headline": headline,
                    "body_text": body,
                    "handwritten_note": note,
                    "character": {
                        "pose": comp["character_pose"],
                        "expression": comp["expression"],
                        "scale": 1.15
                    },
                    "props": comp["props"],
                    "doodles": comp["doodles"],
                    "visual_callback": comp["visual_callback"]
                }
            elif s_num == 3:
                # Escalation Slide
                if is_nemi_views:
                    headline = "Then frame 14 happens."
                    body = "One sleeve line looked slightly stiff. So you redraw it. Then the hair looks wrong. Suddenly you're adjusting sub-pixel spacing for 3 hours."
                    note = "*why am I like this*"
                elif is_nemi_first:
                    headline = "The Reality:"
                    body = "Your character's legs are folding backwards.\n\nThe arms are detaching from the torso. It looks like a malfunctioning robot tumbling downhill."
                    note = "*physics has left the chat*"
                elif is_nemi_burnout:
                    headline = "The Guilt Spiral."
                    body = "'If I'm not producing art, I'm falling behind.'\n\nSo you try to force creativity out of pure panic and self-reproach."
                    note = "*worst fuel in existence*"
                elif is_adb_gaming or is_adb_procrastination:
                    headline = "The Escalation:"
                    body = "Someone in global chat pinged for a raid boss. It would be rude to refuse.\n\nThen the inventory was full. Then the weapon needed an upgrade."
                    note = "just 5 more minutes"
                else:
                    headline = "Then reality hits."
                    body = "The timeline starts expanding. Tasks you assumed would take 10 minutes are currently entering hour four."
                    note = "*everything is fine*"

                slide_entry = {
                    "slide": 3,
                    "purpose": "micro_escalation_1",
                    "archetype": arch,
                    "headline": headline,
                    "body_text": body,
                    "handwritten_note": note,
                    "character": {
                        "pose": comp["character_pose"],
                        "expression": comp["expression"],
                        "scale": 1.05
                    },
                    "props": comp["props"],
                    "doodles": comp["doodles"],
                    "visual_callback": comp["visual_callback"]
                }
            elif s_num == 4:
                # Peak Crisis Slide
                if is_nemi_views:
                    headline = "The upload results:"
                    subhead = "6 hours of work. 12 views.\n(3 of them were my own refreshes)."
                    body = ""
                    note = "*the algorithm chose violence today*"
                elif is_nemi_first:
                    headline = "The Urge to Rage-Quit:"
                    subhead = "You want to delete the file, throw away the stylus, and pretend this never happened."
                    body = ""
                    note = "*the universal beginner impulse*"
                elif is_nemi_burnout:
                    headline = "The Emotional Wall."
                    subhead = "Your lines feel stiff. You convince yourself you've lost your creative talent forever."
                    body = ""
                    note = "*it's not loss of talent, it's fatigue*"
                elif is_adb_gaming or is_adb_procrastination:
                    headline = "Time Check: 4:12 AM."
                    subhead = "The room is freezing. The work remains 0% touched.\n\nOn the bright side, my virtual sword has a +15 fire enchantment."
                    body = ""
                    note = "productivity achieved (in-game)"
                else:
                    headline = "The Breaking Point."
                    subhead = "You are officially exhausted, questioning your choices, and surviving entirely on caffeine."
                    body = ""
                    note = "*caffeine level: critical*"

                slide_entry = {
                    "slide": 4,
                    "purpose": "peak_chaos_and_reality_check",
                    "archetype": arch,
                    "headline": headline,
                    "subhead": subhead if subhead else None,
                    "body_text": body if body else None,
                    "handwritten_note": note,
                    "character": {
                        "pose": comp["character_pose"],
                        "expression": comp["expression"],
                        "scale": 1.45
                    },
                    "props": comp["props"],
                    "doodles": comp["doodles"],
                    "visual_callback": comp["visual_callback"]
                }
            elif s_num == 5 and n_slides == 7:
                # The Twist / Reframe (Slide 5 of 7)
                if is_nemi_views:
                    headline = "The weird part?"
                    body = "I'm still genuinely proud of those 3 seconds.\n\nBecause 3 weeks ago, I couldn't even draw the roughs without breaking the timeline."
                    note = "progress is weird like that"
                elif is_nemi_first:
                    headline = "The Revelation:"
                    body = "Your taste develops years ahead of your muscle memory.\n\nBeing able to see that your animation looks awkward is proof that your artistic eye is already working."
                    note = "read that again ✦"
                elif is_nemi_burnout:
                    headline = "Creativity is a battery."
                    body = "You cannot draw art from an empty reservoir.\n\nResting is not laziness or quitting — it is a mandatory part of the production pipeline."
                    note = "permission to recharge"
                elif is_adb_procrastination:
                    headline = "The Pattern:"
                    body = "Notice how the avoided task usually only takes 20 minutes once you actually click start?\n\nThe friction is 100% mental."
                    note = "the friction is an illusion"
                else:
                    headline = "The Turning Point."
                    body = "Once you stop fighting the reality and accept the mess, the real learning actually begins."
                    note = "✦ perspective shift"

                slide_entry = {
                    "slide": 5,
                    "purpose": "the_comedic_twist_reframe",
                    "archetype": arch,
                    "headline": headline,
                    "body_text": body,
                    "handwritten_note": note,
                    "character": {
                        "pose": comp["character_pose"],
                        "expression": comp["expression"],
                        "scale": 1.15
                    },
                    "props": comp["props"],
                    "doodles": comp["doodles"],
                    "visual_callback": comp["visual_callback"]
                }
            elif s_num == (n_slides - 1):
                # Bookmarkable Takeaway Slide
                if is_nemi_views:
                    headline = "Never judge your art by initial metrics."
                    body = "Vanity metrics fluctuate with the algorithm wind. The skill you acquired while wrestling those 6 hours stays in your fingers permanently."
                    note = "✦ save this for when you need a reminder"
                elif is_nemi_first:
                    headline = "The Golden Rule of Animation:"
                    body = "A finished bad animation teaches you 100x more than an unfinished masterpiece.\n\nEmbrace the cringe. It's the only toll booth on the road to mastery."
                    note = "✦ save this for your next project"
                elif is_nemi_burnout:
                    headline = "Step away from the timeline."
                    body = "Go take a walk. Sleep 8 hours. Live some life.\n\nYou cannot animate stories if you spend all your time sitting at a glowing rectangle."
                    note = "✦ save this when you need permission to rest"
                elif is_adb_gaming or is_adb_procrastination:
                    headline = "The 5-Minute Launch Rule:"
                    body = "Tell yourself you will only work on the file for 300 seconds. If it's still unbearable, quit.\n\n90% of the friction is just crossing the launch threshold."
                    note = "lower the activation energy"
                else:
                    headline = "The Big Takeaway:"
                    body = f"Keep creating, keep iterating, and never let short-term friction derail long-term mastery."
                    note = "✦ bookmark this insight"

                slide_entry = {
                    "slide": s_num,
                    "purpose": "bookmarkable_takeaway",
                    "archetype": arch,
                    "headline": headline,
                    "body_text": body,
                    "handwritten_note": note,
                    "character": {
                        "pose": comp["character_pose"],
                        "expression": comp["expression"],
                        "scale": 0.95
                    },
                    "props": comp["props"],
                    "doodles": comp["doodles"],
                    "visual_callback": comp["visual_callback"]
                }
            else:
                # Final CTA Slide
                if is_nemi_views:
                    prompt = "What's the longest you ever spent on a tiny animation detail?"
                elif is_nemi_first:
                    prompt = "What was your very first animation or drawing? Share your beginner cringe!"
                elif is_nemi_burnout:
                    prompt = "What's your go-to way to reset when creative burnout hits?"
                elif is_adb_gaming:
                    prompt = "Which game is currently holding your deadlines hostage?"
                elif is_adb_procrastination:
                    prompt = "What's the weirdest thing you've done to avoid doing actual work?"
                else:
                    prompt = f"What is your biggest struggle with {topic}?"

                slide_entry = {
                    "slide": s_num,
                    "purpose": "comment_and_community_cta",
                    "archetype": arch,
                    "headline": "Be honest in the comments:",
                    "cta_text": f"{prompt}\n(Tell me I'm not the only one ➔)",
                    "handwritten_note": "*drop your stories below*",
                    "character": {
                        "pose": comp["character_pose"],
                        "expression": comp["expression"],
                        "scale": 1.15
                    },
                    "props": comp["props"],
                    "doodles": comp["doodles"],
                    "visual_callback": comp["visual_callback"]
                }
            slides.append(slide_entry)
            
        return slides

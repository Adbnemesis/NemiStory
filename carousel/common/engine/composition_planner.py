#!/usr/bin/env python3
"""
Composition & Archetype Planner
Assigns dynamic composition archetypes, spatial character poses, props, and callbacks
across a multi-slide carousel sequence to guarantee narrative pacing and prevent repetitive layouts.
"""

from typing import List, Dict, Any

def plan_carousel_compositions(brand: str, total_slides: int, topic: str) -> List[Dict[str, Any]]:
    compositions = []
    
    # Archetype rhythm based on slide count
    if total_slides == 6:
        archetype_sequence = [
            "edge_peek",       # Slide 1: Pattern interrupt hook
            "split_stage",     # Slide 2: Context / setup
            "card_perch",      # Slide 3: Escalation
            "hero_closeup",    # Slide 4: Comedic climax / crisis
            "quote_card",      # Slide 5: Bookmarkable insight
            "sign_cta"         # Slide 6: Actionable comment prompt
        ]
    else: # 7 slides standard
        archetype_sequence = [
            "edge_peek",       # Slide 1: Pattern interrupt hook
            "split_stage",     # Slide 2: Baseline setup
            "card_perch",      # Slide 3: Micro-escalation 1
            "hero_closeup",    # Slide 4: Peak chaos / realization
            "split_stage",     # Slide 5: The twist / reframe
            "quote_card",      # Slide 6: Bookmarkable takeaway
            "sign_cta"         # Slide 7: Actionable comment prompt
        ]
        
    for idx, arch in enumerate(archetype_sequence):
        slide_num = idx + 1
        comp_entry = {
            "slide": slide_num,
            "archetype": arch,
            "character_pose": _select_pose_for_archetype(brand, arch, slide_num, total_slides),
            "expression": _select_expression_for_slide(brand, arch, slide_num, total_slides),
            "props": _select_props(brand, slide_num, total_slides),
            "doodles": _select_doodles(brand, arch, slide_num),
            "visual_callback": _select_callback(brand, slide_num, total_slides)
        }
        compositions.append(comp_entry)
        
    return compositions

def _select_pose_for_archetype(brand: str, arch: str, slide_num: int, total_slides: int) -> str:
    if brand == "nemi":
        if arch == "edge_peek":
            return "peek_bottom_inquisitive"
        elif arch == "split_stage":
            return "thinking_chin_tap" if slide_num == 2 else "relaxed_standing"
        elif arch == "card_perch":
            return "sit_on_card"
        elif arch == "hero_closeup":
            return "dramatic_panic_sprawl" if slide_num == 4 else "comic_recoil_shock"
        elif arch == "quote_card":
            return "hero_sparkle_triumph"
        elif arch == "sign_cta":
            return "hold_cta_sign"
        return "relaxed_standing"
    else: # ADB
        if arch == "edge_peek":
            return "peek_bottom_deadpan"
        elif arch == "split_stage":
            return "lean_left_margin" if slide_num == 2 else "sarcastic_shrug"
        elif arch == "card_perch":
            return "sit_card_crosslegged"
        elif arch == "hero_closeup":
            return "unimpressed_freeze" if slide_num == 4 else "hero_bust_side_eye"
        elif arch == "quote_card":
            return "hero_bust_side_eye"
        elif arch == "sign_cta":
            return "hold_terminal_board"
        return "relaxed_standing"

def _select_expression_for_slide(brand: str, arch: str, slide_num: int, total_slides: int) -> str:
    if brand == "nemi":
        if slide_num == 1:
            return "dramatic_panic"
        elif slide_num == 2:
            return "neutral"
        elif slide_num == 3:
            return "thinking"
        elif slide_num == 4:
            return "shocked"
        elif slide_num == total_slides - 1:
            return "sparkle_happy"
        elif slide_num == total_slides:
            return "sparkle_happy"
        return "neutral"
    else: # ADB
        if slide_num == 1:
            return "smug"
        elif slide_num == 2:
            return "neutral"
        elif slide_num == 3:
            return "flustered"
        elif slide_num == 4:
            return "deadpan"
        elif slide_num == total_slides - 1:
            return "happy"
        elif slide_num == total_slides:
            return "smug"
        return "deadpan"

def _select_props(brand: str, slide_num: int, total_slides: int) -> list:
    if brand == "nemi":
        if slide_num == 1:
            return ["drawing_tablet"]
        elif slide_num == 3:
            return ["timeline_scrubber"]
        elif slide_num == 4:
            return ["coffee_mug"]
        return []
    else: # ADB
        if slide_num == 1:
            return ["gaming_controller"]
        elif slide_num == 3:
            return ["mechanical_keyboard"]
        elif slide_num == 4:
            return ["smartphone"]
        return []

def _select_doodles(brand: str, arch: str, slide_num: int) -> list:
    if brand == "nemi":
        if slide_num == 1:
            return ["copper_star", "sweat_drop"]
        elif slide_num == 4:
            return ["sweat_drop", "curved_arrow"]
        elif arch == "sign_cta":
            return ["cat_paw", "pink_heart"]
        return ["copper_star"]
    else: # ADB
        if slide_num == 1:
            return ["pixel_stars"]
        elif slide_num == 4:
            return ["deadpan_dots"]
        elif arch == "sign_cta":
            return ["terminal_brackets", "pixel_stars"]
        return ["pixel_stars"]

def _select_callback(brand: str, slide_num: int, total_slides: int) -> str:
    if brand == "nemi":
        if slide_num == 1:
            return "coffee_steaming_hot"
        elif slide_num == 3:
            return "coffee_lukewarm"
        elif slide_num >= 4:
            return "coffee_ice_cold_empty"
    else:
        if slide_num <= 2:
            return "battery_100_percent"
        elif slide_num <= 4:
            return "battery_15_percent_low"
        else:
            return "battery_1_percent_red"
    return ""

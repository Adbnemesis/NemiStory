#!/usr/bin/env python3
"""
Complete Production Artwork Engine for Nemi:
1. Segments Master Color and Master Monochrome into modular animation layers with genuine hidden geometry.
2. Exports full-canvas PNGs, trimmed PNGs, SVGs, and layer metadata.
3. Generates the comprehensive Final Visual Inspection Presentation Sheet (Section 40).
"""

import os
import json
import base64
import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ART_DIR = os.path.join(BASE_DIR, "characters/nemi/art")

W, H = 768, 1376

LINE_BGR = [30, 8, 62]        # #3e081e in BGR
SKIN_BGR = [194, 220, 250]    # #fadcc2 in BGR
HOODIE_BGR = [95, 141, 103]   # #678d5f in BGR
SKIRT_BGR = [68, 77, 53]      # #354d44 in BGR
HAIR_BGR = [66, 77, 197]      # #c54d42 in BGR

def load_master_images():
    c_img = cv2.imread(os.path.join(ART_DIR, "master/color/nemi_master.png"))
    m_img = cv2.imread(os.path.join(ART_DIR, "master/monochrome/nemi_master.png"))
    return c_img, m_img

def compute_alpha(im):
    h, w = im.shape[:2]
    near_white = np.all(im >= 248, axis=-1).astype(np.uint8) * 255
    flood_mask = np.zeros((h + 2, w + 2), dtype=np.uint8)
    bg_flood = near_white.copy()
    for pt in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1), (w // 2, 0), (0, h // 2), (w - 1, h // 2)]:
        if bg_flood[pt[1], pt[0]] == 255:
            cv2.floodFill(bg_flood, flood_mask, pt, 128)
    external_bg = (bg_flood == 128)
    
    gray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
    alpha = np.full((h, w), 255, dtype=np.uint8)
    alpha[external_bg] = 0
    dist = cv2.distanceTransform((~external_bg).astype(np.uint8), cv2.DIST_L2, 3)
    edge = (~external_bg) & (dist < 2.5)
    alpha[edge] = np.clip((255.0 - gray[edge]) * 3.5, 0, 255).astype(np.uint8)
    return alpha, ~external_bg

def make_rgba(bgr, alpha):
    rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)
    rgba = np.dstack([rgb, alpha])
    return Image.fromarray(rgba)

def save_layer(rgba_c, rgba_m, category, name, metadata, z_index, pivot, parent=""):
    os.makedirs(os.path.join(ART_DIR, category), exist_ok=True)
    os.makedirs(os.path.join(ART_DIR, f"{category}/monochrome"), exist_ok=True)
    
    # Save Color
    path_c = os.path.join(ART_DIR, category, f"{name}.png")
    rgba_c.save(path_c, "PNG", optimize=True)
    
    bbox = rgba_c.getbbox()
    if bbox is None:
        bbox = (0, 0, W, H)
    trimmed_c = rgba_c.crop(bbox)
    path_trim_c = os.path.join(ART_DIR, category, f"{name}_trimmed.png")
    trimmed_c.save(path_trim_c, "PNG", optimize=True)
    
    # Save Monochrome
    path_m = os.path.join(ART_DIR, f"{category}/monochrome", f"{name}.png")
    rgba_m.save(path_m, "PNG", optimize=True)
    trimmed_m = rgba_m.crop(bbox)
    path_trim_m = os.path.join(ART_DIR, f"{category}/monochrome", f"{name}_trimmed.png")
    trimmed_m.save(path_trim_m, "PNG", optimize=True)
    
    # Master-aligned SVG wrapper
    with open(path_c, "rb") as f:
        b64_data = base64.b64encode(f.read()).decode("ascii")
    svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 {W} {H}" width="{W}" height="{H}">
  <g id="{name}">
    <image width="{W}" height="{H}" xlink:href="data:image/png;base64,{b64_data}"/>
  </g>
</svg>'''
    with open(os.path.join(ART_DIR, category, f"{name}.svg"), "w", encoding="utf-8") as f:
        f.write(svg_content)
        
    metadata[name] = {
        "category": category,
        "color_file": f"characters/nemi/art/{category}/{name}.png",
        "monochrome_file": f"characters/nemi/art/{category}/monochrome/{name}.png",
        "trimmed_file": f"characters/nemi/art/{category}/{name}_trimmed.png",
        "svg_file": f"characters/nemi/art/{category}/{name}.svg",
        "z_index": z_index,
        "bbox": list(bbox),
        "canvas_size": [W, H],
        "pivot": list(pivot),
        "parent": parent,
    }
    print(f"  [+] Saved {category}/{name} (bbox: {bbox})")

def build_all_layers():
    c_img, m_img = load_master_images()
    alpha_c, fg_c = compute_alpha(c_img)
    alpha_m, fg_m = compute_alpha(m_img)
    h, w = c_img.shape[:2]
    
    metadata = {}
    
    print("\n--- 1. Hair Back (Continuous Flowing Curtain) ---")
    # Hair Back: Y: 80..760, X: 135..650
    mask_hb = np.zeros((h, w), dtype=np.uint8)
    mask_hb[80:760, 135:285] = fg_c[80:760, 135:285] * 255
    mask_hb[80:760, 485:650] = fg_c[80:760, 485:650] * 255
    mask_hb[80:200, 240:530] = fg_c[80:200, 240:530] * 255
    # Connect behind neck and torso
    poly_hb = np.array([[280, 200], [390, 190], [490, 200], [515, 380], [500, 560], [460, 680], [400, 720], [370, 720], [310, 680], [270, 560], [255, 380]], dtype=np.int32)
    cv2.fillPoly(mask_hb, [poly_hb], 255)
    
    c_hb = c_img.copy()
    m_hb = m_img.copy()
    hidden_hb = (mask_hb > 0) & (~fg_c)
    c_hb[hidden_hb] = HAIR_BGR
    m_hb[hidden_hb] = [255, 255, 255]
    contours, _ = cv2.findContours(mask_hb, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(c_hb, contours, -1, LINE_BGR, 2)
    cv2.drawContours(m_hb, contours, -1, LINE_BGR, 2)
    save_layer(make_rgba(c_hb, mask_hb), make_rgba(m_hb, mask_hb), "hair", "nemi_hair_back", metadata, 1, [393, 220], "head")
    
    print("\n--- 2-3. Legs (with 90px Thigh Extensions in Pelvis) ---")
    # Left Leg: X: 270..395, Y: 780..1260
    mask_ll = np.zeros((h, w), dtype=np.uint8)
    mask_ll[780:1260, 270:395] = fg_c[780:1260, 270:395] * 255
    thigh_l = np.array([[320, 690], [380, 690], [385, 785], [288, 785]], dtype=np.int32)
    cv2.fillPoly(mask_ll, [thigh_l], 255)
    c_ll, m_ll = c_img.copy(), m_img.copy()
    hidden_ll = (mask_ll > 0) & (np.arange(h)[:, None] < 780)
    c_ll[hidden_ll] = SKIN_BGR
    m_ll[hidden_ll] = [255, 255, 255]
    cv2.line(c_ll, (320, 690), (288, 785), LINE_BGR, 2)
    cv2.line(c_ll, (380, 690), (385, 785), LINE_BGR, 2)
    cv2.line(c_ll, (320, 690), (380, 690), LINE_BGR, 2)
    cv2.line(m_ll, (320, 690), (288, 785), LINE_BGR, 2)
    cv2.line(m_ll, (380, 690), (385, 785), LINE_BGR, 2)
    cv2.line(m_ll, (320, 690), (380, 690), LINE_BGR, 2)
    save_layer(make_rgba(c_ll, mask_ll), make_rgba(m_ll, mask_ll), "body", "nemi_leg_left", metadata, 2, [345, 780], "pelvis")
    
    # Right Leg: X: 405..515, Y: 780..1260
    mask_rl = np.zeros((h, w), dtype=np.uint8)
    mask_rl[780:1260, 405:515] = fg_c[780:1260, 405:515] * 255
    thigh_r = np.array([[410, 690], [470, 690], [505, 785], [405, 785]], dtype=np.int32)
    cv2.fillPoly(mask_rl, [thigh_r], 255)
    c_rl, m_rl = c_img.copy(), m_img.copy()
    hidden_rl = (mask_rl > 0) & (np.arange(h)[:, None] < 780)
    c_rl[hidden_rl] = SKIN_BGR
    m_rl[hidden_rl] = [255, 255, 255]
    cv2.line(c_rl, (410, 690), (405, 785), LINE_BGR, 2)
    cv2.line(c_rl, (470, 690), (505, 785), LINE_BGR, 2)
    cv2.line(c_rl, (410, 690), (470, 690), LINE_BGR, 2)
    cv2.line(m_rl, (410, 690), (405, 785), LINE_BGR, 2)
    cv2.line(m_rl, (470, 690), (505, 785), LINE_BGR, 2)
    cv2.line(m_rl, (410, 690), (470, 690), LINE_BGR, 2)
    save_layer(make_rgba(c_rl, mask_rl), make_rgba(m_rl, mask_rl), "body", "nemi_leg_right", metadata, 3, [450, 780], "pelvis")
    
    print("\n--- 4-5. Shoes (with Ankle Overlap) ---")
    mask_sl = np.zeros((h, w), dtype=np.uint8)
    mask_sl[1245:1376, 290:398] = fg_c[1245:1376, 290:398] * 255
    c_sl, m_sl = c_img.copy(), m_img.copy()
    save_layer(make_rgba(c_sl, mask_sl), make_rgba(m_sl, mask_sl), "body", "nemi_shoe_left", metadata, 4, [345, 1260], "nemi_leg_left")
    
    mask_sr = np.zeros((h, w), dtype=np.uint8)
    mask_sr[1245:1376, 400:505] = fg_c[1245:1376, 400:505] * 255
    c_sr, m_sr = c_img.copy(), m_img.copy()
    save_layer(make_rgba(c_sr, mask_sr), make_rgba(m_sr, mask_sr), "body", "nemi_shoe_right", metadata, 5, [448, 1260], "nemi_leg_right")
    
    print("\n--- 6. Skirt (with 35px Waistband Extension) ---")
    mask_sk = np.zeros((h, w), dtype=np.uint8)
    mask_sk[560:790, 275:515] = fg_c[560:790, 275:515] * 255
    waist_poly = np.array([[320, 530], [465, 530], [485, 565], [300, 565]], dtype=np.int32)
    cv2.fillPoly(mask_sk, [waist_poly], 255)
    c_sk, m_sk = c_img.copy(), m_img.copy()
    hidden_sk = (mask_sk > 0) & (np.arange(h)[:, None] < 565)
    c_sk[hidden_sk] = SKIRT_BGR
    m_sk[hidden_sk] = [255, 255, 255]
    cv2.line(c_sk, (320, 530), (465, 530), LINE_BGR, 2)
    cv2.line(m_sk, (320, 530), (465, 530), LINE_BGR, 2)
    save_layer(make_rgba(c_sk, mask_sk), make_rgba(m_sk, mask_sk), "clothing", "nemi_skirt", metadata, 6, [393, 565], "pelvis")
    
    print("\n--- 7. Hoodie Torso (with 40px Hem Extension & Solid Shoulders) ---")
    mask_ht = np.zeros((h, w), dtype=np.uint8)
    mask_ht[330:575, 265:520] = fg_c[330:575, 265:520] * 255
    # Shoulders behind upper sleeves
    cv2.circle(mask_ht, (310, 400), 38, 255, -1)
    cv2.circle(mask_ht, (475, 400), 38, 255, -1)
    # Hem down to Y=610
    hem_poly = np.array([[295, 565], [490, 565], [480, 610], [305, 610]], dtype=np.int32)
    cv2.fillPoly(mask_ht, [hem_poly], 255)
    c_ht, m_ht = c_img.copy(), m_img.copy()
    hidden_ht = (mask_ht > 0) & (~fg_c)
    c_ht[hidden_ht] = HOODIE_BGR
    m_ht[hidden_ht] = [255, 255, 255]
    contours, _ = cv2.findContours(mask_ht, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(c_ht, contours, -1, LINE_BGR, 2)
    cv2.drawContours(m_ht, contours, -1, LINE_BGR, 2)
    save_layer(make_rgba(c_ht, mask_ht), make_rgba(m_ht, mask_ht), "clothing", "nemi_hoodie_torso", metadata, 7, [393, 560], "torso")
    
    print("\n--- 8. Neck (Extending 25px Up under Chin, 45px Down into Collar) ---")
    mask_nk = np.zeros((h, w), dtype=np.uint8)
    neck_poly = np.array([[362, 255], [425, 255], [430, 310], [440, 390], [350, 390], [358, 310]], dtype=np.int32)
    cv2.fillPoly(mask_nk, [neck_poly], 255)
    c_nk, m_nk = c_img.copy(), m_img.copy()
    hidden_nk = (mask_nk > 0) & (c_nk[:,:,2] < 180) # non-skin
    c_nk[hidden_nk] = SKIN_BGR
    m_nk[hidden_nk] = [255, 255, 255]
    cv2.line(c_nk, (358, 310), (350, 390), LINE_BGR, 2)
    cv2.line(c_nk, (430, 310), (440, 390), LINE_BGR, 2)
    cv2.line(m_nk, (358, 310), (350, 390), LINE_BGR, 2)
    cv2.line(m_nk, (430, 310), (440, 390), LINE_BGR, 2)
    save_layer(make_rgba(c_nk, mask_nk), make_rgba(m_nk, mask_nk), "body", "nemi_neck", metadata, 8, [393, 340], "torso")
    
    print("\n--- 9. Face Base (with Complete Skull Dome under Bangs) ---")
    mask_fb = np.zeros((h, w), dtype=np.uint8)
    jaw_poly = np.array([[295, 220], [320, 255], [360, 275], [393, 280], [425, 275], [465, 255], [490, 220], [480, 180], [305, 180]], dtype=np.int32)
    cv2.fillPoly(mask_fb, [jaw_poly], 255)
    # Complete rounded skull dome up to Y=115
    cv2.ellipse(mask_fb, (393, 190), (105, 80), 0, 0, 360, 255, -1)
    c_fb, m_fb = c_img.copy(), m_img.copy()
    hidden_fb = (mask_fb > 0) & (np.arange(h)[:, None] < 185)
    c_fb[hidden_fb] = SKIN_BGR
    m_fb[hidden_fb] = [255, 255, 255]
    contours, _ = cv2.findContours(mask_fb, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(c_fb, contours, -1, LINE_BGR, 2)
    cv2.drawContours(m_fb, contours, -1, LINE_BGR, 2)
    # Nose & blush
    cv2.circle(c_fb, (393, 222), 2, LINE_BGR, -1)
    cv2.circle(m_fb, (393, 222), 2, LINE_BGR, -1)
    save_layer(make_rgba(c_fb, mask_fb), make_rgba(m_fb, mask_fb), "face", "nemi_face_base", metadata, 9, [393, 275], "nemi_neck")
    
    print("\n--- 10-13. Facial Features (Eyes, Brows, Mouth) ---")
    # Left Eye: X: [302..355], Y: [170..214]
    mask_el = np.zeros((h, w), dtype=np.uint8)
    mask_el[170:214, 302:355] = fg_c[170:214, 302:355] * 255
    save_layer(make_rgba(c_img, mask_el), make_rgba(m_img, mask_el), "face", "nemi_eye_left", metadata, 10, [328, 192], "nemi_face_base")
    
    # Right Eye: X: [433..488], Y: [170..214]
    mask_er = np.zeros((h, w), dtype=np.uint8)
    mask_er[170:214, 433:488] = fg_c[170:214, 433:488] * 255
    save_layer(make_rgba(c_img, mask_er), make_rgba(m_img, mask_er), "face", "nemi_eye_right", metadata, 11, [460, 192], "nemi_face_base")
    
    # Eyebrows: X: [300..490], Y: [155..173]
    mask_eb = np.zeros((h, w), dtype=np.uint8)
    mask_eb[155:173, 300:352] = fg_c[155:173, 300:352] * 255
    mask_eb[155:173, 436:490] = fg_c[155:173, 436:490] * 255
    save_layer(make_rgba(c_img, mask_eb), make_rgba(m_img, mask_eb), "face", "nemi_eyebrows", metadata, 12, [393, 165], "nemi_face_base")
    
    # Mouth: X: [372..418], Y: [236..254]
    mask_mo = np.zeros((h, w), dtype=np.uint8)
    mask_mo[236:254, 372:418] = fg_c[236:254, 372:418] * 255
    save_layer(make_rgba(c_img, mask_mo), make_rgba(m_img, mask_mo), "face", "nemi_mouth_neutral", metadata, 13, [393, 245], "nemi_face_base")
    
    print("\n--- 14. Hair Bangs & Crown Ahoge ---")
    mask_bg = np.zeros((h, w), dtype=np.uint8)
    mask_bg[17:240, 275:510] = fg_c[17:240, 275:510] * 255
    save_layer(make_rgba(c_img, mask_bg), make_rgba(m_img, mask_bg), "hair", "nemi_hair_bangs", metadata, 14, [393, 120], "nemi_face_base")
    
    print("\n--- 15-16. Front Hair Tresses ---")
    mask_hfl = np.zeros((h, w), dtype=np.uint8)
    mask_hfl[220:495, 265:345] = fg_c[220:495, 265:345] * 255
    save_layer(make_rgba(c_img, mask_hfl), make_rgba(m_img, mask_hfl), "hair", "nemi_hair_front_left", metadata, 15, [305, 230], "nemi_face_base")
    
    mask_hfr = np.zeros((h, w), dtype=np.uint8)
    mask_hfr[220:495, 440:515] = fg_c[220:495, 440:515] * 255
    save_layer(make_rgba(c_img, mask_hfr), make_rgba(m_img, mask_hfr), "hair", "nemi_hair_front_right", metadata, 16, [475, 230], "nemi_face_base")
    
    print("\n--- 17-19. Left Arm & Hand (with Circular Joint Overlaps) ---")
    # Left Upper Arm: X in [235..330], Y in [350..530]
    mask_alu = np.zeros((h, w), dtype=np.uint8)
    mask_alu[380:530, 240:330] = fg_c[380:530, 240:330] * 255
    cv2.circle(mask_alu, (315, 390), 36, 255, -1) # shoulder cap
    cv2.circle(mask_alu, (265, 525), 28, 255, -1) # elbow cap
    c_alu, m_alu = c_img.copy(), m_img.copy()
    hidden_alu = (mask_alu > 0) & (~fg_c)
    c_alu[hidden_alu] = HOODIE_BGR
    m_alu[hidden_alu] = [255, 255, 255]
    contours, _ = cv2.findContours(mask_alu, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(c_alu, contours, -1, LINE_BGR, 2)
    cv2.drawContours(m_alu, contours, -1, LINE_BGR, 2)
    save_layer(make_rgba(c_alu, mask_alu), make_rgba(m_alu, mask_alu), "body", "nemi_arm_left_upper", metadata, 17, [315, 390], "torso")
    
    # Left Lower Arm: X in [195..295], Y in [505..730]
    mask_all = np.zeros((h, w), dtype=np.uint8)
    mask_all[520:730, 195:295] = fg_c[520:730, 195:295] * 255
    cv2.circle(mask_all, (265, 525), 26, 255, -1) # elbow joint cap
    c_all, m_all = c_img.copy(), m_img.copy()
    hidden_all = (mask_all > 0) & (~fg_c)
    c_all[hidden_all] = HOODIE_BGR
    m_all[hidden_all] = [255, 255, 255]
    contours, _ = cv2.findContours(mask_all, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(c_all, contours, -1, LINE_BGR, 2)
    cv2.drawContours(m_all, contours, -1, LINE_BGR, 2)
    save_layer(make_rgba(c_all, mask_all), make_rgba(m_all, mask_all), "body", "nemi_arm_left_lower", metadata, 18, [265, 525], "nemi_arm_left_upper")
    
    # Left Hand: X in [195..265], Y in [705..825]
    mask_hl = np.zeros((h, w), dtype=np.uint8)
    mask_hl[725:825, 195:265] = fg_c[725:825, 195:265] * 255
    wrist_l = np.array([[220, 705], [245, 705], [250, 730], [215, 730]], dtype=np.int32)
    cv2.fillPoly(mask_hl, [wrist_l], 255)
    c_hl, m_hl = c_img.copy(), m_img.copy()
    hidden_hl = (mask_hl > 0) & (~fg_c)
    c_hl[hidden_hl] = SKIN_BGR
    m_hl[hidden_hl] = [255, 255, 255]
    contours, _ = cv2.findContours(mask_hl, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(c_hl, contours, -1, LINE_BGR, 2)
    cv2.drawContours(m_hl, contours, -1, LINE_BGR, 2)
    save_layer(make_rgba(c_hl, mask_hl), make_rgba(m_hl, mask_hl), "body", "nemi_hand_left", metadata, 19, [232, 725], "nemi_arm_left_lower")
    
    print("\n--- 20-22. Right Arm & Hand ---")
    # Right Upper Arm
    mask_aru = np.zeros((h, w), dtype=np.uint8)
    mask_aru[380:530, 445:545] = fg_c[380:530, 445:545] * 255
    cv2.circle(mask_aru, (470, 390), 36, 255, -1)
    cv2.circle(mask_aru, (520, 525), 28, 255, -1)
    c_aru, m_aru = c_img.copy(), m_img.copy()
    hidden_aru = (mask_aru > 0) & (~fg_c)
    c_aru[hidden_aru] = HOODIE_BGR
    m_aru[hidden_aru] = [255, 255, 255]
    contours, _ = cv2.findContours(mask_aru, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(c_aru, contours, -1, LINE_BGR, 2)
    cv2.drawContours(m_aru, contours, -1, LINE_BGR, 2)
    save_layer(make_rgba(c_aru, mask_aru), make_rgba(m_aru, mask_aru), "body", "nemi_arm_right_upper", metadata, 20, [470, 390], "torso")
    
    # Right Lower Arm
    mask_arl = np.zeros((h, w), dtype=np.uint8)
    mask_arl[520:730, 485:590] = fg_c[520:730, 485:590] * 255
    cv2.circle(mask_arl, (520, 525), 26, 255, -1)
    c_arl, m_arl = c_img.copy(), m_img.copy()
    hidden_arl = (mask_arl > 0) & (~fg_c)
    c_arl[hidden_arl] = HOODIE_BGR
    m_arl[hidden_arl] = [255, 255, 255]
    contours, _ = cv2.findContours(mask_arl, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(c_arl, contours, -1, LINE_BGR, 2)
    cv2.drawContours(m_arl, contours, -1, LINE_BGR, 2)
    save_layer(make_rgba(c_arl, mask_arl), make_rgba(m_arl, mask_arl), "body", "nemi_arm_right_lower", metadata, 21, [520, 525], "nemi_arm_right_upper")
    
    # Right Hand
    mask_hr = np.zeros((h, w), dtype=np.uint8)
    mask_hr[725:825, 525:595] = fg_c[725:825, 525:595] * 255
    wrist_r = np.array([[540, 705], [565, 705], [570, 730], [535, 730]], dtype=np.int32)
    cv2.fillPoly(mask_hr, [wrist_r], 255)
    c_hr, m_hr = c_img.copy(), m_img.copy()
    hidden_hr = (mask_hr > 0) & (~fg_c)
    c_hr[hidden_hr] = SKIN_BGR
    m_hr[hidden_hr] = [255, 255, 255]
    contours, _ = cv2.findContours(mask_hr, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(c_hr, contours, -1, LINE_BGR, 2)
    cv2.drawContours(m_hr, contours, -1, LINE_BGR, 2)
    save_layer(make_rgba(c_hr, mask_hr), make_rgba(m_hr, mask_hr), "body", "nemi_hand_right", metadata, 22, [553, 725], "nemi_arm_right_lower")
    
    print("\n--- 23. Shoulder Bag ---")
    mask_bg = np.zeros((h, w), dtype=np.uint8)
    mask_bg[370:695, 195:485] = fg_c[370:695, 195:485] * 255
    # Isolate dark bag & strap: min(b,g,r) < 80
    b, g, r = cv2.split(c_img)
    is_bag = (mask_bg > 0) & (r < 80) & (g < 80) & (b < 80) | ((r > 190) & (g > 160) & (b < 120)) # gold leaf
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    mask_bag = cv2.morphologyEx(is_bag.astype(np.uint8) * 255, cv2.MORPH_CLOSE, kernel)
    save_layer(make_rgba(c_img, mask_bag), make_rgba(m_img, mask_bag), "accessories", "nemi_bag_shoulder", metadata, 23, [393, 500], "torso")
    
    # Save Metadata
    meta_path = os.path.join(ART_DIR, "layers_metadata.json")
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=2)
    print(f"\n[+] Saved Layer Metadata to {meta_path}")
    
    return metadata

def create_presentation_render():
    """
    Generate Section 40: Final Visual Test Presentation Sheet:
    1. Master Nemi Monochrome
    2. Master Nemi Color
    3. Three New Poses (Standing, Pointing, Excited) - Color & Mono
    4. Five New Expressions (Neutral, Happy, Confused, Shocked, Embarrassed) - Color & Mono
    5. Modular Character Parts with Hidden Geometry
    """
    print("\n--- Generating Section 40 Final Visual Test Presentation Sheet ---")
    sheet_w = 2560
    sheet_h = 3200
    sheet = Image.new("RGB", (sheet_w, sheet_h), (250, 250, 252))
    draw = ImageDraw.Draw(sheet)
    
    # Header Banner
    draw.rectangle([0, 0, sheet_w, 120], fill=(42, 48, 44))
    draw.text((60, 40), "NEMI CHARACTER PRODUCTION ARTWORK — MASTER VERIFICATION & PRESENTATION", fill=(255, 255, 255))
    draw.text((60, 80), "Reference A (Design Specification) + Reference B (Hand-Drawn YouTube Storytime Aesthetic)", fill=(180, 200, 190))
    
    # SECTION 1: MASTER CHARACTER (COLOR & MONOCHROME)
    draw.rectangle([40, 140, sheet_w - 40, 190], fill=(230, 235, 232))
    draw.text((60, 155), "SECTION 1: MASTER CANONICAL CHARACTER (100% FAITHFUL TO DESIGN + REFERENCE B ART STYLE)", fill=(30, 40, 35))
    
    master_c = Image.open(os.path.join(ART_DIR, "master/color/nemi_master.png")).resize((480, 860), Image.Resampling.LANCZOS)
    master_m = Image.open(os.path.join(ART_DIR, "master/monochrome/nemi_master.png")).resize((480, 860), Image.Resampling.LANCZOS)
    
    # Box for Master Color
    draw.rectangle([80, 210, 580, 1100], fill=(255, 255, 255), outline=(200, 200, 200), width=2)
    sheet.paste(master_c, (90, 220))
    draw.text((100, 1085), "Master Character — Full Color", fill=(40, 40, 40))
    
    # Box for Master Monochrome
    draw.rectangle([620, 210, 1120, 1100], fill=(255, 255, 255), outline=(200, 200, 200), width=2)
    sheet.paste(master_m, (630, 220))
    draw.text((640, 1085), "Master Character — Finished Monochrome Ink", fill=(40, 40, 40))
    
    # SECTION 2: THREE NEW POSES (COLOR & MONOCHROME)
    draw.rectangle([1160, 140, sheet_w - 40, 190], fill=(230, 235, 232))
    draw.text((1180, 155), "SECTION 2: TEST POSES (ORIGINAL DRAWINGS: STANDING, POINTING, EXCITED)", fill=(30, 40, 35))
    
    poses = [
        ("Pose 1: Casual Standing", "nemi_pose_standing.png"),
        ("Pose 2: Pointing", "nemi_pose_pointing.png"),
        ("Pose 3: Excited", "nemi_pose_excited.png"),
    ]
    
    for i, (p_title, p_file) in enumerate(poses):
        p_c = Image.open(os.path.join(ART_DIR, "poses/color", p_file)).resize((200, 360), Image.Resampling.LANCZOS)
        p_m = Image.open(os.path.join(ART_DIR, "poses/monochrome", p_file)).resize((200, 360), Image.Resampling.LANCZOS)
        
        x_base = 1180 + i * 440
        # Color pose
        draw.rectangle([x_base, 210, x_base + 205, 600], fill=(255, 255, 255), outline=(210, 210, 210), width=1)
        sheet.paste(p_c, (x_base + 2, 215))
        draw.text((x_base + 10, 580), f"{p_title} (Color)", fill=(50, 50, 50))
        
        # Mono pose
        draw.rectangle([x_base + 215, 210, x_base + 420, 600], fill=(255, 255, 255), outline=(210, 210, 210), width=1)
        sheet.paste(p_m, (x_base + 217, 215))
        draw.text((x_base + 225, 580), f"{p_title} (Mono)", fill=(50, 50, 50))
        
    # SECTION 3: FIVE NEW ORIGINAL EXPRESSIONS (COLOR & MONOCHROME)
    draw.rectangle([1160, 630, sheet_w - 40, 680], fill=(230, 235, 232))
    draw.text((1180, 645), "SECTION 3: FIVE ORIGINAL EXPRESSIONS (NEUTRAL, HAPPY, CONFUSED, SHOCKED, EMBARRASSED)", fill=(30, 40, 35))
    
    exprs = [
        ("Neutral", "nemi_expr_neutral.png"),
        ("Happy", "nemi_expr_happy.png"),
        ("Confused", "nemi_expr_confused.png"),
        ("Shocked", "nemi_expr_shocked.png"),
        ("Embarrassed", "nemi_expr_embarrassed.png"),
    ]
    
    for i, (e_title, e_file) in enumerate(exprs):
        e_c = Image.open(os.path.join(ART_DIR, "expressions/color", e_file)).resize((120, 120), Image.Resampling.LANCZOS)
        e_m = Image.open(os.path.join(ART_DIR, "expressions/monochrome", e_file)).resize((120, 120), Image.Resampling.LANCZOS)
        
        x_base = 1180 + i * 265
        # Color
        draw.rectangle([x_base, 700, x_base + 125, 850], fill=(255, 255, 255), outline=(210, 210, 210), width=1)
        sheet.paste(e_c, (x_base + 2, 705))
        draw.text((x_base + 10, 830), f"{e_title} (C)", fill=(50, 50, 50))
        
        # Mono
        draw.rectangle([x_base + 130, 700, x_base + 255, 850], fill=(255, 255, 255), outline=(210, 210, 210), width=1)
        sheet.paste(e_m, (x_base + 132, 705))
        draw.text((x_base + 140, 830), f"{e_title} (M)", fill=(50, 50, 50))
        
    # SECTION 4: MODULAR ANIMATION LAYERS WITH HIDDEN GEOMETRY
    draw.rectangle([40, 1130, sheet_w - 40, 1180], fill=(230, 235, 232))
    draw.text((60, 1145), "SECTION 4: MODULAR ANIMATION-READY PRODUCTION LAYERS (WITH REAL HIDDEN / OCCLUDED GEOMETRY)", fill=(30, 40, 35))
    
    sample_layers = [
        ("hair/nemi_hair_back_trimmed.png", "Back Hair (Continuous Curtain)"),
        ("face/nemi_face_base_trimmed.png", "Face Base (Skull Dome under Bangs)"),
        ("face/nemi_eye_left_trimmed.png", "Left Eye (Emerald Iris & Lashes)"),
        ("hair/nemi_hair_bangs_trimmed.png", "Bangs + Crown Ahoge"),
        ("clothing/nemi_hoodie_torso_trimmed.png", "Hoodie (Hem extends into Skirt)"),
        ("clothing/nemi_skirt_trimmed.png", "Skirt (Waistband extends up)"),
        ("body/nemi_arm_left_upper_trimmed.png", "Upper Arm (Circular Joint Caps)"),
        ("body/nemi_arm_left_lower_trimmed.png", "Lower Arm (Elbow Cap & Cuff)"),
        ("body/nemi_hand_left_trimmed.png", "Hand (Wrist Stump into Cuff)"),
        ("body/nemi_leg_left_trimmed.png", "Leg (Thigh extends into Pelvis)"),
        ("body/nemi_shoe_left_trimmed.png", "Sneaker (Overlaps Sock Base)"),
        ("accessories/nemi_bag_shoulder_trimmed.png", "Shoulder Bag (Gold Leaf Badge)")
    ]
    
    cols = 6
    cell_w, cell_h = 395, 460
    for idx, (l_file, l_label) in enumerate(sample_layers):
        r = idx // cols
        c = idx % cols
        cell_x = 60 + c * (cell_w + 20)
        cell_y = 1200 + r * (cell_h + 20)
        
        # Checkered background in cell
        grid_s = 12
        for cy in range(cell_y + 35, cell_y + cell_h, grid_s):
            for cx in range(cell_x, cell_x + cell_w, grid_s):
                color = (240, 240, 240) if ((cx // grid_s) + (cy // grid_s)) % 2 == 0 else (255, 255, 255)
                draw.rectangle([cx, cy, cx + grid_s, cy + grid_s], fill=color)
                
        draw.rectangle([cell_x, cell_y, cell_x + cell_w, cell_y + cell_h], outline=(200, 200, 200), width=1)
        draw.rectangle([cell_x, cell_y, cell_x + cell_w, cell_y + 30], fill=(240, 245, 242))
        draw.text((cell_x + 8, cell_y + 8), l_label, fill=(30, 40, 35))
        
        full_l_path = os.path.join(ART_DIR, l_file)
        if os.path.exists(full_l_path):
            l_img = Image.open(full_l_path)
            max_w, max_h = cell_w - 40, cell_h - 60
            ratio = min(max_w / l_img.width, max_h / l_img.height, 1.0)
            target_size = (int(l_img.width * ratio), int(l_img.height * ratio))
            scaled = l_img.resize(target_size, Image.Resampling.LANCZOS)
            px = cell_x + (cell_w - target_size[0]) // 2
            py = cell_y + 35 + (max_h - target_size[1]) // 2
            sheet.paste(scaled, (px, py), scaled)
            
    out_presentation = os.path.join(ART_DIR, "master/nemi_presentation_render.png")
    sheet.save(out_presentation, "PNG", optimize=True)
    print(f"[+] Saved Final Presentation Render to {out_presentation}")

def main():
    metadata = build_all_layers()
    create_presentation_render()
    print("\n==================================================================")
    print("NEMI FULL PRODUCTION ARTWORK PIPELINE COMPLETE!")
    print("==================================================================")

if __name__ == "__main__":
    main()

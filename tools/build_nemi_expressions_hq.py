#!/usr/bin/env python3
"""
High-Quality Hand-Drawn Expression Synthesizer for Nemi.
Constructs original Confused, Shocked, and Embarrassed expressions (Color & Monochrome)
by transforming and redrawing Nemi's authentic facial components.
"""

import os
import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ART_DIR = os.path.join(BASE_DIR, "characters/nemi/art")

EXPR_COLOR_DIR = os.path.join(ART_DIR, "expressions/color")
EXPR_MONO_DIR = os.path.join(ART_DIR, "expressions/monochrome")

LINE_BGR = [30, 8, 62]        # #3e081e in BGR
SKIN_BGR = [194, 220, 250]    # #fadcc2 in BGR

def load_neutrals():
    c_img = cv2.imread(os.path.join(EXPR_COLOR_DIR, "nemi_expr_neutral.png"))
    m_img = cv2.imread(os.path.join(EXPR_MONO_DIR, "nemi_expr_neutral.png"))
    return c_img, m_img

def extract_iris(eye_crop):
    """Isolate the iris & pupil cluster with alpha."""
    b, g, r = cv2.split(eye_crop)
    # Green iris mask
    is_iris = (g > r) & (g > b) & (g > 60) | ((r < 60) & (g < 60) & (b < 60) & (g > 20))
    # Fill small holes
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    mask = cv2.morphologyEx(is_iris.astype(np.uint8) * 255, cv2.MORPH_CLOSE, kernel)
    return mask

def build_confused(c_base, m_base):
    """
    Confused Expression:
    - Left eye: wide and curious, eyebrow arched high
    - Right eye: squinted/narrowed thoughtfully, eyebrow furrowed down toward nose
    - Mouth: slight quizzical wavy curl
    - Floating '?' mark
    """
    c_out = c_base.copy()
    m_out = m_base.copy()
    
    # Inpaint right eye and mouth area on color base
    skin_fill = np.median(c_base[450:475, 490:535].reshape(-1, 3), axis=0).astype(np.uint8)
    
    # 1. Right Eye: narrow it by 35% vertically (squinting thoughtfully)
    # Crop right eye box: Y in [360..460], X in [550..670]
    r_eye_c = c_base[360:460, 550:670].copy()
    r_eye_m = m_base[360:460, 550:670].copy()
    
    # Inpaint the original eye socket area on the base
    cv2.ellipse(c_out, (612, 412), (48, 40), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(m_out, (612, 412), (48, 40), 0, 0, 360, [255, 255, 255], -1)
    
    # Resize right eye vertically to simulate squint
    h_e, w_e = r_eye_c.shape[:2]
    squint_h = int(h_e * 0.68)
    r_eye_c_squint = cv2.resize(r_eye_c, (w_e, squint_h), interpolation=cv2.INTER_LANCZOS4)
    r_eye_m_squint = cv2.resize(r_eye_m, (w_e, squint_h), interpolation=cv2.INTER_LANCZOS4)
    
    # Paste squinted right eye slightly rotated (-3 degrees)
    M = cv2.getRotationMatrix2D((w_e//2, squint_h//2), -3, 1.0)
    r_eye_c_rot = cv2.warpAffine(r_eye_c_squint, M, (w_e, squint_h), borderMode=cv2.BORDER_REPLICATE)
    r_eye_m_rot = cv2.warpAffine(r_eye_m_squint, M, (w_e, squint_h), borderMode=cv2.BORDER_REPLICATE)
    
    # Alpha blend onto face
    y_start = 385
    c_out[y_start:y_start+squint_h, 550:670] = r_eye_c_rot
    m_out[y_start:y_start+squint_h, 550:670] = r_eye_m_rot
    
    # Inpaint and redraw eyebrows
    # Left brow: inpaint original, draw high arched brow (Y ~ 335..350)
    cv2.ellipse(c_out, (405, 360), (45, 18), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(m_out, (405, 360), (45, 18), 0, 0, 360, [255, 255, 255], -1)
    # Right brow: inpaint original, draw furrowed brow (Y ~ 365..380)
    cv2.ellipse(c_out, (615, 360), (45, 18), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(m_out, (615, 360), (45, 18), 0, 0, 360, [255, 255, 255], -1)
    
    # Left brow: high curious arch
    pts_l = np.array([[365, 355], [405, 335], [445, 345]], dtype=np.int32)
    cv2.polylines(c_out, [pts_l], False, LINE_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_out, [pts_l], False, LINE_BGR, 4, cv2.LINE_AA)
    
    # Right brow: furrowed downward toward nose
    pts_r = np.array([[580, 380], [615, 372], [655, 360]], dtype=np.int32)
    cv2.polylines(c_out, [pts_r], False, LINE_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_out, [pts_r], False, LINE_BGR, 4, cv2.LINE_AA)
    
    # Mouth: inpaint neutral mouth, draw quizzical wavy mouth line
    cv2.ellipse(c_out, (512, 525), (40, 20), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(m_out, (512, 525), (40, 20), 0, 0, 360, [255, 255, 255], -1)
    pts_m = np.array([[488, 526], [504, 522], [520, 528], [536, 523]], dtype=np.int32)
    cv2.polylines(c_out, [pts_m], False, LINE_BGR, 3, cv2.LINE_AA)
    cv2.polylines(m_out, [pts_m], False, LINE_BGR, 3, cv2.LINE_AA)
    
    # Floating '?' mark near head in Pegi's drawing style
    for img in [c_out, m_out]:
        cv2.ellipse(img, (745, 215), (16, 16), 0, 200, 480, LINE_BGR, 4, cv2.LINE_AA)
        cv2.line(img, (745, 231), (745, 245), LINE_BGR, 4, cv2.LINE_AA)
        cv2.circle(img, (745, 258), 3, LINE_BGR, -1)
        
    cv2.imwrite(os.path.join(EXPR_COLOR_DIR, "nemi_expr_confused.png"), c_out)
    cv2.imwrite(os.path.join(EXPR_MONO_DIR, "nemi_expr_confused.png"), m_out)
    print("  [+] Synthesized HQ Confused expression")

def build_shocked(c_base, m_base):
    """
    Shocked Expression:
    - High arched shock brows
    - Wide open eyes with high eyelashes
    - Pinpoint/shrunken pupils floating in sclera (Reference B style)
    - Tall open O-mouth with upper teeth and dark interior
    - Sweat drop & shock action lines
    """
    c_out = c_base.copy()
    m_out = m_base.copy()
    skin_fill = np.median(c_base[450:475, 490:535].reshape(-1, 3), axis=0).astype(np.uint8)
    
    # Inpaint eyes, brows, mouth
    for center, rad in [((410, 410), (55, 45)), ((612, 410), (55, 45)),
                        ((405, 360), (45, 18)), ((615, 360), (45, 18)),
                        ((512, 525), (45, 25))]:
        cv2.ellipse(c_out, center, rad, 0, 0, 360, skin_fill.tolist(), -1)
        cv2.ellipse(m_out, center, rad, 0, 0, 360, [255, 255, 255], -1)
        
    # High raised shock eyebrows
    pts_l = np.array([[365, 335], [405, 318], [445, 328]], dtype=np.int32)
    pts_r = np.array([[575, 328], [615, 318], [655, 335]], dtype=np.int32)
    cv2.polylines(c_out, [pts_l], False, LINE_BGR, 4, cv2.LINE_AA)
    cv2.polylines(c_out, [pts_r], False, LINE_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_out, [pts_l], False, LINE_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_out, [pts_r], False, LINE_BGR, 4, cv2.LINE_AA)
    
    # Eyes: wide open oval sclera
    for img, is_col in [(c_out, True), (m_out, False)]:
        # Sclera
        cv2.ellipse(img, (410, 408), (42, 36), 0, 0, 360, [255, 255, 255], -1)
        cv2.ellipse(img, (612, 408), (42, 36), 0, 0, 360, [255, 255, 255], -1)
        
        # Upper lash wing
        cv2.ellipse(img, (410, 385), (44, 22), 0, 190, 350, LINE_BGR, 5, cv2.LINE_AA)
        cv2.ellipse(img, (612, 385), (44, 22), 0, 190, 350, LINE_BGR, 5, cv2.LINE_AA)
        # Lower lash line
        cv2.ellipse(img, (410, 432), (36, 12), 0, 10, 170, LINE_BGR, 3, cv2.LINE_AA)
        cv2.ellipse(img, (612, 432), (36, 12), 0, 10, 170, LINE_BGR, 3, cv2.LINE_AA)
        
        # Small pinpoint shrunken pupils floating inside sclera (Reference B style)
        if is_col:
            # Green outer ring
            cv2.circle(img, (410, 408), 16, [95, 141, 54], -1, cv2.LINE_AA)
            cv2.circle(img, (410, 408), 8, [32, 44, 19], -1, cv2.LINE_AA)
            cv2.circle(img, (406, 404), 3, [255, 255, 255], -1, cv2.LINE_AA)
            
            cv2.circle(img, (612, 408), 16, [95, 141, 54], -1, cv2.LINE_AA)
            cv2.circle(img, (612, 408), 8, [32, 44, 19], -1, cv2.LINE_AA)
            cv2.circle(img, (608, 404), 3, [255, 255, 255], -1, cv2.LINE_AA)
        else:
            cv2.circle(img, (410, 408), 16, LINE_BGR, 2, cv2.LINE_AA)
            cv2.circle(img, (410, 408), 8, LINE_BGR, -1, cv2.LINE_AA)
            cv2.circle(img, (406, 404), 3, [255, 255, 255], -1, cv2.LINE_AA)
            
            cv2.circle(img, (612, 408), 16, LINE_BGR, 2, cv2.LINE_AA)
            cv2.circle(img, (612, 408), 8, LINE_BGR, -1, cv2.LINE_AA)
            cv2.circle(img, (608, 404), 3, [255, 255, 255], -1, cv2.LINE_AA)
            
    # Tall open shocked O-mouth
    mouth_pts = np.array([
        [492, 510], [532, 510],
        [536, 548], [520, 558], [504, 558], [488, 548]
    ], dtype=np.int32)
    
    # Color mouth
    cv2.fillPoly(c_out, [mouth_pts], [110, 90, 185]) # dark pinkish-burgundy interior
    teeth_pts = np.array([[496, 510], [528, 510], [526, 518], [498, 518]], dtype=np.int32)
    cv2.fillPoly(c_out, [teeth_pts], [255, 255, 255])
    cv2.polylines(c_out, [mouth_pts], True, LINE_BGR, 3, cv2.LINE_AA)
    
    # Mono mouth
    cv2.fillPoly(m_out, [mouth_pts], [215, 210, 215])
    cv2.fillPoly(m_out, [teeth_pts], [255, 255, 255])
    cv2.polylines(m_out, [mouth_pts], True, LINE_BGR, 3, cv2.LINE_AA)
    
    # Sweat drop on cheek
    drop_pts = np.array([[675, 415], [682, 428], [680, 436], [670, 436], [668, 428]], dtype=np.int32)
    cv2.fillPoly(c_out, [drop_pts], [248, 180, 138]) # soft blue
    cv2.polylines(c_out, [drop_pts], True, LINE_BGR, 2, cv2.LINE_AA)
    cv2.fillPoly(m_out, [drop_pts], [255, 255, 255])
    cv2.polylines(m_out, [drop_pts], True, LINE_BGR, 2, cv2.LINE_AA)
    
    # Action lines
    for pts in [[(220, 320), (250, 340)], [(205, 360), (240, 370)], [(780, 340), (810, 320)], [(790, 370), (825, 360)]]:
        cv2.line(c_out, pts[0], pts[1], LINE_BGR, 3, cv2.LINE_AA)
        cv2.line(m_out, pts[0], pts[1], LINE_BGR, 3, cv2.LINE_AA)
        
    cv2.imwrite(os.path.join(EXPR_COLOR_DIR, "nemi_expr_shocked.png"), c_out)
    cv2.imwrite(os.path.join(EXPR_MONO_DIR, "nemi_expr_shocked.png"), m_out)
    print("  [+] Synthesized HQ Shocked expression")

def build_embarrassed(c_base, m_base):
    """
    Embarrassed Expression:
    - Eyebrows angled up in center (sheepish / pleading)
    - Irises shifted down-left (shy averted gaze)
    - Nervous squiggly smile line
    - Heavy warm peach blush across cheeks & nose bridge
    - Dense diagonal blush hatching lines
    - Small nervous sweat bead
    """
    c_out = c_base.copy()
    m_out = m_base.copy()
    skin_fill = np.median(c_base[450:475, 490:535].reshape(-1, 3), axis=0).astype(np.uint8)
    
    # Inpaint original eyebrows and mouth
    cv2.ellipse(c_out, (405, 360), (45, 18), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(c_out, (615, 360), (45, 18), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(c_out, (512, 525), (45, 20), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(m_out, (405, 360), (45, 18), 0, 0, 360, [255, 255, 255], -1)
    cv2.ellipse(m_out, (615, 360), (45, 18), 0, 0, 360, [255, 255, 255], -1)
    cv2.ellipse(m_out, (512, 525), (45, 20), 0, 0, 360, [255, 255, 255], -1)
    
    # Sheepish eyebrows angled up in center
    pts_l = np.array([[365, 362], [405, 350], [445, 340]], dtype=np.int32)
    pts_r = np.array([[575, 340], [615, 350], [655, 362]], dtype=np.int32)
    cv2.polylines(c_out, [pts_l], False, LINE_BGR, 4, cv2.LINE_AA)
    cv2.polylines(c_out, [pts_r], False, LINE_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_out, [pts_l], False, LINE_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_out, [pts_r], False, LINE_BGR, 4, cv2.LINE_AA)
    
    # Shy averted eyes: inpaint pupil centers, shift irises down-left
    # Left eye iris center moves to (398, 416)
    # Right eye iris center moves to (600, 416)
    # Re-draw the eyes with averted irises
    for img, is_col in [(c_out, True), (m_out, False)]:
        # Sclera
        cv2.ellipse(img, (410, 410), (38, 28), 0, 0, 360, [255, 255, 255], -1)
        cv2.ellipse(img, (612, 410), (38, 28), 0, 0, 360, [255, 255, 255], -1)
        
        # Soft downward eyelids
        cv2.ellipse(img, (410, 396), (40, 18), 0, 190, 350, LINE_BGR, 4, cv2.LINE_AA)
        cv2.ellipse(img, (612, 396), (40, 18), 0, 190, 350, LINE_BGR, 4, cv2.LINE_AA)
        # Lower lash
        cv2.ellipse(img, (410, 428), (34, 10), 0, 10, 170, LINE_BGR, 2, cv2.LINE_AA)
        cv2.ellipse(img, (612, 428), (34, 10), 0, 10, 170, LINE_BGR, 2, cv2.LINE_AA)
        
        if is_col:
            cv2.circle(img, (400, 414), 18, [95, 141, 54], -1, cv2.LINE_AA)
            cv2.circle(img, (400, 414), 9, [32, 44, 19], -1, cv2.LINE_AA)
            cv2.circle(img, (395, 410), 4, [255, 255, 255], -1, cv2.LINE_AA)
            
            cv2.circle(img, (602, 414), 18, [95, 141, 54], -1, cv2.LINE_AA)
            cv2.circle(img, (602, 414), 9, [32, 44, 19], -1, cv2.LINE_AA)
            cv2.circle(img, (597, 410), 4, [255, 255, 255], -1, cv2.LINE_AA)
        else:
            cv2.circle(img, (400, 414), 18, LINE_BGR, 2, cv2.LINE_AA)
            cv2.circle(img, (400, 414), 9, LINE_BGR, -1, cv2.LINE_AA)
            cv2.circle(img, (395, 410), 4, [255, 255, 255], -1, cv2.LINE_AA)
            
            cv2.circle(img, (602, 414), 18, LINE_BGR, 2, cv2.LINE_AA)
            cv2.circle(img, (602, 414), 9, LINE_BGR, -1, cv2.LINE_AA)
            cv2.circle(img, (597, 410), 4, [255, 255, 255], -1, cv2.LINE_AA)
            
    # Nervous wavy mouth line
    pts_m = np.array([[486, 528], [498, 524], [512, 529], [526, 524], [538, 527]], dtype=np.int32)
    cv2.polylines(c_out, [pts_m], False, LINE_BGR, 3, cv2.LINE_AA)
    cv2.polylines(m_out, [pts_m], False, LINE_BGR, 3, cv2.LINE_AA)
    
    # Warm peach blush across cheeks & nose
    overlay = c_out.copy()
    cv2.ellipse(overlay, (410, 448), (45, 22), -5, 0, 360, [130, 140, 245], -1)
    cv2.ellipse(overlay, (612, 448), (45, 22), 5, 0, 360, [130, 140, 245], -1)
    cv2.ellipse(overlay, (512, 465), (35, 14), 0, 0, 360, [140, 150, 245], -1)
    c_out = cv2.addWeighted(overlay, 0.55, c_out, 0.45, 0)
    
    # Dense blush hatching lines on both
    for img in [c_out, m_out]:
        for x in range(375, 445, 7):
            cv2.line(img, (x, 465), (x + 10, 438), LINE_BGR, 2, cv2.LINE_AA)
        for x in range(575, 645, 7):
            cv2.line(img, (x, 465), (x + 10, 438), LINE_BGR, 2, cv2.LINE_AA)
        for x in range(495, 530, 7):
            cv2.line(img, (x, 473), (x + 8, 455), LINE_BGR, 2, cv2.LINE_AA)
            
    # Small nervous sweat bead (370, 330)
    drop_pts = np.array([[370, 320], [376, 330], [374, 336], [366, 336], [364, 330]], dtype=np.int32)
    cv2.fillPoly(c_out, [drop_pts], [248, 180, 138])
    cv2.polylines(c_out, [drop_pts], True, LINE_BGR, 2, cv2.LINE_AA)
    cv2.fillPoly(m_out, [drop_pts], [255, 255, 255])
    cv2.polylines(m_out, [drop_pts], True, LINE_BGR, 2, cv2.LINE_AA)
    
    cv2.imwrite(os.path.join(EXPR_COLOR_DIR, "nemi_expr_embarrassed.png"), c_out)
    cv2.imwrite(os.path.join(EXPR_MONO_DIR, "nemi_expr_embarrassed.png"), m_out)
    print("  [+] Synthesized HQ Embarrassed expression")

def main():
    c_base, m_base = load_neutrals()
    print("--- Building High-Quality Expressions ---")
    build_confused(c_base, m_base)
    build_shocked(c_base, m_base)
    build_embarrassed(c_base, m_base)
    print("Expressions updated successfully!")

if __name__ == "__main__":
    main()

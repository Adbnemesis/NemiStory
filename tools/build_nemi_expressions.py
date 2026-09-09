#!/usr/bin/env python3
"""
Generate the remaining original Nemi expressions:
- Confused (Color & Monochrome)
- Shocked (Color & Monochrome)
- Embarrassed (Color & Monochrome)
following Reference B's hand-drawn YouTube illustration style and Nemi's core design.
"""

import os
import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ART_DIR = os.path.join(BASE_DIR, "characters/nemi/art")

EXPR_COLOR_DIR = os.path.join(ART_DIR, "expressions/color")
EXPR_MONO_DIR = os.path.join(ART_DIR, "expressions/monochrome")

LINE_COLOR_BGR = [30, 8, 62]     # #3e081e in BGR
LINE_COLOR_RGB = (62, 8, 30)     # #3e081e
SKIN_COLOR_BGR = [194, 220, 250] # #fadcc2 in BGR
SKIN_COLOR_RGB = (250, 220, 194)
BLUSH_COLOR_BGR = [144, 166, 245]# #f5a690 in BGR
BLUSH_COLOR_RGB = (245, 166, 144)
IRIS_GREEN_BGR = [95, 141, 54]   # #368d5f in BGR
IRIS_GREEN_RGB = (54, 141, 95)
PUPIL_DARK_BGR = [32, 44, 19]    # #132c20 in BGR
PUPIL_DARK_RGB = (19, 44, 32)
MOUTH_INNER_BGR = [120, 100, 190]
SWEAT_BLUE_BGR = [248, 180, 138] # soft blue #8ab4f8 in BGR

def get_clean_face_base():
    """Extract clean face skin under eyes and mouth from neutral portrait."""
    c_img = cv2.imread(os.path.join(EXPR_COLOR_DIR, "nemi_expr_neutral.png"))
    m_img = cv2.imread(os.path.join(EXPR_MONO_DIR, "nemi_expr_neutral.png"))
    
    # Clean eye sockets and mouth on color:
    # Left eye: (410, 410), radius (48, 42)
    # Right eye: (612, 410), radius (48, 42)
    # Mouth: (512, 520), radius (45, 25)
    # Brows: (405, 360) and (615, 360)
    c_base = c_img.copy()
    m_base = m_img.copy()
    
    # Inpaint eye & mouth regions on color base with skin tone
    skin_fill = np.median(c_img[450:475, 490:535].reshape(-1, 3), axis=0).astype(np.uint8)
    cv2.ellipse(c_base, (410, 405), (52, 45), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(c_base, (612, 405), (52, 45), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(c_base, (405, 360), (45, 18), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(c_base, (615, 360), (45, 18), 0, 0, 360, skin_fill.tolist(), -1)
    cv2.ellipse(c_base, (512, 525), (42, 22), 0, 0, 360, skin_fill.tolist(), -1)
    
    # Inpaint on mono base with pure white
    cv2.ellipse(m_base, (410, 405), (52, 45), 0, 0, 360, [255, 255, 255], -1)
    cv2.ellipse(m_base, (612, 405), (52, 45), 0, 0, 360, [255, 255, 255], -1)
    cv2.ellipse(m_base, (405, 360), (45, 18), 0, 0, 360, [255, 255, 255], -1)
    cv2.ellipse(m_base, (615, 360), (45, 18), 0, 0, 360, [255, 255, 255], -1)
    cv2.ellipse(m_base, (512, 525), (42, 22), 0, 0, 360, [255, 255, 255], -1)
    
    return c_base, m_base

def draw_confused():
    """Create Confused expression: asymmetric quizzical brows, puzzled eyes, wavy mouth, floating ?."""
    c_img, m_img = get_clean_face_base()
    
    # Left eye: wide and curious (410, 405)
    # Sclera
    cv2.ellipse(c_img, (410, 405), (38, 30), 0, 0, 360, [255, 255, 255], -1)
    # Iris
    cv2.circle(c_img, (412, 405), 22, IRIS_GREEN_BGR, -1)
    cv2.circle(c_img, (412, 405), 11, PUPIL_DARK_BGR, -1)
    cv2.circle(c_img, (405, 398), 6, [255, 255, 255], -1) # shine
    # Upper eyelash
    cv2.ellipse(c_img, (410, 392), (40, 18), 0, 190, 350, LINE_COLOR_BGR, 4)
    
    # Right eye: slightly narrowed/puzzled (612, 405)
    cv2.ellipse(c_img, (612, 408), (36, 22), 0, 0, 360, [255, 255, 255], -1)
    cv2.circle(c_img, (610, 408), 18, IRIS_GREEN_BGR, -1)
    cv2.circle(c_img, (610, 408), 9, PUPIL_DARK_BGR, -1)
    cv2.circle(c_img, (605, 403), 5, [255, 255, 255], -1)
    cv2.ellipse(c_img, (612, 396), (38, 14), 0, 190, 350, LINE_COLOR_BGR, 4)
    
    # Asymmetric eyebrows:
    # Left brow: arched high up (370..445, Y: 335..355)
    pts_brow_l = np.array([[370, 355], [405, 335], [445, 348]], dtype=np.int32)
    cv2.polylines(c_img, [pts_brow_l], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    # Right brow: furrowed down toward center (580..655, Y: 375..360)
    pts_brow_r = np.array([[580, 375], [615, 368], [655, 362]], dtype=np.int32)
    cv2.polylines(c_img, [pts_brow_r], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    
    # Quizzical wavy mouth at (512, 525)
    pts_mouth = np.array([[485, 528], [502, 522], [520, 527], [538, 523]], dtype=np.int32)
    cv2.polylines(c_img, [pts_mouth], False, LINE_COLOR_BGR, 3, cv2.LINE_AA)
    
    # Floating hand-drawn question mark '?' near top right (X: 740, Y: 220)
    cv2.ellipse(c_img, (745, 215), (18, 18), 0, 200, 480, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.line(c_img, (745, 233), (745, 248), LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.circle(c_img, (745, 262), 3, LINE_COLOR_BGR, -1)
    
    # MONOCHROME VERSION:
    # Mirror linework to monochrome base
    # Left eye sclera & iris outline
    cv2.ellipse(m_img, (410, 405), (38, 30), 0, 0, 360, [255, 255, 255], -1)
    cv2.circle(m_img, (412, 405), 22, [255, 255, 255], -1)
    cv2.circle(m_img, (412, 405), 22, LINE_COLOR_BGR, 2)
    cv2.circle(m_img, (412, 405), 11, LINE_COLOR_BGR, -1)
    cv2.circle(m_img, (405, 398), 6, [255, 255, 255], -1)
    cv2.ellipse(m_img, (410, 392), (40, 18), 0, 190, 350, LINE_COLOR_BGR, 4)
    
    # Right eye
    cv2.ellipse(m_img, (612, 408), (36, 22), 0, 0, 360, [255, 255, 255], -1)
    cv2.circle(m_img, (610, 408), 18, LINE_COLOR_BGR, 2)
    cv2.circle(m_img, (610, 408), 9, LINE_COLOR_BGR, -1)
    cv2.circle(m_img, (605, 403), 5, [255, 255, 255], -1)
    cv2.ellipse(m_img, (612, 396), (38, 14), 0, 190, 350, LINE_COLOR_BGR, 4)
    
    # Brows & mouth
    cv2.polylines(m_img, [pts_brow_l], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_img, [pts_brow_r], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_img, [pts_mouth], False, LINE_COLOR_BGR, 3, cv2.LINE_AA)
    
    # Question mark
    cv2.ellipse(m_img, (745, 215), (18, 18), 0, 200, 480, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.line(m_img, (745, 233), (745, 248), LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.circle(m_img, (745, 262), 3, LINE_COLOR_BGR, -1)
    
    cv2.imwrite(os.path.join(EXPR_COLOR_DIR, "nemi_expr_confused.png"), c_img)
    cv2.imwrite(os.path.join(EXPR_MONO_DIR, "nemi_expr_confused.png"), m_img)
    print("  [+] Generated Confused expression (Color & Mono)")

def draw_shocked():
    """Create Shocked expression: wide staring eyes, pinpoint pupils, tall open O-mouth, shock lines."""
    c_img, m_img = get_clean_face_base()
    
    # High raised shock eyebrows
    pts_brow_l = np.array([[365, 335], [405, 320], [445, 330]], dtype=np.int32)
    pts_brow_r = np.array([[575, 330], [615, 320], [655, 335]], dtype=np.int32)
    cv2.polylines(c_img, [pts_brow_l], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.polylines(c_img, [pts_brow_r], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_img, [pts_brow_l], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_img, [pts_brow_r], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    
    # Wide round open eyes: Left (410, 405), Right (612, 405)
    for img, is_col in [(c_img, True), (m_img, False)]:
        # Sclera (pure white round oval)
        cv2.ellipse(img, (410, 405), (40, 36), 0, 0, 360, [255, 255, 255], -1)
        cv2.ellipse(img, (612, 405), (40, 36), 0, 0, 360, [255, 255, 255], -1)
        
        # High upper lash lines
        cv2.ellipse(img, (410, 382), (42, 22), 0, 190, 350, LINE_COLOR_BGR, 5)
        cv2.ellipse(img, (612, 382), (42, 22), 0, 190, 350, LINE_COLOR_BGR, 5)
        # Lower lash lines
        cv2.ellipse(img, (410, 428), (36, 14), 0, 10, 170, LINE_COLOR_BGR, 3)
        cv2.ellipse(img, (612, 428), (36, 14), 0, 10, 170, LINE_COLOR_BGR, 3)
        
        # Small pinpoint shrunken pupils (shocked look)
        if is_col:
            cv2.circle(img, (410, 405), 14, IRIS_GREEN_BGR, -1)
            cv2.circle(img, (410, 405), 7, PUPIL_DARK_BGR, -1)
            cv2.circle(img, (406, 401), 3, [255, 255, 255], -1)
            
            cv2.circle(img, (612, 405), 14, IRIS_GREEN_BGR, -1)
            cv2.circle(img, (612, 405), 7, PUPIL_DARK_BGR, -1)
            cv2.circle(img, (608, 401), 3, [255, 255, 255], -1)
        else:
            cv2.circle(img, (410, 405), 14, LINE_COLOR_BGR, 2)
            cv2.circle(img, (410, 405), 7, LINE_COLOR_BGR, -1)
            cv2.circle(img, (406, 401), 3, [255, 255, 255], -1)
            
            cv2.circle(img, (612, 405), 14, LINE_COLOR_BGR, 2)
            cv2.circle(img, (612, 405), 7, LINE_COLOR_BGR, -1)
            cv2.circle(img, (608, 401), 3, [255, 255, 255], -1)
            
    # Tall open shocked O-mouth: at (512, 530)
    for img, is_col in [(c_img, True), (m_img, False)]:
        mouth_pts = np.array([
            [492, 508], [532, 508],
            [536, 545], [522, 555], [502, 555], [488, 545]
        ], dtype=np.int32)
        if is_col:
            cv2.fillPoly(img, [mouth_pts], MOUTH_INNER_BGR)
            # Upper teeth
            teeth_pts = np.array([[496, 508], [528, 508], [526, 516], [498, 516]], dtype=np.int32)
            cv2.fillPoly(img, [teeth_pts], [255, 255, 255])
        else:
            cv2.fillPoly(img, [mouth_pts], [215, 210, 215])
            teeth_pts = np.array([[496, 508], [528, 508], [526, 516], [498, 516]], dtype=np.int32)
            cv2.fillPoly(img, [teeth_pts], [255, 255, 255])
        cv2.polylines(img, [mouth_pts], True, LINE_COLOR_BGR, 3, cv2.LINE_AA)
        
    # Sweat drop on cheek: at (675, 430)
    drop_pts = np.array([[675, 415], [682, 428], [680, 436], [670, 436], [668, 428]], dtype=np.int32)
    cv2.fillPoly(c_img, [drop_pts], SWEAT_BLUE_BGR)
    cv2.polylines(c_img, [drop_pts], True, LINE_COLOR_BGR, 2, cv2.LINE_AA)
    cv2.fillPoly(m_img, [drop_pts], [255, 255, 255])
    cv2.polylines(m_img, [drop_pts], True, LINE_COLOR_BGR, 2, cv2.LINE_AA)
    
    # Hand-drawn shock action lines around head
    shock_lines = [
        [(220, 320), (250, 340)],
        [(205, 360), (240, 370)],
        [(780, 340), (810, 320)],
        [(790, 370), (825, 360)]
    ]
    for pts in shock_lines:
        cv2.line(c_img, pts[0], pts[1], LINE_COLOR_BGR, 3, cv2.LINE_AA)
        cv2.line(m_img, pts[0], pts[1], LINE_COLOR_BGR, 3, cv2.LINE_AA)
        
    cv2.imwrite(os.path.join(EXPR_COLOR_DIR, "nemi_expr_shocked.png"), c_img)
    cv2.imwrite(os.path.join(EXPR_MONO_DIR, "nemi_expr_shocked.png"), m_img)
    print("  [+] Generated Shocked expression (Color & Mono)")

def draw_embarrassed():
    """Create Embarrassed expression: shy downward eyes, sheepish brows, nervous wavy mouth, heavy blush."""
    c_img, m_img = get_clean_face_base()
    
    # Worried/sheepish brows angled up at center
    pts_brow_l = np.array([[365, 365], [405, 350], [445, 342]], dtype=np.int32)
    pts_brow_r = np.array([[575, 342], [615, 350], [655, 365]], dtype=np.int32)
    cv2.polylines(c_img, [pts_brow_l], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.polylines(c_img, [pts_brow_r], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_img, [pts_brow_l], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    cv2.polylines(m_img, [pts_brow_r], False, LINE_COLOR_BGR, 4, cv2.LINE_AA)
    
    # Shy eyes looking downward/away to the left
    for img, is_col in [(c_img, True), (m_img, False)]:
        # Sclera
        cv2.ellipse(img, (410, 410), (36, 26), 0, 0, 360, [255, 255, 255], -1)
        cv2.ellipse(img, (612, 410), (36, 26), 0, 0, 360, [255, 255, 255], -1)
        
        # Soft downward eyelids
        cv2.ellipse(img, (410, 396), (38, 16), 0, 190, 350, LINE_COLOR_BGR, 4)
        cv2.ellipse(img, (612, 396), (38, 16), 0, 190, 350, LINE_COLOR_BGR, 4)
        
        # Averted irises (shifted down-left)
        if is_col:
            cv2.circle(img, (400, 415), 18, IRIS_GREEN_BGR, -1)
            cv2.circle(img, (400, 415), 9, PUPIL_DARK_BGR, -1)
            cv2.circle(img, (395, 410), 4, [255, 255, 255], -1)
            
            cv2.circle(img, (602, 415), 18, IRIS_GREEN_BGR, -1)
            cv2.circle(img, (602, 415), 9, PUPIL_DARK_BGR, -1)
            cv2.circle(img, (597, 410), 4, [255, 255, 255], -1)
        else:
            cv2.circle(img, (400, 415), 18, LINE_COLOR_BGR, 2)
            cv2.circle(img, (400, 415), 9, LINE_COLOR_BGR, -1)
            cv2.circle(img, (395, 410), 4, [255, 255, 255], -1)
            
            cv2.circle(img, (602, 415), 18, LINE_COLOR_BGR, 2)
            cv2.circle(img, (602, 415), 9, LINE_COLOR_BGR, -1)
            cv2.circle(img, (597, 410), 4, [255, 255, 255], -1)
            
    # Nervous wavy mouth at (512, 525)
    pts_mouth = np.array([[488, 528], [500, 524], [512, 529], [524, 524], [536, 527]], dtype=np.int32)
    cv2.polylines(c_img, [pts_mouth], False, LINE_COLOR_BGR, 3, cv2.LINE_AA)
    cv2.polylines(m_img, [pts_mouth], False, LINE_COLOR_BGR, 3, cv2.LINE_AA)
    
    # Heavy warm blush across cheeks and nose bridge
    overlay = c_img.copy()
    cv2.ellipse(overlay, (410, 445), (45, 22), -5, 0, 360, [130, 140, 245], -1)
    cv2.ellipse(overlay, (612, 445), (45, 22), 5, 0, 360, [130, 140, 245], -1)
    cv2.ellipse(overlay, (512, 460), (35, 14), 0, 0, 360, [140, 150, 245], -1) # bridge of nose blush
    c_img = cv2.addWeighted(overlay, 0.55, c_img, 0.45, 0)
    
    # Dense blush hatching lines on both color and monochrome
    for img in [c_img, m_img]:
        for x in range(375, 445, 7):
            cv2.line(img, (x, 462), (x + 10, 435), LINE_COLOR_BGR, 2, cv2.LINE_AA)
        for x in range(575, 645, 7):
            cv2.line(img, (x, 462), (x + 10, 435), LINE_COLOR_BGR, 2, cv2.LINE_AA)
        # Nose bridge hatching
        for x in range(495, 530, 7):
            cv2.line(img, (x, 470), (x + 8, 452), LINE_COLOR_BGR, 2, cv2.LINE_AA)
            
    # Small nervous sweat bead near hairline (370, 330)
    drop_pts = np.array([[370, 320], [376, 330], [374, 336], [366, 336], [364, 330]], dtype=np.int32)
    cv2.fillPoly(c_img, [drop_pts], SWEAT_BLUE_BGR)
    cv2.polylines(c_img, [drop_pts], True, LINE_COLOR_BGR, 2, cv2.LINE_AA)
    cv2.fillPoly(m_img, [drop_pts], [255, 255, 255])
    cv2.polylines(m_img, [drop_pts], True, LINE_COLOR_BGR, 2, cv2.LINE_AA)
    
    cv2.imwrite(os.path.join(EXPR_COLOR_DIR, "nemi_expr_embarrassed.png"), c_img)
    cv2.imwrite(os.path.join(EXPR_MONO_DIR, "nemi_expr_embarrassed.png"), m_img)
    print("  [+] Generated Embarrassed expression (Color & Mono)")

def main():
    print("--- Generating Full Hand-Drawn Expression Library ---")
    draw_confused()
    draw_shocked()
    draw_embarrassed()
    print("All 5 expressions in both Color and Monochrome ready!")

if __name__ == "__main__":
    main()

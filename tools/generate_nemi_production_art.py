import os
import subprocess
import xml.etree.ElementTree as ET

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ART_DIR = os.path.join(BASE_DIR, "characters/nemi/art")

MASTER_DIR = os.path.join(ART_DIR, "master")
HAIR_DIR = os.path.join(ART_DIR, "hair")
FACE_DIR = os.path.join(ART_DIR, "face")
BODY_DIR = os.path.join(ART_DIR, "body")
CLOTHES_DIR = os.path.join(ART_DIR, "clothes")
ACCESSORIES_DIR = os.path.join(ART_DIR, "accessories")

for d in [MASTER_DIR, HAIR_DIR, FACE_DIR, BODY_DIR, CLOTHES_DIR, ACCESSORIES_DIR]:
    os.makedirs(d, exist_ok=True)

W, H = 1000, 1600

# Canonical Nemi Color Palette
PALETTE = {
    "line": "#3e081e",
    "line_soft": "#5a1830",
    "skin_base": "#fadcc2",
    "skin_shadow": "#f1be9d",
    "skin_blush": "#f5a690",
    "skin_highlight": "#fff5eb",
    "hair_base": "#c54d42",
    "hair_shadow": "#9e362e",
    "hair_deep_shadow": "#6d1e18",
    "hair_highlight": "#e4695c",
    "eye_sclera": "#ffffff",
    "eye_iris_outer": "#245e43",
    "eye_iris_inner": "#368d5f",
    "eye_iris_bright": "#58ad7d",
    "eye_pupil": "#132c20",
    "hoodie_base": "#678d5f",
    "hoodie_shadow": "#4c6d45",
    "hoodie_highlight": "#7da575",
    "skirt_base": "#354d44",
    "skirt_shadow": "#24362f",
    "skirt_highlight": "#456358",
    "sock_white": "#ffffff",
    "sock_shadow": "#e2ded6",
    "shoe_white": "#f6f5f0",
    "shoe_shadow": "#dedbd3",
    "shoe_green": "#678d5f",
    "shoe_sole": "#2d433b",
    "bag_dark": "#2f3330",
    "bag_leaf": "#d8b368",
    "drawstring": "#f2eee6"
}

def create_svg_wrapper(inner_content, width=W, height=H):
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">
  <defs>
    <!-- Soft blush filter -->
    <filter id="blush_blur" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="8" />
    </filter>
    <!-- Eye gradient -->
    <linearGradient id="eye_gradient" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{PALETTE['eye_iris_outer']}"/>
      <stop offset="60%" stop-color="{PALETTE['eye_iris_inner']}"/>
      <stop offset="100%" stop-color="{PALETTE['eye_iris_bright']}"/>
    </linearGradient>
    <!-- Hair shine gradient -->
    <linearGradient id="hair_shine" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{PALETTE['hair_base']}"/>
      <stop offset="50%" stop-color="{PALETTE['hair_highlight']}"/>
      <stop offset="100%" stop-color="{PALETTE['hair_base']}"/>
    </linearGradient>
  </defs>
  {inner_content}
</svg>'''

# -----------------------------------------------------------------------------
# INDIVIDUAL LAYER SVG DEFINITIONS (WITH HIDDEN / OCCLUDED GEOMETRY)
# -----------------------------------------------------------------------------

def get_layer_hair_back():
    # Flowing hair behind neck, shoulders, and torso (Y=200 down to Y=870)
    # Complete broad volume so character movement never reveals empty gaps
    return f'''
    <g id="nemi_hair_back">
      <!-- Deep Shadow Underlayer -->
      <path d="M 500,210
               C 380,210 300,280 280,420
               C 260,540 270,680 300,810
               C 320,870 350,910 380,880
               C 410,850 430,770 450,710
               C 470,750 490,830 500,860
               C 510,830 530,750 550,710
               C 570,770 590,850 620,880
               C 650,910 680,870 700,810
               C 730,680 740,540 720,420
               C 700,280 620,210 500,210 Z"
            fill="{PALETTE['hair_deep_shadow']}" />

      <!-- Main Back Hair Volume -->
      <path d="M 500,215
               C 390,215 315,290 295,430
               C 275,550 285,670 310,790
               C 330,850 365,880 395,840
               C 420,800 440,730 460,680
               C 475,720 490,790 500,830
               C 510,790 525,720 540,680
               C 560,730 580,800 605,840
               C 635,880 670,850 690,790
               C 715,670 725,550 705,430
               C 685,290 610,215 500,215 Z"
            fill="{PALETTE['hair_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.6" stroke-linejoin="round" />

      <!-- Back Hair Shadow Creases & Strands -->
      <path d="M 340,460 C 330,580 345,710 375,820" fill="none" stroke="{PALETTE['hair_shadow']}" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M 660,460 C 670,580 655,710 625,820" fill="none" stroke="{PALETTE['hair_shadow']}" stroke-width="2.5" stroke-linecap="round"/>
      <path d="M 370,360 C 350,480 360,600 390,720" fill="none" stroke="{PALETTE['hair_shadow']}" stroke-width="2.2" stroke-linecap="round"/>
      <path d="M 630,360 C 650,480 640,600 610,720" fill="none" stroke="{PALETTE['hair_shadow']}" stroke-width="2.2" stroke-linecap="round"/>
    </g>'''

def get_layer_neck():
    # Neck column with occluded geometry extending up under chin and 40px down into hoodie collar
    return f'''
    <g id="nemi_neck">
      <!-- Neck Base extending into hoodie (Y=460 to Y=565) -->
      <path d="M 470,470 L 465,565 L 535,565 L 530,470 Z"
            fill="{PALETTE['skin_base']}" />
      <!-- Soft neck shadow under chin -->
      <path d="M 470,470 Q 500,505 530,470 L 532,515 Q 500,535 468,515 Z"
            fill="{PALETTE['skin_shadow']}" />
      <!-- Neck contour lines -->
      <path d="M 470,470 L 465,565" stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linecap="round"/>
      <path d="M 530,470 L 535,565" stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linecap="round"/>
      <!-- Subtle collarbone accent -->
      <path d="M 488,550 Q 500,555 512,550" fill="none" stroke="{PALETTE['skin_shadow']}" stroke-width="2" stroke-linecap="round"/>
    </g>'''

def get_layer_face_base():
    # Full head base: complete skull dome above forehead (occluded by bangs),
    # cheeks, ears, jawline, delicate chin, nose, and peach blush
    return f'''
    <g id="nemi_face_base">
      <!-- Complete Skull / Jaw Silhouette -->
      <path d="M 500,240
               C 420,240 395,310 395,385
               C 395,430 420,465 450,485
               C 475,502 495,505 500,505
               C 505,505 525,502 550,485
               C 580,465 605,430 605,385
               C 605,310 580,240 500,240 Z"
            fill="{PALETTE['skin_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.4" stroke-linejoin="round" />

      <!-- Left Ear (Screen Left) -->
      <path d="M 400,380 C 385,385 385,415 400,420 Z"
            fill="{PALETTE['skin_base']}" stroke="{PALETTE['line']}" stroke-width="2.0" />
      <path d="M 396,392 C 392,398 393,408 398,412" fill="none" stroke="{PALETTE['skin_shadow']}" stroke-width="1.6"/>

      <!-- Right Ear (Screen Right) -->
      <path d="M 600,380 C 615,385 615,415 600,420 Z"
            fill="{PALETTE['skin_base']}" stroke="{PALETTE['line']}" stroke-width="2.0" />
      <path d="M 604,392 C 608,398 607,408 602,412" fill="none" stroke="{PALETTE['skin_shadow']}" stroke-width="1.6"/>

      <!-- Peach Cheek Blush -->
      <ellipse cx="445" cy="425" rx="22" ry="12" fill="{PALETTE['skin_blush']}" opacity="0.65" filter="url(#blush_blur)"/>
      <ellipse cx="555" cy="425" rx="22" ry="12" fill="{PALETTE['skin_blush']}" opacity="0.65" filter="url(#blush_blur)"/>

      <!-- Delicate Anime Nose -->
      <path d="M 498,432 L 500,436 L 502,434" fill="none" stroke="{PALETTE['line_soft']}" stroke-width="2.0" stroke-linecap="round"/>
      <ellipse cx="500" cy="437" rx="1.5" ry="1.2" fill="{PALETTE['skin_shadow']}"/>
    </g>'''

def get_layer_eye_left():
    # Screen-left eye (Character's right): Sclera, Iris gradient, Pupil, Shine highlights, Lashes
    return f'''
    <g id="nemi_eye_left">
      <!-- Sclera / White Base -->
      <path d="M 436,396 Q 458,375 480,396 Q 458,414 436,396 Z"
            fill="{PALETTE['eye_sclera']}" />

      <!-- Iris Clip Area -->
      <g>
        <ellipse cx="458" cy="396" rx="15" ry="17" fill="url(#eye_gradient)"/>
        <!-- Inner Pupil -->
        <ellipse cx="458" cy="397" rx="7" ry="9" fill="{PALETTE['eye_pupil']}"/>
        <!-- Bottom Iris Glow Curve -->
        <path d="M 448,404 Q 458,413 468,404" fill="none" stroke="{PALETTE['eye_iris_bright']}" stroke-width="2.2" stroke-linecap="round"/>
        <!-- Primary White Catchlight -->
        <circle cx="453" cy="389" r="4.2" fill="#ffffff"/>
        <!-- Secondary Highlight Dot -->
        <circle cx="465" cy="403" r="2.2" fill="#ffffff" opacity="0.85"/>
      </g>

      <!-- Upper Eyelash Line (Thick Anime Line) -->
      <path d="M 433,398 C 445,380 472,380 484,396" fill="none" stroke="{PALETTE['line']}" stroke-width="4.2" stroke-linecap="round"/>
      <!-- Delicate Eyelash Flick -->
      <path d="M 482,393 L 488,389" stroke="{PALETTE['line']}" stroke-width="2.5" stroke-linecap="round"/>
      <!-- Lower Eye Contour -->
      <path d="M 445,413 Q 458,416 471,413" fill="none" stroke="{PALETTE['line_soft']}" stroke-width="2.0" stroke-linecap="round"/>
      <!-- Upper Eyelid Crease -->
      <path d="M 442,376 Q 458,371 474,376" fill="none" stroke="{PALETTE['skin_shadow']}" stroke-width="1.8" stroke-linecap="round"/>
    </g>'''

def get_layer_eye_right():
    # Screen-right eye (Character's left)
    return f'''
    <g id="nemi_eye_right">
      <!-- Sclera / White Base -->
      <path d="M 520,396 Q 542,375 564,396 Q 542,414 520,396 Z"
            fill="{PALETTE['eye_sclera']}" />

      <!-- Iris Area -->
      <g>
        <ellipse cx="542" cy="396" rx="15" ry="17" fill="url(#eye_gradient)"/>
        <!-- Inner Pupil -->
        <ellipse cx="542" cy="397" rx="7" ry="9" fill="{PALETTE['eye_pupil']}"/>
        <!-- Bottom Iris Glow Curve -->
        <path d="M 532,404 Q 542,413 552,404" fill="none" stroke="{PALETTE['eye_iris_bright']}" stroke-width="2.2" stroke-linecap="round"/>
        <!-- Primary White Catchlight -->
        <circle cx="537" cy="389" r="4.2" fill="#ffffff"/>
        <!-- Secondary Highlight Dot -->
        <circle cx="549" cy="403" r="2.2" fill="#ffffff" opacity="0.85"/>
      </g>

      <!-- Upper Eyelash Line -->
      <path d="M 516,396 C 528,380 555,380 567,398" fill="none" stroke="{PALETTE['line']}" stroke-width="4.2" stroke-linecap="round"/>
      <!-- Delicate Eyelash Flick -->
      <path d="M 565,393 L 571,389" stroke="{PALETTE['line']}" stroke-width="2.5" stroke-linecap="round"/>
      <!-- Lower Eye Contour -->
      <path d="M 529,413 Q 542,416 555,413" fill="none" stroke="{PALETTE['line_soft']}" stroke-width="2.0" stroke-linecap="round"/>
      <!-- Upper Eyelid Crease -->
      <path d="M 526,376 Q 542,371 558,376" fill="none" stroke="{PALETTE['skin_shadow']}" stroke-width="1.8" stroke-linecap="round"/>
    </g>'''

def get_layer_eyebrows():
    return f'''
    <g id="nemi_eyebrows">
      <!-- Left Brow -->
      <path d="M 436,358 Q 456,346 478,356" fill="none" stroke="{PALETTE['hair_shadow']}" stroke-width="3.0" stroke-linecap="round"/>
      <!-- Right Brow -->
      <path d="M 522,356 Q 544,346 564,358" fill="none" stroke="{PALETTE['hair_shadow']}" stroke-width="3.0" stroke-linecap="round"/>
    </g>'''

def get_layer_mouth():
    return f'''
    <g id="nemi_mouth_neutral">
      <!-- Soft Smiling Closed Lip Line -->
      <path d="M 488,462 Q 500,469 512,462" fill="none" stroke="{PALETTE['line']}" stroke-width="2.4" stroke-linecap="round"/>
      <!-- Subtle lower lip shadow accent -->
      <path d="M 496,473 Q 500,475 504,473" fill="none" stroke="{PALETTE['skin_shadow']}" stroke-width="2.0" stroke-linecap="round"/>
    </g>'''

def get_layer_hair_bangs():
    # Forehead bangs with clumping anime points + signature crown ahoge flick
    return f'''
    <g id="nemi_hair_bangs">
      <!-- Iconic Crown Ahoge (Springing from crown Y=225 up to Y=165) -->
      <path d="M 495,225
               C 490,195 505,165 528,165
               C 538,165 540,175 532,185
               C 520,200 508,215 505,230 Z"
            fill="{PALETTE['hair_base']}" stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>

      <!-- Main Bangs Fringe Across Forehead -->
      <path d="M 395,320
               C 400,240 460,220 500,220
               C 540,220 600,240 605,320
               C 595,350 580,380 575,395
               C 570,375 565,350 555,365
               C 545,385 535,410 530,420
               C 525,395 520,365 510,365
               C 500,365 495,390 490,415
               C 485,395 475,370 465,370
               C 455,370 445,395 440,410
               C 435,390 425,360 415,365
               C 405,370 398,390 395,320 Z"
            fill="{PALETTE['hair_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.5" stroke-linejoin="round" />

      <!-- Bangs Shadow Accents underneath -->
      <path d="M 440,410 L 444,395 L 448,405" fill="{PALETTE['hair_shadow']}"/>
      <path d="M 490,415 L 493,398 L 497,410" fill="{PALETTE['hair_shadow']}"/>
      <path d="M 530,420 L 533,400 L 537,412" fill="{PALETTE['hair_shadow']}"/>

      <!-- Crown Hair Volume Lines & Shine -->
      <path d="M 440,270 Q 500,250 560,270" fill="none" stroke="{PALETTE['hair_highlight']}" stroke-width="3.5" stroke-linecap="round" opacity="0.8"/>
      <path d="M 450,290 Q 500,275 550,290" fill="none" stroke="{PALETTE['hair_highlight']}" stroke-width="2.5" stroke-linecap="round" opacity="0.6"/>
    </g>'''

def get_layer_hair_front():
    # Long flowing front tresses framing cheeks and falling over shoulders onto chest
    return f'''
    <g id="nemi_hair_front">
      <!-- Left Front Tress (Screen Left / Character Right) -->
      <path d="M 410,310
               C 390,360 380,430 385,500
               C 390,560 410,630 420,700
               C 425,725 435,730 435,705
               C 435,670 425,600 420,530
               C 415,460 425,390 435,335 Z"
            fill="{PALETTE['hair_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.5" stroke-linejoin="round"/>
      <!-- Left Tress Shadow -->
      <path d="M 390,480 C 395,550 410,620 420,690" fill="none" stroke="{PALETTE['hair_shadow']}" stroke-width="2.2" stroke-linecap="round"/>

      <!-- Right Front Tress (Screen Right / Character Left) -->
      <path d="M 590,310
               C 610,360 620,430 615,500
               C 610,560 590,630 580,700
               C 575,725 565,730 565,705
               C 565,670 575,600 580,530
               C 585,460 575,390 565,335 Z"
            fill="{PALETTE['hair_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.5" stroke-linejoin="round"/>
      <!-- Right Tress Shadow -->
      <path d="M 610,480 C 605,550 590,620 580,690" fill="none" stroke="{PALETTE['hair_shadow']}" stroke-width="2.2" stroke-linecap="round"/>
    </g>'''

def get_layer_hoodie_torso():
    # Complete torso volume: hood collar, dropped shoulders, body extending down to Y=865 (past skirt waistband at Y=825)
    return f'''
    <g id="nemi_hoodie_torso">
      <!-- Main Hoodie Body extending under skirt -->
      <path d="M 455,555
               C 415,565 390,590 385,635
               L 395,785
               C 398,825 410,865 425,865
               L 575,865
               C 590,865 602,825 605,785
               L 615,635
               C 610,590 585,565 545,555
               C 525,565 475,565 455,555 Z"
            fill="{PALETTE['hoodie_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.6" stroke-linejoin="round"/>

      <!-- Hoodie Shadow (Sides & Hem Creases) -->
      <path d="M 388,650 C 392,720 398,780 405,830 L 420,830 L 415,770 Z" fill="{PALETTE['hoodie_shadow']}"/>
      <path d="M 612,650 C 608,720 602,780 595,830 L 580,830 L 585,770 Z" fill="{PALETTE['hoodie_shadow']}"/>

      <!-- Ribbed Waistband Hem (Visible at Y=780..825) -->
      <path d="M 405,785 C 440,795 560,795 595,785 L 590,828 C 555,838 445,838 410,828 Z"
            fill="{PALETTE['hoodie_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>

      <!-- Kangaroo Pocket Outline -->
      <path d="M 440,715 L 460,670 L 540,670 L 560,715 L 560,780 L 440,780 Z"
            fill="none" stroke="{PALETTE['hoodie_shadow']}" stroke-width="2.2" stroke-linejoin="round"/>

      <!-- Hood Collar Framing the Neck with center V notch -->
      <path d="M 460,545
               C 440,560 445,595 470,605
               L 495,620 L 505,620 L 530,605
               C 555,595 560,560 540,545
               C 520,555 480,555 460,545 Z"
            fill="{PALETTE['hoodie_highlight']}"
            stroke="{PALETTE['line']}" stroke-width="2.4" stroke-linejoin="round"/>
      <!-- Collar Inner Crease -->
      <path d="M 495,620 L 500,640 L 505,620" fill="{PALETTE['hoodie_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>
    </g>'''

def get_layer_hoodie_drawstrings():
    return f'''
    <g id="nemi_hoodie_drawstrings">
      <!-- Left Drawstring -->
      <path d="M 485,615 Q 480,660 482,695" fill="none" stroke="{PALETTE['drawstring']}" stroke-width="3.5" stroke-linecap="round"/>
      <circle cx="482" cy="697" r="3.2" fill="{PALETTE['line']}"/>

      <!-- Right Drawstring -->
      <path d="M 515,615 Q 520,660 518,695" fill="none" stroke="{PALETTE['drawstring']}" stroke-width="3.5" stroke-linecap="round"/>
      <circle cx="518" cy="697" r="3.2" fill="{PALETTE['line']}"/>
    </g>'''

def get_layer_skirt():
    # Dark green pleated tennis skirt
    # Hidden waistband extends up to Y=790 under hoodie hem
    # Hem at Y=950 with knife pleats
    return f'''
    <g id="nemi_skirt">
      <!-- Skirt Base / Underlayer extending under hoodie -->
      <path d="M 418,790 L 582,790 L 618,950 L 382,950 Z"
            fill="{PALETTE['skirt_base']}" />

      <!-- Knife Pleats Folds with Alternating Shadow Bands -->
      <!-- Pleat 1 -->
      <path d="M 382,950 L 400,820 L 420,820 L 408,950 Z" fill="{PALETTE['skirt_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>
      <!-- Pleat 2 -->
      <path d="M 408,950 L 420,820 L 442,820 L 434,950 Z" fill="{PALETTE['skirt_base']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>
      <!-- Pleat 3 -->
      <path d="M 434,950 L 442,820 L 466,820 L 462,950 Z" fill="{PALETTE['skirt_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>
      <!-- Pleat 4 (Center Left) -->
      <path d="M 462,950 L 466,820 L 492,820 L 490,950 Z" fill="{PALETTE['skirt_base']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>
      <!-- Pleat 5 (Center Right) -->
      <path d="M 490,950 L 492,820 L 518,820 L 518,950 Z" fill="{PALETTE['skirt_base']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>
      <!-- Pleat 6 -->
      <path d="M 518,950 L 518,820 L 542,820 L 546,950 Z" fill="{PALETTE['skirt_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>
      <!-- Pleat 7 -->
      <path d="M 546,950 L 542,820 L 565,820 L 574,950 Z" fill="{PALETTE['skirt_base']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>
      <!-- Pleat 8 -->
      <path d="M 574,950 L 565,820 L 585,820 L 618,950 Z" fill="{PALETTE['skirt_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>

      <!-- Skirt Bottom Hem Line -->
      <path d="M 382,950 C 440,958 560,958 618,950" fill="none" stroke="{PALETTE['line']}" stroke-width="2.5" stroke-linecap="round"/>
    </g>'''

def get_layer_leg_left():
    # Screen-left leg (Character's right): Thigh starts at Y=880 (under skirt!), knee, calf, white sock
    return f'''
    <g id="nemi_leg_left">
      <!-- Thigh (starting inside skirt Y=880 down to knee Y=1150) -->
      <path d="M 432,880
               L 435,1020
               C 436,1080 440,1130 442,1160
               C 445,1190 448,1240 450,1260
               L 482,1260
               C 485,1240 488,1190 485,1160
               C 482,1130 482,1080 480,1020
               L 476,880 Z"
            fill="{PALETTE['skin_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>

      <!-- Soft Knee Accent -->
      <path d="M 452,1152 Q 464,1156 476,1152" fill="none" stroke="{PALETTE['skin_shadow']}" stroke-width="2.0" stroke-linecap="round"/>
      <ellipse cx="464" cy="1158" rx="4" ry="2" fill="{PALETTE['skin_blush']}" opacity="0.4"/>

      <!-- White Crew Sock (Y=1250 to Y=1340) with ribbed cuff -->
      <path d="M 448,1255
               C 446,1280 445,1315 444,1340
               L 488,1340
               C 487,1315 486,1280 484,1255 Z"
            fill="{PALETTE['sock_white']}"
            stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>
      <!-- Sock Cuff Ring -->
      <path d="M 446,1260 Q 466,1264 486,1260" fill="none" stroke="{PALETTE['sock_shadow']}" stroke-width="3.0"/>
      <!-- Sock Ankle Crease -->
      <path d="M 450,1325 Q 466,1330 482,1325" fill="none" stroke="{PALETTE['sock_shadow']}" stroke-width="1.8"/>
    </g>'''

def get_layer_leg_right():
    # Screen-right leg (Character's left)
    return f'''
    <g id="nemi_leg_right">
      <!-- Thigh (starting inside skirt Y=880 down to knee Y=1150) -->
      <path d="M 524,880
               L 520,1020
               C 518,1080 518,1130 515,1160
               C 512,1190 515,1240 518,1260
               L 550,1260
               C 552,1240 555,1190 558,1160
               C 560,1130 564,1080 565,1020
               L 568,880 Z"
            fill="{PALETTE['skin_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>

      <!-- Knee Accent -->
      <path d="M 524,1152 Q 536,1156 548,1152" fill="none" stroke="{PALETTE['skin_shadow']}" stroke-width="2.0" stroke-linecap="round"/>
      <ellipse cx="536" cy="1158" rx="4" ry="2" fill="{PALETTE['skin_blush']}" opacity="0.4"/>

      <!-- White Crew Sock -->
      <path d="M 516,1255
               C 514,1280 513,1315 512,1340
               L 556,1340
               C 555,1315 554,1280 552,1255 Z"
            fill="{PALETTE['sock_white']}"
            stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>
      <!-- Sock Cuff Ring -->
      <path d="M 514,1260 Q 534,1264 554,1260" fill="none" stroke="{PALETTE['sock_shadow']}" stroke-width="3.0"/>
      <!-- Sock Ankle Crease -->
      <path d="M 518,1325 Q 534,1330 550,1325" fill="none" stroke="{PALETTE['sock_shadow']}" stroke-width="1.8"/>
    </g>'''

def get_layer_shoe_left():
    # Chunky white sneaker with sage green flash, tongue, laces, and sole tread
    return f'''
    <g id="nemi_shoe_left">
      <!-- Dark Sole Tread (Y=1405..1425) -->
      <path d="M 430,1408 L 496,1408 C 498,1418 494,1424 485,1424 L 438,1424 C 430,1424 428,1418 430,1408 Z"
            fill="{PALETTE['shoe_sole']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>

      <!-- Sneaker Midsole (White/Cushioned) -->
      <path d="M 432,1390 L 494,1390 L 496,1408 L 430,1408 Z"
            fill="{PALETTE['shoe_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>

      <!-- Shoe Upper Body -->
      <path d="M 440,1330
               L 444,1360
               L 428,1392
               C 432,1396 492,1396 498,1392
               L 486,1360
               L 484,1330 Z"
            fill="{PALETTE['shoe_white']}"
            stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>

      <!-- Sage Green Curved Side Accent -->
      <path d="M 435,1382 C 450,1370 475,1370 490,1382 L 485,1388 C 470,1378 450,1378 438,1388 Z"
            fill="{PALETTE['shoe_green']}"/>

      <!-- Sneaker Tongue & Laces -->
      <path d="M 454,1342 L 474,1342" stroke="{PALETTE['line_soft']}" stroke-width="2.0" stroke-linecap="round"/>
      <path d="M 452,1355 L 476,1355" stroke="{PALETTE['line_soft']}" stroke-width="2.0" stroke-linecap="round"/>
      <path d="M 450,1368 L 478,1368" stroke="{PALETTE['line_soft']}" stroke-width="2.0" stroke-linecap="round"/>
      <!-- Tied Bow Laces -->
      <ellipse cx="456" cy="1348" rx="6" ry="3" fill="none" stroke="{PALETTE['line_soft']}" stroke-width="1.8"/>
      <ellipse cx="472" cy="1348" rx="6" ry="3" fill="none" stroke="{PALETTE['line_soft']}" stroke-width="1.8"/>
    </g>'''

def get_layer_shoe_right():
    return f'''
    <g id="nemi_shoe_right">
      <!-- Sole Tread -->
      <path d="M 504,1408 L 570,1408 C 572,1418 568,1424 559,1424 L 512,1424 C 504,1424 502,1418 504,1408 Z"
            fill="{PALETTE['shoe_sole']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>

      <!-- Midsole -->
      <path d="M 506,1390 L 568,1390 L 570,1408 L 504,1408 Z"
            fill="{PALETTE['shoe_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>

      <!-- Shoe Upper Body -->
      <path d="M 514,1330
               L 516,1360
               L 502,1392
               C 506,1396 566,1396 572,1392
               L 560,1360
               L 558,1330 Z"
            fill="{PALETTE['shoe_white']}"
            stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>

      <!-- Sage Green Accent -->
      <path d="M 509,1382 C 524,1370 549,1370 564,1382 L 559,1388 C 544,1378 524,1378 512,1388 Z"
            fill="{PALETTE['shoe_green']}"/>

      <!-- Laces -->
      <path d="M 526,1342 L 546,1342" stroke="{PALETTE['line_soft']}" stroke-width="2.0" stroke-linecap="round"/>
      <path d="M 524,1355 L 548,1355" stroke="{PALETTE['line_soft']}" stroke-width="2.0" stroke-linecap="round"/>
      <path d="M 522,1368 L 550,1368" stroke="{PALETTE['line_soft']}" stroke-width="2.0" stroke-linecap="round"/>
      <ellipse cx="528" cy="1348" rx="6" ry="3" fill="none" stroke="{PALETTE['line_soft']}" stroke-width="1.8"/>
      <ellipse cx="544" cy="1348" rx="6" ry="3" fill="none" stroke="{PALETTE['line_soft']}" stroke-width="1.8"/>
    </g>'''

def get_layer_arm_left_upper():
    # Character's Right / Screen-Left Upper Arm:
    # Full circular shoulder cap centered at (395, 575) radius 32 extending into torso!
    # Rounded elbow joint cap at (365, 715) radius 26 extending into forearm!
    return f'''
    <g id="nemi_arm_left_upper">
      <!-- Complete Upper Arm Sleeve with Circular Joint Caps -->
      <path d="M 395,545
               C 415,545 425,565 425,585
               L 395,715
               C 392,735 365,745 350,735
               C 338,720 342,700 345,685
               L 365,585
               C 365,560 375,545 395,545 Z"
            fill="{PALETTE['hoodie_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.4" stroke-linejoin="round"/>
      <!-- Shoulder Seam Line / Crease -->
      <path d="M 370,590 Q 390,600 410,590" fill="none" stroke="{PALETTE['hoodie_shadow']}" stroke-width="2.0"/>
      <!-- Fabric Fold Crease -->
      <path d="M 360,650 Q 380,660 395,645" fill="none" stroke="{PALETTE['hoodie_shadow']}" stroke-width="2.0" stroke-linecap="round"/>
    </g>'''

def get_layer_arm_left_lower():
    # Lower arm sleeve: rounded elbow cap at (365, 715) overlapping upper arm,
    # loose sleeve body, gathered elastic cuff at wrist (375, 840)
    return f'''
    <g id="nemi_arm_left_lower">
      <!-- Rounded Elbow Overlap Cap -->
      <circle cx="365" cy="715" r="24" fill="{PALETTE['hoodie_base']}"/>

      <!-- Puffy Forearm Sleeve -->
      <path d="M 345,715
               C 335,760 340,810 355,840
               L 395,840
               C 405,810 400,760 390,715 Z"
            fill="{PALETTE['hoodie_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.4" stroke-linejoin="round"/>
      <!-- Fabric Folds -->
      <path d="M 350,775 Q 370,785 390,770" fill="none" stroke="{PALETTE['hoodie_shadow']}" stroke-width="2.0" stroke-linecap="round"/>

      <!-- Gathered Elastic Wrist Cuff -->
      <path d="M 355,835 L 395,835 L 392,852 L 358,852 Z"
            fill="{PALETTE['hoodie_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>
    </g>'''

def get_layer_hand_left():
    # Left hand: wrist shaft enters cuff (Y=840..852), full palm, thumb, fingers (Y down to 915)
    return f'''
    <g id="nemi_hand_left">
      <!-- Hidden wrist shaft entering cuff -->
      <path d="M 365,840 L 385,840 L 388,860 L 362,860 Z" fill="{PALETTE['skin_base']}"/>

      <!-- Hand Palm & Relaxed Fingers -->
      <path d="M 362,855
               C 355,875 352,895 358,912
               C 362,918 368,918 372,912
               C 375,905 378,890 380,885
               C 382,895 385,915 388,912
               C 392,908 392,890 390,875
               C 395,870 398,860 388,855 Z"
            fill="{PALETTE['skin_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.0" stroke-linejoin="round"/>
      <!-- Subtle Finger Separation Lines -->
      <path d="M 372,890 L 372,908" stroke="{PALETTE['skin_shadow']}" stroke-width="1.6" stroke-linecap="round"/>
      <path d="M 380,885 L 382,905" stroke="{PALETTE['skin_shadow']}" stroke-width="1.6" stroke-linecap="round"/>
    </g>'''

def get_layer_arm_right_upper():
    # Character's Left / Screen-Right Upper Arm
    return f'''
    <g id="nemi_arm_right_upper">
      <!-- Complete Upper Arm Sleeve with Circular Joint Caps -->
      <path d="M 605,545
               C 585,545 575,565 575,585
               L 605,715
               C 608,735 635,745 650,735
               C 662,720 658,700 655,685
               L 635,585
               C 635,560 625,545 605,545 Z"
            fill="{PALETTE['hoodie_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.4" stroke-linejoin="round"/>
      <!-- Shoulder Seam Line / Crease -->
      <path d="M 630,590 Q 610,600 590,590" fill="none" stroke="{PALETTE['hoodie_shadow']}" stroke-width="2.0"/>
      <!-- Fabric Fold Crease -->
      <path d="M 640,650 Q 620,660 605,645" fill="none" stroke="{PALETTE['hoodie_shadow']}" stroke-width="2.0" stroke-linecap="round"/>
    </g>'''

def get_layer_arm_right_lower():
    return f'''
    <g id="nemi_arm_right_lower">
      <!-- Rounded Elbow Overlap Cap -->
      <circle cx="635" cy="715" r="24" fill="{PALETTE['hoodie_base']}"/>

      <!-- Puffy Forearm Sleeve -->
      <path d="M 655,715
               C 665,760 660,810 645,840
               L 605,840
               C 595,810 600,760 610,715 Z"
            fill="{PALETTE['hoodie_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.4" stroke-linejoin="round"/>
      <!-- Fabric Folds -->
      <path d="M 650,775 Q 630,785 610,770" fill="none" stroke="{PALETTE['hoodie_shadow']}" stroke-width="2.0" stroke-linecap="round"/>

      <!-- Gathered Elastic Wrist Cuff -->
      <path d="M 645,835 L 605,835 L 608,852 L 642,852 Z"
            fill="{PALETTE['hoodie_shadow']}" stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>
    </g>'''

def get_layer_hand_right():
    return f'''
    <g id="nemi_hand_right">
      <!-- Hidden wrist shaft entering cuff -->
      <path d="M 635,840 L 615,840 L 612,860 L 638,860 Z" fill="{PALETTE['skin_base']}"/>

      <!-- Hand Palm & Relaxed Fingers -->
      <path d="M 638,855
               C 645,875 648,895 642,912
               C 638,918 632,918 628,912
               C 625,905 622,890 620,885
               C 618,895 615,915 612,912
               C 608,908 608,890 610,875
               C 605,870 602,860 612,855 Z"
            fill="{PALETTE['skin_base']}"
            stroke="{PALETTE['line']}" stroke-width="2.0" stroke-linejoin="round"/>
      <!-- Finger Separation Lines -->
      <path d="M 628,890 L 628,908" stroke="{PALETTE['skin_shadow']}" stroke-width="1.6" stroke-linecap="round"/>
      <path d="M 620,885 L 618,905" stroke="{PALETTE['skin_shadow']}" stroke-width="1.6" stroke-linecap="round"/>
    </g>'''

def get_layer_bag_shoulder():
    # Cross-body diagonal strap from right shoulder (580, 560) to left hip (420, 800) and hip bag
    return f'''
    <g id="nemi_bag_shoulder">
      <!-- Diagonal Strap across chest -->
      <path d="M 580,555 L 420,780 L 408,772 L 568,547 Z"
            fill="{PALETTE['bag_dark']}" stroke="{PALETTE['line']}" stroke-width="2.0"/>

      <!-- Bag Body resting at left hip (X=365..435, Y=765..870) -->
      <path d="M 375,765
               C 425,765 435,780 435,820
               L 430,860
               C 425,875 375,875 370,860
               L 365,820
               C 365,780 370,765 375,765 Z"
            fill="{PALETTE['bag_dark']}"
            stroke="{PALETTE['line']}" stroke-width="2.2" stroke-linejoin="round"/>
      <!-- Bag Flap Seam -->
      <path d="M 366,810 Q 400,820 434,810" fill="none" stroke="{PALETTE['line_soft']}" stroke-width="1.8"/>

      <!-- Gold Leaf Emblem -->
      <path d="M 400,825 C 392,835 394,845 400,852 C 406,845 408,835 400,825 Z"
            fill="{PALETTE['bag_leaf']}"/>
      <path d="M 400,828 L 400,850" stroke="{PALETTE['line']}" stroke-width="1.2"/>
    </g>'''

# -----------------------------------------------------------------------------
# MASTER ASSEMBLED ILLUSTRATION
# -----------------------------------------------------------------------------

def generate_all():
    print("Generating Nemi production vector artwork layers...")

    layers = {
        # Hair
        ("hair", "nemi_hair_back"): get_layer_hair_back(),
        ("hair", "nemi_hair_bangs"): get_layer_hair_bangs(),
        ("hair", "nemi_hair_front"): get_layer_hair_front(),

        # Face
        ("face", "nemi_face_base"): get_layer_face_base(),
        ("face", "nemi_eye_left"): get_layer_eye_left(),
        ("face", "nemi_eye_right"): get_layer_eye_right(),
        ("face", "nemi_eyebrows"): get_layer_eyebrows(),
        ("face", "nemi_mouth_neutral"): get_layer_mouth(),

        # Body
        ("body", "nemi_neck"): get_layer_neck(),
        ("body", "nemi_leg_left"): get_layer_leg_left(),
        ("body", "nemi_leg_right"): get_layer_leg_right(),
        ("body", "nemi_shoe_left"): get_layer_shoe_left(),
        ("body", "nemi_shoe_right"): get_layer_shoe_right(),
        ("body", "nemi_arm_left_upper"): get_layer_arm_left_upper(),
        ("body", "nemi_arm_left_lower"): get_layer_arm_left_lower(),
        ("body", "nemi_hand_left"): get_layer_hand_left(),
        ("body", "nemi_arm_right_upper"): get_layer_arm_right_upper(),
        ("body", "nemi_arm_right_lower"): get_layer_arm_right_lower(),
        ("body", "nemi_hand_right"): get_layer_hand_right(),

        # Clothes
        ("clothes", "nemi_hoodie_torso"): get_layer_hoodie_torso(),
        ("clothes", "nemi_hoodie_drawstrings"): get_layer_hoodie_drawstrings(),
        ("clothes", "nemi_skirt"): get_layer_skirt(),

        # Accessories
        ("accessories", "nemi_bag_shoulder"): get_layer_bag_shoulder(),
    }

    # Save each individual modular SVG
    for (folder, name), content in layers.items():
        svg_full = create_svg_wrapper(content)
        dir_path = os.path.join(ART_DIR, folder)
        file_path = os.path.join(dir_path, f"{name}.svg")
        with open(file_path, "w") as f:
            f.write(svg_full)
        print(f"  Saved {folder}/{name}.svg")

    # Master Stacking Order (Proper Depth Stacking)
    master_stack = [
        get_layer_hair_back(),           # 1. Back hair (deepest)
        get_layer_leg_left(),            # 2. Left leg (under skirt)
        get_layer_leg_right(),           # 3. Right leg (under skirt)
        get_layer_shoe_left(),           # 4. Left shoe
        get_layer_shoe_right(),          # 5. Right shoe
        get_layer_skirt(),               # 6. Skirt (over legs, under torso)
        get_layer_neck(),                # 7. Neck (into hoodie)
        get_layer_hoodie_torso(),        # 8. Hoodie body (over skirt top)
        get_layer_arm_left_upper(),      # 9. Left upper arm
        get_layer_arm_left_lower(),      # 10. Left lower arm
        get_layer_hand_left(),           # 11. Left hand
        get_layer_arm_right_upper(),     # 12. Right upper arm
        get_layer_arm_right_lower(),     # 13. Right lower arm
        get_layer_hand_right(),          # 14. Right hand
        get_layer_bag_shoulder(),        # 15. Crossbody bag & strap
        get_layer_hoodie_drawstrings(),  # 16. Drawstrings over hoodie
        get_layer_face_base(),           # 17. Head base & ears
        get_layer_eye_left(),            # 18. Left eye
        get_layer_eye_right(),           # 19. Right eye
        get_layer_eyebrows(),            # 20. Eyebrows
        get_layer_mouth(),               # 21. Mouth
        get_layer_hair_front(),          # 22. Front side hair tresses
        get_layer_hair_bangs(),          # 23. Forehead bangs + ahoge (top)
    ]

    master_content = "\n".join(master_stack)
    master_svg = create_svg_wrapper(master_content)
    master_svg_path = os.path.join(MASTER_DIR, "nemi_master.svg")
    with open(master_svg_path, "w") as f:
        f.write(master_svg)
    print(f"Saved master assembled character at: {master_svg_path}")

    # Render master character to high-res PNG via qlmanage
    print("Rendering high-res master PNG...")
    cmd = ["qlmanage", "-t", "-s", "1400", "-o", MASTER_DIR, master_svg_path]
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    # qlmanage creates nemi_master.svg.png -> rename to nemi_master.png
    gen_png = os.path.join(MASTER_DIR, "nemi_master.svg.png")
    target_png = os.path.join(MASTER_DIR, "nemi_master.png")
    if os.path.exists(gen_png):
        os.rename(gen_png, target_png)
        print("Generated master PNG at:", target_png)

if __name__ == "__main__":
    generate_all()

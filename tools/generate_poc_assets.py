import os
import math
import numpy as np
from PIL import Image, ImageDraw

LINE_COLOR = (62, 8, 30, 255)       # Signature #3e081e deep wine/burgundy
FILL_WHITE = (255, 255, 255, 255)
FILL_BLUSH = (255, 180, 190, 220)
FILL_TONGUE = (255, 130, 155, 255)
FILL_SWEAT = (160, 210, 255, 240)
TRANSPARENT = (0, 0, 0, 0)

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def create_canvas(w=512, h=512):
    return Image.new("RGBA", (w, h), TRANSPARENT)

def draw_tapered_line(draw, p1, p2, w1=5.0, w2=5.0, color=LINE_COLOR):
    steps = max(int(math.hypot(p2[0]-p1[0], p2[1]-p1[1])), 1)
    for i in range(steps + 1):
        t = i / float(steps)
        x = p1[0] + (p2[0] - p1[0]) * t
        y = p1[1] + (p2[1] - p1[1]) * t
        w = w1 + (w2 - w1) * t
        r = w / 2.0
        draw.ellipse([x - r, y - r, x + r, y + r], fill=color)

def draw_smooth_spline(draw, points, width=5.0, color=LINE_COLOR, closed=False):
    pts = list(points)
    if closed:
        pts = [pts[-1]] + pts + [pts[0], pts[1]]
    else:
        pts = [pts[0]] + pts + [pts[-1]]

    def catmull_rom_point(p0, p1, p2, p3, t):
        t2 = t * t
        t3 = t2 * t
        f0 = -0.5 * t3 + t2 - 0.5 * t
        f1 = 1.5 * t3 - 2.5 * t2 + 1.0
        f2 = -1.5 * t3 + 2.0 * t2 + 0.5 * t
        f3 = 0.5 * t3 - 0.5 * t2
        x = p0[0] * f0 + p1[0] * f1 + p2[0] * f2 + p3[0] * f3
        y = p0[1] * f0 + p1[1] * f1 + p2[1] * f2 + p3[1] * f3
        return (x, y)

    sampled = []
    for i in range(len(pts) - 3):
        p0, p1, p2, p3 = pts[i], pts[i+1], pts[i+2], pts[i+3]
        seg_dist = math.hypot(p2[0]-p1[0], p2[1]-p1[1])
        steps = max(int(seg_dist / 3.0), 4)
        for s in range(steps):
            t = s / float(steps)
            sampled.append(catmull_rom_point(p0, p1, p2, p3, t))
    sampled.append(pts[-2])

    for i in range(len(sampled) - 1):
        draw_tapered_line(draw, sampled[i], sampled[i+1], width, width, color)

    return sampled

def generate_head_base():
    # 512x512 Canvas.
    # Center of head ~ (256, 260).
    # Chin point ~ (256, 385).
    # Neck bottom ~ (256, 440).
    # Top of hair ~ (256, 120).
    im = create_canvas(512, 512)
    draw = ImageDraw.Draw(im)

    # Hair Back silhouette
    hair_back_pts = [
        (160, 220), (115, 290), (95, 360), (120, 420), (150, 440),
        (185, 410), (210, 370), (302, 370), (327, 410), (362, 440),
        (392, 420), (417, 360), (397, 290), (352, 220)
    ]
    draw.polygon(hair_back_pts, fill=FILL_WHITE)
    draw_smooth_spline(draw, [(160, 220), (115, 290), (95, 360), (120, 420), (150, 440), (185, 410)], width=5.5)
    draw_smooth_spline(draw, [(352, 220), (397, 290), (417, 360), (392, 420), (362, 440), (327, 410)], width=5.5)

    # Neck
    draw_tapered_line(draw, (238, 365), (238, 435), 5.5, 5.5)
    draw_tapered_line(draw, (274, 365), (274, 435), 5.5, 5.5)
    draw_smooth_spline(draw, [(235, 425), (256, 435), (277, 425)], width=5.0)

    # Jawline and chin
    jaw_pts = [
        (170, 260), (175, 310), (192, 350), (220, 375),
        (256, 388), # Chin
        (292, 375), (320, 350), (337, 310), (342, 260)
    ]
    face_poly = jaw_pts + [(342, 190), (170, 190)]
    draw.polygon(face_poly, fill=FILL_WHITE)
    draw_smooth_spline(draw, jaw_pts, width=5.5)

    # Ears
    draw_smooth_spline(draw, [(168, 275), (152, 290), (162, 315), (172, 320)], width=4.5)
    draw_smooth_spline(draw, [(344, 275), (360, 290), (350, 315), (340, 320)], width=4.5)

    # Cute nose button & dot
    draw.ellipse([251, 318, 261, 328], outline=LINE_COLOR, fill=FILL_WHITE, width=3)
    draw.ellipse([255, 336, 257, 338], fill=LINE_COLOR)

    # Hair dome
    hair_top = [
        (135, 250), (120, 185), (145, 130), (195, 95), (256, 85),
        (317, 95), (367, 130), (392, 185), (377, 250)
    ]
    draw_smooth_spline(draw, hair_top, width=5.5)

    # Bangs
    bang_l1 = [(180, 105), (175, 165), (170, 225), (190, 255), (195, 215), (200, 165), (220, 100)]
    draw_smooth_spline(draw, bang_l1, width=5.0)

    bang_c = [(230, 95), (225, 155), (220, 215), (225, 265), (240, 225), (245, 165), (255, 90)]
    draw_smooth_spline(draw, bang_c, width=5.0)

    bang_r = [(265, 95), (275, 155), (285, 215), (290, 260), (295, 205), (315, 155), (330, 105)]
    draw_smooth_spline(draw, bang_r, width=5.0)

    # Cheek framing tendrils
    draw_smooth_spline(draw, [(150, 220), (158, 270), (162, 325), (175, 360)], width=4.5)
    draw_smooth_spline(draw, [(362, 220), (354, 270), (350, 325), (337, 360)], width=4.5)

    # Top ahoge tuft
    ahoge = [(245, 88), (232, 55), (244, 45), (256, 68), (268, 50), (280, 60), (267, 88)]
    draw_smooth_spline(draw, ahoge, width=4.5)

    out_path = os.path.join(BASE_DIR, "assets/characters/storyteller/heads/head_base.png")
    im.save(out_path)
    print("Saved refined head_base to", out_path)

def generate_poses():
    # 512x512 Canvas.
    # Neck collar top ~ (256, 50). Lower waist ~ (256, 480).
    im_n = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_n)
    body_fill = [
        (225, 50), (165, 85), (135, 150), (130, 245), (160, 295), (190, 305),
        (195, 480), (317, 480), (322, 305), (352, 295), (382, 245), (377, 150),
        (347, 85), (287, 50)
    ]
    draw.polygon(body_fill, fill=FILL_WHITE)
    draw_smooth_spline(draw, [(225, 50), (165, 80), (135, 145), (130, 245)], width=5.5)
    draw_smooth_spline(draw, [(287, 50), (347, 80), (377, 145), (382, 245)], width=5.5)
    draw_smooth_spline(draw, [(165, 155), (175, 255), (190, 480)], width=5.5)
    draw_smooth_spline(draw, [(347, 155), (337, 255), (322, 480)], width=5.5)
    draw_smooth_spline(draw, [(130, 245), (155, 300), (205, 310), (235, 295)], width=5.5)
    draw_smooth_spline(draw, [(382, 245), (357, 300), (307, 310), (277, 295)], width=5.5)
    draw_smooth_spline(draw, [(223, 48), (256, 56), (289, 48)], width=5.5)
    im_n.save(os.path.join(BASE_DIR, "assets/characters/storyteller/body/pose_neutral.png"))

    # Crossed Arms (frame 25)
    im_c = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_c)
    draw.polygon(body_fill, fill=FILL_WHITE)
    draw_smooth_spline(draw, [(225, 50), (165, 80), (135, 145), (150, 215), (265, 250), (320, 220)], width=5.5)
    draw_smooth_spline(draw, [(287, 50), (347, 80), (377, 145), (355, 220), (250, 255), (195, 225)], width=5.5)
    draw_smooth_spline(draw, [(310, 210), (325, 225), (312, 240)], width=4.5)
    draw_smooth_spline(draw, [(205, 215), (190, 230), (202, 245)], width=4.5)
    draw_smooth_spline(draw, [(160, 220), (175, 310), (190, 480)], width=5.5)
    draw_smooth_spline(draw, [(352, 220), (337, 310), (322, 480)], width=5.5)
    draw_smooth_spline(draw, [(223, 48), (256, 56), (289, 48)], width=5.5)
    im_c.save(os.path.join(BASE_DIR, "assets/characters/storyteller/body/pose_crossed_arms.png"))

    # Gesturing
    im_g = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_g)
    draw.polygon(body_fill, fill=FILL_WHITE)
    draw_smooth_spline(draw, [(225, 50), (165, 85), (135, 155), (135, 255), (160, 345)], width=5.5)
    draw_smooth_spline(draw, [(287, 50), (350, 75), (375, 140), (350, 200), (300, 175)], width=5.5)
    gesture_hand = [(300, 175), (292, 145), (302, 130), (312, 145), (318, 175)]
    draw_smooth_spline(draw, gesture_hand, width=4.5)
    draw_smooth_spline(draw, [(160, 155), (175, 265), (190, 480)], width=5.5)
    draw_smooth_spline(draw, [(350, 200), (337, 295), (322, 480)], width=5.5)
    draw_smooth_spline(draw, [(223, 48), (256, 56), (289, 48)], width=5.5)
    im_g.save(os.path.join(BASE_DIR, "assets/characters/storyteller/body/pose_gesturing.png"))

    # Recoil
    im_r = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_r)
    recoil_pts = [
        (225, 60), (145, 50), (115, 120), (125, 210), (160, 480),
        (352, 480), (387, 210), (397, 120), (367, 50), (287, 60)
    ]
    draw.polygon(recoil_pts, fill=FILL_WHITE)
    draw_smooth_spline(draw, [(225, 60), (150, 50), (120, 120), (130, 200)], width=5.5)
    draw_smooth_spline(draw, [(287, 60), (362, 50), (392, 120), (382, 200)], width=5.5)
    draw_smooth_spline(draw, [(120, 120), (100, 160), (120, 185)], width=5.0)
    draw_smooth_spline(draw, [(392, 120), (412, 160), (392, 185)], width=5.0)
    draw_smooth_spline(draw, [(150, 140), (165, 270), (175, 480)], width=5.5)
    draw_smooth_spline(draw, [(362, 140), (347, 270), (337, 480)], width=5.5)
    draw_tapered_line(draw, (85, 80), (60, 65), 4.0, 2.0)
    draw_tapered_line(draw, (80, 110), (50, 110), 4.0, 2.0)
    draw_tapered_line(draw, (427, 80), (452, 65), 4.0, 2.0)
    draw_tapered_line(draw, (432, 110), (462, 110), 4.0, 2.0)
    draw_smooth_spline(draw, [(223, 58), (256, 66), (289, 58)], width=5.5)
    im_r.save(os.path.join(BASE_DIR, "assets/characters/storyteller/body/pose_recoil.png"))

    print("Saved refined body poses.")

def generate_eyes():
    # Eyes 512x512 canvas aligned with head_base.
    # Left eye center ~ (215, 278), Right eye center ~ (297, 278).
    im = create_canvas(512, 512)
    draw = ImageDraw.Draw(im)
    lash_l = [(196, 280), (206, 260), (224, 258), (236, 280)]
    draw_smooth_spline(draw, lash_l, width=6.0)
    draw_tapered_line(draw, (196, 280), (190, 274), 4.0, 2.0)
    draw.ellipse([206, 268, 228, 296], outline=LINE_COLOR, fill=FILL_WHITE, width=3)
    draw.ellipse([211, 273, 223, 291], fill=LINE_COLOR)
    draw.ellipse([214, 276, 218, 280], fill=FILL_WHITE)

    lash_r = [(276, 280), (288, 258), (306, 260), (316, 280)]
    draw_smooth_spline(draw, lash_r, width=6.0)
    draw_tapered_line(draw, (316, 280), (322, 274), 4.0, 2.0)
    draw.ellipse([284, 268, 306, 296], outline=LINE_COLOR, fill=FILL_WHITE, width=3)
    draw.ellipse([289, 273, 301, 291], fill=LINE_COLOR)
    draw.ellipse([292, 276, 296, 280], fill=FILL_WHITE)

    draw_smooth_spline(draw, [(198, 250), (214, 242), (230, 250)], width=4.0)
    draw_smooth_spline(draw, [(282, 250), (298, 242), (314, 250)], width=4.0)
    im.save(os.path.join(BASE_DIR, "assets/characters/storyteller/eyes/eyes_neutral.png"))

    # Squint
    im_sq = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_sq)
    draw_smooth_spline(draw, [(196, 282), (210, 262), (226, 262), (236, 282)], width=6.5)
    draw_tapered_line(draw, (196, 282), (190, 288), 4.5, 2.0)
    draw_smooth_spline(draw, [(276, 282), (286, 262), (302, 262), (316, 282)], width=6.5)
    draw_tapered_line(draw, (316, 282), (322, 288), 4.5, 2.0)
    draw_smooth_spline(draw, [(198, 244), (214, 232), (230, 244)], width=4.0)
    draw_smooth_spline(draw, [(282, 244), (298, 232), (314, 244)], width=4.0)
    im_sq.save(os.path.join(BASE_DIR, "assets/characters/storyteller/eyes/eyes_squint.png"))

    # Shocked
    im_sh = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_sh)
    draw.ellipse([198, 254, 234, 298], outline=LINE_COLOR, fill=FILL_WHITE, width=4)
    draw.ellipse([213, 273, 219, 279], fill=LINE_COLOR)
    draw.ellipse([278, 254, 314, 298], outline=LINE_COLOR, fill=FILL_WHITE, width=4)
    draw.ellipse([293, 273, 299, 279], fill=LINE_COLOR)
    draw_smooth_spline(draw, [(198, 238), (214, 222), (230, 238)], width=4.0)
    draw_smooth_spline(draw, [(282, 238), (298, 222), (314, 238)], width=4.0)
    im_sh.save(os.path.join(BASE_DIR, "assets/characters/storyteller/eyes/eyes_shocked.png"))

    # Deadpan
    im_dp = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_dp)
    draw.ellipse([200, 254, 232, 300], fill=LINE_COLOR)
    draw.ellipse([280, 254, 312, 300], fill=LINE_COLOR)
    draw.line([(200, 244), (232, 244)], fill=LINE_COLOR, width=4)
    draw.line([(280, 244), (312, 244)], fill=LINE_COLOR, width=4)
    im_dp.save(os.path.join(BASE_DIR, "assets/characters/storyteller/eyes/eyes_deadpan.png"))

    # Sparkle
    im_sp = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_sp)
    draw_smooth_spline(draw, lash_l, width=6.0)
    draw.ellipse([204, 264, 230, 298], outline=LINE_COLOR, fill=FILL_WHITE, width=3)
    star_l = [(217, 270), (219, 279), (226, 281), (219, 283), (217, 292), (215, 283), (208, 281), (215, 279)]
    draw.polygon(star_l, fill=LINE_COLOR)

    draw_smooth_spline(draw, lash_r, width=6.0)
    draw.ellipse([282, 264, 308, 298], outline=LINE_COLOR, fill=FILL_WHITE, width=3)
    star_r = [(295, 270), (297, 279), (304, 281), (297, 283), (295, 292), (293, 283), (286, 281), (293, 279)]
    draw.polygon(star_r, fill=LINE_COLOR)

    draw_smooth_spline(draw, [(198, 240), (214, 228), (230, 240)], width=4.0)
    draw_smooth_spline(draw, [(282, 240), (298, 228), (314, 240)], width=4.0)
    im_sp.save(os.path.join(BASE_DIR, "assets/characters/storyteller/eyes/eyes_sparkle.png"))

    # Blink
    im_bl = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_bl)
    draw.line([(200, 280), (232, 280)], fill=LINE_COLOR, width=5)
    draw.line([(280, 280), (312, 280)], fill=LINE_COLOR, width=5)
    draw.line([(200, 250), (232, 250)], fill=LINE_COLOR, width=4)
    draw.line([(280, 250), (312, 250)], fill=LINE_COLOR, width=4)
    im_bl.save(os.path.join(BASE_DIR, "assets/characters/storyteller/eyes/eyes_blink.png"))

    print("Saved refined eyes.")

def generate_mouths():
    # Mouth center ~ (256, 355)
    im = create_canvas(512, 512)
    draw = ImageDraw.Draw(im)
    draw.ellipse([249, 346, 263, 364], outline=LINE_COLOR, fill=FILL_WHITE, width=3)
    im.save(os.path.join(BASE_DIR, "assets/characters/storyteller/mouths/mouth_open_o.png"))

    im_sm = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_sm)
    pts = [(242, 348), (256, 365), (270, 348)]
    draw.polygon(pts + [(242, 348)], fill=FILL_WHITE)
    draw_smooth_spline(draw, pts, width=3.5)
    draw.line([(242, 348), (270, 348)], fill=LINE_COLOR, width=3)
    im_sm.save(os.path.join(BASE_DIR, "assets/characters/storyteller/mouths/mouth_smile.png"))

    im_bp = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_bp)
    draw.arc([243, 344, 256, 356], start=0, end=180, fill=LINE_COLOR, width=3)
    draw.arc([256, 344, 269, 356], start=0, end=180, fill=LINE_COLOR, width=3)
    draw.chord([251, 350, 261, 364], start=0, end=180, fill=FILL_TONGUE, outline=LINE_COLOR, width=2)
    im_bp.save(os.path.join(BASE_DIR, "assets/characters/storyteller/mouths/mouth_blep.png"))

    im_sk = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_sk)
    draw_smooth_spline(draw, [(244, 356), (257, 358), (270, 349)], width=3.5)
    im_sk.save(os.path.join(BASE_DIR, "assets/characters/storyteller/mouths/mouth_smirk.png"))

    im_fl = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_fl)
    draw.line([(247, 355), (265, 355)], fill=LINE_COLOR, width=3)
    im_fl.save(os.path.join(BASE_DIR, "assets/characters/storyteller/mouths/mouth_flat.png"))

    print("Saved refined mouths.")

def generate_details():
    im_bl = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_bl)
    for ox in [0, 8, 16]:
        draw.line([(205 + ox, 310), (210 + ox, 330)], fill=LINE_COLOR, width=3)
        draw.line([(287 + ox, 310), (292 + ox, 330)], fill=LINE_COLOR, width=3)
    im_bl.save(os.path.join(BASE_DIR, "assets/characters/storyteller/details/detail_blush.png"))

    im_sw = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_sw)
    sweat = [(320, 230), (328, 245), (322, 252), (314, 250), (312, 242)]
    draw.polygon(sweat, fill=FILL_SWEAT)
    draw_smooth_spline(draw, sweat, width=3.0, closed=True)
    im_sw.save(os.path.join(BASE_DIR, "assets/characters/storyteller/details/detail_sweat.png"))

    im_ex = create_canvas(512, 512)
    draw = ImageDraw.Draw(im_ex)
    box = [(345, 175), (380, 165), (385, 205), (360, 215), (350, 235), (352, 212), (340, 207)]
    draw.polygon(box, fill=FILL_WHITE)
    draw_smooth_spline(draw, box, width=3.5, closed=True)
    draw.line([(362, 178), (363, 196)], fill=LINE_COLOR, width=4)
    draw.ellipse([(361, 201), (365, 205)], fill=LINE_COLOR)
    im_ex.save(os.path.join(BASE_DIR, "assets/characters/storyteller/details/detail_exclamation.png"))

    print("Saved details.")

def generate_composite_preview():
    # 800x800 canvas with ample padding
    comp = Image.new("RGBA", (800, 800), (255, 255, 255, 255))
    body = Image.open(os.path.join(BASE_DIR, "assets/characters/storyteller/body/pose_neutral.png")).convert("RGBA")
    head = Image.open(os.path.join(BASE_DIR, "assets/characters/storyteller/heads/head_base.png")).convert("RGBA")
    eyes = Image.open(os.path.join(BASE_DIR, "assets/characters/storyteller/eyes/eyes_neutral.png")).convert("RGBA")
    mouth = Image.open(os.path.join(BASE_DIR, "assets/characters/storyteller/mouths/mouth_open_o.png")).convert("RGBA")

    # In head_base, neck collar is at (256, 430).
    # In body pose_neutral, neck collar is at (256, 50).
    # If body is at (144, 380), collar is at Y: 380 + 50 = 430.
    # So head at (144, 0) puts head collar at Y: 0 + 430 = 430! Perfect match!
    comp.alpha_composite(body, (144, 380))
    comp.alpha_composite(head, (144, 0))
    comp.alpha_composite(eyes, (144, 0))
    comp.alpha_composite(mouth, (144, 0))

    preview_path = os.path.join(BASE_DIR, "assets/characters/storyteller/composite_preview.png")
    comp.save(preview_path)
    print("Saved composite preview to", preview_path)

if __name__ == "__main__":
    generate_head_base()
    generate_poses()
    generate_eyes()
    generate_mouths()
    generate_details()
    generate_composite_preview()

import os
from PIL import Image, ImageDraw, ImageFont

img_dir = "characters/nemi/renders/acting/"
tests = [
    ("01_acting_test1_micro_acting.png", "1. Micro Acting (Hold, Dart, Blink, Tilt)"),
    ("02_acting_test2_conversational.png", "2. Conversational (Eyes Lead, Head Follows, Smile)"),
    ("03_acting_test3_confusion.png", "3. Confusion (Asymmetric Brow, Tilt, Question)"),
    ("04_acting_test4_realization.png", "4. Realization (Gaze, Widen, Brows, Gasp, Turn)"),
    ("05_acting_test5_shock_recoil.png", "5. Shock (Eyes Widen, Snap Mouth, Recoil, Freeze)"),
    ("06_acting_test6_deadpan_longhold.png", "6. Deadpan (Dry Glance, 3° Tilt, Long Hold)"),
    ("07_acting_test7_comedic_timing.png", "7. Comedic Timing (Setup -> Pause -> Shock -> Hold)"),
    ("08_acting_test8_exaggerated_action.png", "8. Exaggerated Action (Anticipate, Point, Overshoot)"),
    ("09_acting_test9_novel_combination.png", "9. Brand-New Combination (Lean, Turn, Point, Gaze)"),
]

cols = 3
rows = 3
thumb_w = 640
thumb_h = 360
pad = 16
header_h = 60
label_h = 40

sheet_w = cols * thumb_w + (cols + 1) * pad
sheet_h = header_h + rows * (thumb_h + label_h) + (rows + 1) * pad

sheet = Image.new("RGB", (sheet_w, sheet_h), "#1c1420")
draw = ImageDraw.Draw(sheet)

# Header
draw.rectangle([(0, 0), (sheet_w, header_h)], fill="#281a2e")
draw.text((pad + 10, 18), "NEMI — ACTING & ANIMATION LANGUAGE V1 (THE 9 AUTHORITATIVE TESTS)", fill="#f6d365")

for idx, (fname, label) in enumerate(tests):
    c = idx % cols
    r = idx // cols
    x = pad + c * (thumb_w + pad)
    y = header_h + pad + r * (thumb_h + label_h + pad)
    
    path = os.path.join(img_dir, fname)
    if os.path.exists(path):
        im = Image.open(path)
        im = im.resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        sheet.paste(im, (x, y))
    
    # Label bar
    draw.rectangle([(x, y + thumb_h), (x + thumb_w, y + thumb_h + label_h)], fill="#2c2033")
    draw.text((x + 12, y + thumb_h + 12), label, fill="#ffffff")

out_path = os.path.join(img_dir, "00_nemi_acting_tests_overview.png")
sheet.save(out_path, quality=95)
print("Saved overview contact sheet to:", out_path)

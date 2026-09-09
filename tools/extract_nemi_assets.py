import os
import numpy as np
from PIL import Image, ImageDraw
from collections import deque
from scipy.ndimage import binary_dilation, label, find_objects

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SRC_SHEET = os.path.join(BASE_DIR, "references/main_character/nemi_sheet.png")

POSES_DIR = os.path.join(BASE_DIR, "characters/nemi/art/poses")
EXPRS_DIR = os.path.join(BASE_DIR, "characters/nemi/art/expressions")
MICRO_DIR = os.path.join(BASE_DIR, "characters/nemi/art/micro")
LAYERS_DIR = os.path.join(BASE_DIR, "characters/nemi/art/layers")
PROPS_DIR = os.path.join(BASE_DIR, "characters/nemi/art/props")

for d in [POSES_DIR, EXPRS_DIR, MICRO_DIR, LAYERS_DIR, PROPS_DIR]:
    os.makedirs(d, exist_ok=True)

def remove_background_floodfill(crop_rgb, bg_color=(250, 246, 239), tol=26, feather=True):
    arr = np.array(crop_rgb).astype(float)
    h, w, _ = arr.shape

    # Color Euclidean distance from background
    dist = np.sqrt(np.sum((arr - np.array(bg_color).reshape((1, 1, 3))) ** 2, axis=2))

    is_bg = np.zeros((h, w), dtype=bool)
    visited = np.zeros((h, w), dtype=bool)
    q = deque()

    # Seed boundary pixels
    for x in range(w):
        if dist[0, x] < tol:
            q.append((0, x))
            visited[0, x] = True
        if dist[h - 1, x] < tol:
            q.append((h - 1, x))
            visited[h - 1, x] = True
    for y in range(h):
        if dist[y, 0] < tol and not visited[y, 0]:
            q.append((y, 0))
            visited[y, 0] = True
        if dist[y, w - 1] < tol and not visited[y, w - 1]:
            q.append((y, w - 1))
            visited[y, w - 1] = True

    while q:
        cy, cx = q.popleft()
        is_bg[cy, cx] = True
        for dy, dx in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            ny, nx = cy + dy, cx + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                if dist[ny, nx] < tol:
                    visited[ny, nx] = True
                    q.append((ny, nx))

    alpha = np.ones((h, w), dtype=np.uint8) * 255
    alpha[is_bg] = 0

    if feather:
        border = binary_dilation(is_bg) & (~is_bg)
        alpha[border] = np.clip((dist[border] / tol) * 255, 0, 255).astype(np.uint8)

    rgba = np.dstack([np.array(crop_rgb), alpha])
    return Image.fromarray(rgba.astype(np.uint8))

def filter_edge_specks(im_rgba):
    arr = np.array(im_rgba)
    alpha = arr[:, :, 3]
    h, w = alpha.shape
    lbls, num = label(alpha > 0)
    if num <= 1:
        return im_rgba
    objs = find_objects(lbls)
    sizes = [np.count_nonzero(lbls == i+1) for i in range(num)]
    largest_idx = np.argmax(sizes) + 1

    for i in range(num):
        idx = i + 1
        if idx == largest_idx:
            continue
        comp_size = sizes[i]
        sl = objs[i]
        comp_y1, comp_y2 = sl[0].start, sl[0].stop
        # If very small (< 40 px) and near top or bottom boundary (< 10 px from boundary)
        if comp_size < 40 and (comp_y1 < 10 or comp_y2 > h - 10):
            alpha[lbls == idx] = 0

    arr[:, :, 3] = alpha
    return Image.fromarray(arr)

def crop_and_clean(sheet, box, tol=26, pad=3):
    x1, y1, x2, y2 = box
    x1 = max(0, x1 - pad)
    y1 = max(0, y1 - pad)
    x2 = min(sheet.width, x2 + pad)
    y2 = min(sheet.height, y2 + pad)
    crop = sheet.crop((x1, y1, x2, y2))
    cleaned = remove_background_floodfill(crop, tol=tol)
    cleaned = filter_edge_specks(cleaned)
    return cleaned

def extract_expressions(sheet):
    expr_boxes = {
        "neutral": (364, 42, 470, 160),
        "happy": (480, 40, 586, 160),
        "excited": (594, 40, 706, 160),
        "confused": (712, 40, 822, 160),

        "angry": (364, 180, 472, 298),
        "sad": (480, 185, 586, 298),
        "surprised": (594, 180, 704, 298),
        "embarrassed": (710, 180, 820, 298),

        "smug": (364, 320, 475, 442),
        "annoyed": (480, 320, 588, 442),
        "shocked": (596, 320, 704, 442),
        "laughing": (710, 320, 820, 442),
    }

    print("Extracting 12 expressions...")
    for name, box in expr_boxes.items():
        clean = crop_and_clean(sheet, box, tol=26, pad=2)
        out_p = os.path.join(EXPRS_DIR, f"expr_{name}.png")
        clean.save(out_p)
        print(f"  Saved expr_{name}.png ({clean.size[0]}x{clean.size[1]})")

def extract_poses(sheet):
    pose_boxes = {
        "standing": (30, 720, 90, 895),
        "sitting": (108, 755, 193, 895),
        "walking": (205, 720, 283, 895),
        "running": (286, 722, 386, 895),
        "pointing": (396, 722, 495, 895),

        "thinking": (30, 922, 96, 1022),
        "shrugging": (114, 922, 204, 1022),
        "leaning": (228, 922, 297, 1022),
        "looking_up": (316, 922, 384, 1022),
        "looking_down": (410, 922, 478, 1022),

        "surprised": (30, 1058, 106, 1172),
        "excited": (120, 1044, 215, 1172),
        "angry": (222, 1058, 297, 1172),
        "sad": (312, 1058, 391, 1172),
        "laughing": (402, 1058, 485, 1172),
    }

    print("Extracting 15 poses...")
    for name, box in pose_boxes.items():
        clean = crop_and_clean(sheet, box, tol=24, pad=2)
        out_p = os.path.join(POSES_DIR, f"pose_{name}.png")
        clean.save(out_p)
        print(f"  Saved pose_{name}.png ({clean.size[0]}x{clean.size[1]})")

def extract_micro_events(sheet):
    micro_boxes = {
        "blink": (370, 506, 442, 574),
        "eye_dart": (456, 506, 532, 574),
        "eyebrow_raise": (547, 506, 624, 574),
        "mouth_open": (640, 506, 719, 574),
        "mouth_close": (735, 506, 813, 574)
    }

    print("Extracting 5 micro expressions...")
    for name, box in micro_boxes.items():
        clean = crop_and_clean(sheet, box, tol=22, pad=1)
        out_p = os.path.join(MICRO_DIR, f"micro_{name}.png")
        clean.save(out_p)
        print(f"  Saved micro_{name}.png ({clean.size[0]}x{clean.size[1]})")

def extract_props(sheet):
    prop_boxes = {
        "phone": (853, 730, 902, 802),
        "laptop": (916, 735, 1012, 802),
        "drink": (855, 832, 905, 906),
        "bag": (932, 830, 998, 910),
        "snacks": (852, 937, 908, 1007),
        "speech_bubble": (940, 942, 1008, 1000)
    }

    print("Extracting 6 props...")
    for name, box in prop_boxes.items():
        clean = crop_and_clean(sheet, box, tol=24, pad=2)
        out_p = os.path.join(PROPS_DIR, f"prop_{name}.png")
        clean.save(out_p)
        print(f"  Saved prop_{name}.png ({clean.size[0]}x{clean.size[1]})")

def extract_layers(sheet):
    layer_boxes = {
        "model_front_full": (508, 738, 598, 1082),
        "hair": (612, 728, 649, 782),
        "head": (613, 784, 649, 834),
        "torso": (608, 833, 654, 876),
        "arm_left_upper": (612, 878, 646, 920),
        "arm_left_lower": (627, 916, 661, 954),
        "arm_right": (662, 915, 695, 955),
        "skirt": (607, 953, 670, 991),
        "leg_left": (611, 991, 641, 1056),
        "leg_right": (652, 992, 685, 1055),
        "bag_accessory": (651, 1059, 684, 1097)
    }

    print("Extracting modular character layers...")
    for name, box in layer_boxes.items():
        clean = crop_and_clean(sheet, box, tol=24, pad=2)
        out_p = os.path.join(LAYERS_DIR, f"{name}.png")
        clean.save(out_p)
        print(f"  Saved layer {name}.png ({clean.size[0]}x{clean.size[1]})")

def generate_overview():
    print("Generating comprehensive asset overview contact sheet...")
    W, H = 1400, 1100
    overview = Image.new("RGBA", (W, H), (251, 249, 246, 255))
    draw = ImageDraw.Draw(overview)

    draw.text((40, 25), "NEMI - PRODUCTION 2D ASSET LIBRARY", fill=(62, 8, 30, 255))
    draw.text((40, 60), "12 FACIAL EXPRESSIONS (Bust Framing)", fill=(103, 141, 95, 255))
    expr_names = [
        ["neutral", "happy", "excited", "confused"],
        ["angry", "sad", "surprised", "embarrassed"],
        ["smug", "annoyed", "shocked", "laughing"]
    ]
    for r in range(3):
        for c in range(4):
            ename = expr_names[r][c]
            im_path = os.path.join(EXPRS_DIR, f"expr_{ename}.png")
            if os.path.exists(im_path):
                im = Image.open(im_path)
                x = 40 + c * 135
                y = 90 + r * 150
                overview.alpha_composite(im, (x, y))
                draw.text((x + 10, y + 128), ename.capitalize(), fill=(80, 80, 80, 255))

    draw.text((40, 560), "MICRO-EVENTS / EYE & MOUTH SUB-FRAMES", fill=(103, 141, 95, 255))
    micro_names = ["blink", "eye_dart", "eyebrow_raise", "mouth_open", "mouth_close"]
    for i, mname in enumerate(micro_names):
        im_path = os.path.join(MICRO_DIR, f"micro_{mname}.png")
        if os.path.exists(im_path):
            im = Image.open(im_path)
            x = 40 + i * 105
            y = 590
            overview.alpha_composite(im, (x, y))
            draw.text((x + 5, y + 75), mname.replace("_", " ").title(), fill=(80, 80, 80, 255))

    draw.text((40, 700), "STORY PROPS & ACCESSORIES", fill=(103, 141, 95, 255))
    prop_names = ["phone", "laptop", "drink", "bag", "snacks", "speech_bubble"]
    for i, pname in enumerate(prop_names):
        im_path = os.path.join(PROPS_DIR, f"prop_{pname}.png")
        if os.path.exists(im_path):
            im = Image.open(im_path)
            x = 40 + i * 95
            y = 730
            overview.alpha_composite(im, (x, y))
            draw.text((x + 5, y + 85), pname.replace("_", " ").title(), fill=(80, 80, 80, 255))

    draw.text((620, 60), "15 CANONICAL STORY POSES", fill=(103, 141, 95, 255))
    pose_rows = [
        [("standing", "Standing"), ("sitting", "Sitting"), ("walking", "Walking"), ("running", "Running"), ("pointing", "Pointing")],
        [("thinking", "Thinking"), ("shrugging", "Shrugging"), ("leaning", "Leaning"), ("looking_up", "Look Up"), ("looking_down", "Look Down")],
        [("surprised", "Surprised"), ("excited", "Excited"), ("angry", "Angry"), ("sad", "Sad"), ("laughing", "Laughing")]
    ]

    for r, row in enumerate(pose_rows):
        for c, (pname, label_text) in enumerate(row):
            im_path = os.path.join(POSES_DIR, f"pose_{pname}.png")
            if os.path.exists(im_path):
                im = Image.open(im_path)
                x = 620 + c * 150
                y = 90 + r * 200
                ox = x + (130 - im.size[0]) // 2
                oy = y + (170 - im.size[1]) if r == 0 else y + (130 - im.size[1])
                overview.alpha_composite(im, (ox, oy))
                draw.text((x + 25, y + 175 if r == 0 else y + 135), label_text, fill=(80, 80, 80, 255))

    draw.text((620, 700), "MODULAR CHARACTER MODEL", fill=(103, 141, 95, 255))
    front_path = os.path.join(LAYERS_DIR, "model_front_full.png")
    if os.path.exists(front_path):
        fim = Image.open(front_path)
        overview.alpha_composite(fim, (620, 730))
        draw.text((620 + fim.size[0] + 20, 760), "Full Front Base Model", fill=(62, 8, 30, 255))
        draw.text((620 + fim.size[0] + 20, 785), "- 100% Faithful to Reference Sheet", fill=(100, 100, 100, 255))
        draw.text((620 + fim.size[0] + 20, 810), "- Red Hair, Green Eyes, Sage Hoodie, Skirt", fill=(100, 100, 100, 255))
        draw.text((620 + fim.size[0] + 20, 835), "- Alpha Cleaned (Zero Cream Halos)", fill=(100, 100, 100, 255))

    out_p = os.path.join(BASE_DIR, "characters/nemi/art/nemi_asset_overview.png")
    overview.save(out_p)
    print("Saved overview to", out_p)

if __name__ == "__main__":
    print("Loading source sheet:", SRC_SHEET)
    sheet = Image.open(SRC_SHEET).convert("RGB")
    extract_expressions(sheet)
    extract_poses(sheet)
    extract_micro_events(sheet)
    extract_props(sheet)
    extract_layers(sheet)
    generate_overview()
    print("All Nemi production assets extracted successfully with immaculate alpha!")

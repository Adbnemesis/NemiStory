#!/usr/bin/env python3
"""
Contact Sheet Generator
Stitches rendered carousel slides into a single overview contact sheet (contact_sheet.png)
with slide numbers, brand indicators, and review metadata.
"""

import os
import sys
import glob
from PIL import Image, ImageDraw, ImageFont

def generate_contact_sheet(version_dir: str, brand: str = "nemi", title: str = "Carousel Overview") -> str:
    # 1. Locate all slide files (01.png, 02.png, ...)
    slide_files = sorted(glob.glob(os.path.join(version_dir, "[0-9][0-9].png")))
    if not slide_files:
        print(f"Warning: No slide PNGs found in {version_dir}")
        return ""
        
    num_slides = len(slide_files)
    
    # Grid layout:
    # 6 slides -> 3 cols x 2 rows
    # 7 slides -> 4 cols x 2 rows
    # 5 slides -> 5 cols x 1 row or 3x2
    cols = 4 if num_slides >= 5 else num_slides
    rows = (num_slides + cols - 1) // cols
    
    thumb_w = 270
    thumb_h = int(thumb_w * (1350 / 1080)) # 337
    
    pad_x = 24
    pad_y = 36
    top_header_h = 100
    bottom_pad = 30
    
    sheet_w = (cols * thumb_w) + ((cols + 1) * pad_x)
    sheet_h = top_header_h + (rows * thumb_h) + (rows * pad_y) + bottom_pad
    
    # Palette
    if brand.lower() == "nemi":
        bg_color = (253, 251, 247)
        card_border = (229, 218, 206)
        text_color = (43, 33, 24)
        accent_color = (194, 91, 58) # Terracotta
    else:
        bg_color = (15, 17, 23)
        card_border = (38, 45, 61)
        text_color = (235, 239, 245)
        accent_color = (78, 143, 242) # Electric Blue
        
    sheet = Image.new("RGBA", (sheet_w, sheet_h), bg_color)
    draw = ImageDraw.Draw(sheet)
    
    # Load default font or custom font if available
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 22)
        sub_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 13)
        num_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
    except Exception:
        title_font = ImageFont.load_default()
        sub_font = ImageFont.load_default()
        num_font = ImageFont.load_default()
        
    # Header Banner
    brand_tag = f"[{brand.upper()} CAROUSEL]"
    draw.text((pad_x, 22), brand_tag, fill=accent_color, font=sub_font)
    draw.text((pad_x, 40), title[:60] + ("..." if len(title) > 60 else ""), fill=text_color, font=title_font)
    draw.text((pad_x, 70), f"Sequence: {num_slides} Slides (1080x1350 4:5) • Native Godot Vector Engine • Zero AI Art", fill=text_color, font=sub_font)
    
    # Line below header
    draw.line([(pad_x, 92), (sheet_w - pad_x, 92)], fill=card_border, width=1)
    
    # Place thumbnails
    for idx, fpath in enumerate(slide_files):
        c = idx % cols
        r = idx // cols
        
        x = pad_x + c * (thumb_w + pad_x)
        y = top_header_h + r * (thumb_h + pad_y)
        
        try:
            with Image.open(fpath) as img:
                thumb = img.convert("RGBA").resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
                sheet.paste(thumb, (x, y))
                
                # Card border
                draw.rectangle([x - 1, y - 1, x + thumb_w, y + thumb_h], outline=card_border, width=1)
                
                # Slide number pill at top-left of slide
                pill_text = f"Slide {idx + 1:02d}"
                draw.rectangle([x + 6, y + 6, x + 64, y + 24], fill=(0, 0, 0, 180))
                draw.text((x + 12, y + 8), pill_text, fill=(255, 255, 255), font=num_font)
        except Exception as e:
            print(f"Error loading slide {fpath}: {e}")
            
    out_path = os.path.join(version_dir, "contact_sheet.png")
    sheet.convert("RGB").save(out_path, "PNG")
    print(f"✓ Generated contact sheet: {out_path} ({sheet_w}x{sheet_h})")
    return out_path

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 contact_sheet.py <version_dir> [brand] [title]")
        sys.exit(1)
    d = sys.argv[1]
    b = sys.argv[2] if len(sys.argv) > 2 else "nemi"
    t = sys.argv[3] if len(sys.argv) > 3 else "Carousel Contact Sheet"
    generate_contact_sheet(d, b, t)

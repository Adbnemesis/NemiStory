#!/usr/bin/env python3
"""
Master Carousel Registry Manager
Updates carousel/docs/CAROUSEL_REGISTRY.json whenever a carousel or new version is created.
"""

import os
import json
from datetime import datetime, timezone

def update_registry(
    registry_file: str,
    carousel_id: str,
    brand: str,
    title: str,
    topic: str,
    content_type: str,
    tone: str,
    version: str,
    status: str,
    output_path: str
) -> None:
    if not os.path.exists(registry_file):
        data = {
            "system": "NemiStory Automated Carousel Production Engine",
            "version": "1.0.0",
            "last_updated": datetime.now(timezone.utc).isoformat(),
            "carousels": []
        }
    else:
        with open(registry_file, "r", encoding="utf-8") as f:
            try:
                data = json.load(f)
            except Exception:
                data = {"carousels": []}

    carousels = data.get("carousels", [])
    
    # Check if entry already exists
    existing = None
    for c in carousels:
        if c.get("carousel_id") == carousel_id:
            existing = c
            break
            
    if existing:
        existing["latest_version"] = version
        existing["status"] = status
        existing["output_path"] = output_path
        existing["last_updated"] = datetime.now(timezone.utc).isoformat()
    else:
        carousels.append({
            "carousel_id": carousel_id,
            "brand": brand,
            "title": title,
            "topic": topic,
            "content_type": content_type,
            "tone": tone,
            "created_date": datetime.now(timezone.utc).isoformat(),
            "latest_version": version,
            "status": status,
            "output_path": output_path
        })
        
    data["carousels"] = carousels
    data["last_updated"] = datetime.now(timezone.utc).isoformat()
    
    with open(registry_file, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        
    print(f"✓ Updated master registry: {registry_file} (Carousel: {carousel_id}, Version: {version})")

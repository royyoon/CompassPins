#!/usr/bin/env python3
"""
Resize screenshot to iPad Pro 12.9" dimensions (2048 × 2732 px)
"""

from PIL import Image

def resize_to_ipad(input_path, output_path):
    """Resize image to iPad Pro 12.9" screenshot size"""

    target_width = 2048
    target_height = 2732

    # Open the image
    img = Image.open(input_path)

    print(f"Original size: {img.size[0]} × {img.size[1]} px")

    # Get original dimensions
    orig_width, orig_height = img.size
    orig_aspect = orig_width / orig_height
    target_aspect = target_width / target_height

    # Create white background at target size
    result = Image.new('RGB', (target_width, target_height), (255, 255, 255))

    # Calculate scaling to fit image in target while maintaining aspect ratio
    if orig_aspect > target_aspect:
        # Image is wider - fit to width
        new_width = target_width
        new_height = int(target_width / orig_aspect)
    else:
        # Image is taller - fit to height
        new_height = target_height
        new_width = int(target_height * orig_aspect)

    # Resize image
    img_resized = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

    # Center on white background
    x_offset = (target_width - new_width) // 2
    y_offset = (target_height - new_height) // 2

    result.paste(img_resized, (x_offset, y_offset))

    # Save
    result.save(output_path, quality=95)
    print(f"✅ Created iPad screenshot: {output_path}")
    print(f"   Size: {target_width} × {target_height} px")

if __name__ == "__main__":
    import sys

    # Check if we can find the screenshot
    input_file = "/var/folders/vt/p05gdwbn6tq9w0sc6v76hwsr0000gn/T/TemporaryItems/NSIRD_screencaptureui_gCt2Up/Screenshot 2026-10-27 at 1.18.50 AM.png"
    output_file = "/Users/royyoon/AdventureGuides/CompassPinsApp/screenshot-ipad-firesafety.png"

    try:
        resize_to_ipad(input_file, output_file)
    except FileNotFoundError:
        print(f"❌ Could not find screenshot at: {input_file}")
        print("\nPlease provide the screenshot path:")
        print("Usage: python3 resize-screenshot.py <input-screenshot.png>")
        if len(sys.argv) > 1:
            resize_to_ipad(sys.argv[1], output_file)

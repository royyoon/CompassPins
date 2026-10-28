#!/usr/bin/env python3
"""
Resize iPad screenshots to App Store required dimensions
Portrait: 2048 × 2732px (iPad Pro 12.9")
"""

from PIL import Image
import sys
import os

def resize_to_ipad_appstore(input_path, output_path):
    """Resize image to iPad App Store screenshot size"""

    target_width = 2048
    target_height = 2732

    # Open the image
    img = Image.open(input_path)

    print(f"📱 Processing: {os.path.basename(input_path)}")
    print(f"   Original size: {img.size[0]} × {img.size[1]} px")

    # Create canvas at exact target size with white background
    canvas = Image.new('RGB', (target_width, target_height), (255, 255, 255))

    # Get original dimensions
    orig_width, orig_height = img.size

    # Calculate aspect ratios
    orig_aspect = orig_width / orig_height
    target_aspect = target_width / target_height

    # Resize to fit within target dimensions while maintaining aspect ratio
    if orig_aspect > target_aspect:
        # Image is wider relative to target - fit to width
        new_width = target_width
        new_height = int(target_width / orig_aspect)
    else:
        # Image is taller relative to target - fit to height
        new_height = target_height
        new_width = int(target_height * orig_aspect)

    # Resize image with high-quality resampling
    img_resized = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

    # Center the resized image on canvas
    x_offset = (target_width - new_width) // 2
    y_offset = (target_height - new_height) // 2

    canvas.paste(img_resized, (x_offset, y_offset))

    # Save
    canvas.save(output_path, 'PNG', quality=95, optimize=True)

    print(f"   ✅ Saved: {os.path.basename(output_path)}")
    print(f"   Final size: {target_width} × {target_height} px")
    print()

if __name__ == "__main__":
    # The screenshots from the temp folder
    screenshots = [
        "/var/folders/vt/p05gdwbn6tq9w0sc6v76hwsr0000gn/T/TemporaryItems/NSIRD_screencaptureui_LuJcr5/Screenshot 2026-10-27 at 2.04.39 AM.png",
        "/var/folders/vt/p05gdwbn6tq9w0sc6v76hwsr0000gn/T/TemporaryItems/NSIRD_screencaptureui_LuJcr5/Screenshot 2026-10-27 at 2.04.46 AM.png"
    ]

    output_dir = "/Users/royyoon/AdventureGuides/CompassPinsApp/AppStore-Screenshots"

    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    output_files = [
        os.path.join(output_dir, "ipad-screenshot-1-knife-safety.png"),
        os.path.join(output_dir, "ipad-screenshot-2-walking-stick.png")
    ]

    print("🔄 Resizing iPad screenshots for App Store Connect\n")

    for i, (input_file, output_file) in enumerate(zip(screenshots, output_files), 1):
        try:
            resize_to_ipad_appstore(input_file, output_file)
        except FileNotFoundError:
            print(f"❌ Could not find: {input_file}")
            print("   File may have been moved from temp folder")
            print()

    print(f"📁 Screenshots saved to: {output_dir}")
    print(f"\n✅ Upload these files to App Store Connect")
    print(f"   Format: PNG")
    print(f"   Size: 2048 × 2732 px (Portrait)")

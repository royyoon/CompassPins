#!/usr/bin/env python3
from PIL import Image

def remove_transparency(image_path, output_path, bg_color=(255, 255, 255)):
    """Remove transparency from PNG image"""
    img = Image.open(image_path)
    
    # Create a new image with white background
    if img.mode in ('RGBA', 'LA'):
        # Create background
        background = Image.new('RGB', img.size, bg_color)
        # Paste image on background using alpha channel as mask
        background.paste(img, mask=img.split()[-1])
        background.save(output_path, 'PNG')
        print(f"Fixed: {output_path}")
    else:
        # Already opaque
        img.save(output_path, 'PNG')
        print(f"Already opaque: {output_path}")

# Fix the main icon
remove_transparency(
    '/Users/royyoon/AdventureGuides/CompassPinsApp/AppIcon.png',
    '/Users/royyoon/AdventureGuides/CompassPinsApp/AppIcon-Fixed.png',
    bg_color=(52, 73, 94)  # Dark blue-gray background
)

print("\n✅ Fixed icon created: AppIcon-Fixed.png")
print("Now drag this into Xcode Assets → AppIcon")

#!/usr/bin/env python3
"""
Create iPad screenshot from the Fire Safety pin detail image
Since we have the phone screenshot, we'll create an iPad-sized version
"""

from PIL import Image, ImageDraw

def create_ipad_screenshot_from_phone():
    """Create a mock iPad screenshot based on the phone UI we saw"""

    # iPad Pro 12.9" dimensions
    width = 2048
    height = 2732

    # Create dark background (matching the app's dark mode)
    img = Image.new('RGB', (width, height), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # For now, create a placeholder that shows the correct dimensions
    # The user should take an actual screenshot from iPad simulator

    # Draw centered text
    try:
        from PIL import ImageFont
        font_large = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 80)
        font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 50)
    except:
        font_large = ImageFont.load_default()
        font_small = ImageFont.load_default()

    # Title
    title = "iPad Screenshot Placeholder"
    bbox = draw.textbbox((0, 0), title, font=font_large)
    title_width = bbox[2] - bbox[0]
    draw.text((width//2 - title_width//2, height//2 - 200), title, fill=(200, 200, 200), font=font_large)

    # Size
    size_text = "2048 × 2732 px"
    bbox = draw.textbbox((0, 0), size_text, font=font_small)
    size_width = bbox[2] - bbox[0]
    draw.text((width//2 - size_width//2, height//2 - 50), size_text, fill=(150, 150, 150), font=font_small)

    # Instructions
    instructions = [
        "To create actual screenshot:",
        "1. Open Xcode",
        "2. Select iPad Pro (12.9-inch) simulator",
        "3. Run CompassPins app (Cmd+R)",
        "4. Navigate to Fire Safety pin",
        "5. Press Cmd+S to save screenshot"
    ]

    y = height//2 + 100
    for line in instructions:
        bbox = draw.textbbox((0, 0), line, font=font_small)
        line_width = bbox[2] - bbox[0]
        draw.text((width//2 - line_width//2, y), line, fill=(150, 150, 150), font=font_small)
        y += 80

    output_path = "/Users/royyoon/AdventureGuides/CompassPinsApp/screenshot-ipad-placeholder.png"
    img.save(output_path, quality=95)
    print(f"✅ Created iPad placeholder: {output_path}")
    print(f"   Size: {width} × {height} px")
    print("\n⚠️  This is a placeholder. You need to take actual screenshots from iPad simulator.")
    print("\nSteps:")
    print("1. Open CompassPins/CompassPins.xcodeproj in Xcode")
    print("2. Select 'iPad Pro (12.9-inch) (6th generation)' from device menu")
    print("3. Press Cmd+R to run")
    print("4. Navigate to screens and press Cmd+S")
    print("5. Screenshots save to ~/Desktop")

if __name__ == "__main__":
    create_ipad_screenshot_from_phone()

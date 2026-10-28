#!/usr/bin/env python3
"""
Create screenshot templates for App Store submission
Shows the required sizes and what content should be captured
"""

from PIL import Image, ImageDraw, ImageFont

def create_screenshot_template(width, height, device_name, output_path):
    """Create a template showing what to screenshot"""

    # Create white background
    img = Image.new('RGB', (width, height), (245, 245, 245))
    draw = ImageDraw.Draw(img)

    # Try to load font
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 60)
        text_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
    except:
        title_font = ImageFont.load_default()
        text_font = ImageFont.load_default()

    # Draw border
    draw.rectangle([(20, 20), (width-20, height-20)], outline=(200, 200, 200), width=4)

    # Title
    title = f"{device_name} Screenshot Template"
    bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = bbox[2] - bbox[0]
    draw.text((width//2 - title_width//2, 100), title, fill=(100, 100, 100), font=title_font)

    # Size info
    size_text = f"{width} × {height} px"
    bbox = draw.textbbox((0, 0), size_text, font=text_font)
    size_width = bbox[2] - bbox[0]
    draw.text((width//2 - size_width//2, 200), size_text, fill=(150, 150, 150), font=text_font)

    # Instructions
    instructions = [
        "Take screenshots of:",
        "",
        "1. Home screen with compass progress",
        "2. Journey detail (tap a journey card)",
        "3. Pin detail view with image",
        "",
        f"Run app on {device_name} simulator",
        "Press Cmd+S to capture screenshot"
    ]

    y = 400
    for line in instructions:
        bbox = draw.textbbox((0, 0), line, font=text_font)
        line_width = bbox[2] - bbox[0]
        draw.text((width//2 - line_width//2, y), line, fill=(100, 100, 100), font=text_font)
        y += 80

    img.save(output_path, quality=95)
    print(f"✅ Created template: {output_path}")

if __name__ == "__main__":
    # iPhone 6.7" (iPhone 15 Pro Max)
    create_screenshot_template(
        1290, 2796,
        "iPhone 15 Pro Max",
        "/Users/royyoon/AdventureGuides/CompassPinsApp/template-iphone.png"
    )

    # iPad 12.9" (iPad Pro 6th gen)
    create_screenshot_template(
        2048, 2732,
        "iPad Pro 12.9-inch",
        "/Users/royyoon/AdventureGuides/CompassPinsApp/template-ipad.png"
    )

    print("\n📱 Next steps:")
    print("1. Open CompassPins.xcodeproj in Xcode")
    print("2. Select iPhone 15 Pro Max simulator")
    print("3. Run app (Cmd+R) and take screenshots (Cmd+S)")
    print("4. Select iPad Pro (12.9-inch) simulator")
    print("5. Run app (Cmd+R) and take screenshots (Cmd+S)")
    print("\nScreenshots will be saved to ~/Desktop")

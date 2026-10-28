#!/usr/bin/env python3
"""
Create App Store screenshots for iPad (2048 × 2732px)
Based on the Knife Safety and Walking Stick pin views shown
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_ipad_screenshot(output_path, pin_name, journey_color, what_to_do, examples_text, bg_image_name):
    """Create an iPad screenshot matching the app UI"""

    # iPad Pro 12.9" portrait dimensions
    width = 2048
    height = 2732

    # Create white background
    img = Image.new('RGB', (width, height), (248, 248, 248))
    draw = ImageDraw.Draw(img)

    # Load fonts
    try:
        font_nav = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
        font_title = ImageFont.truetype("/System/Library/Fonts/SF-Pro-Display-Bold.ttf", 72)
        font_heading = ImageFont.truetype("/System/Library/Fonts/SF-Pro-Display-Semibold.ttf", 32)
        font_body = ImageFont.truetype("/System/Library/Fonts/SF-Pro-Text-Regular.ttf", 36)
        font_section = ImageFont.truetype("/System/Library/Fonts/SF-Pro-Display-Semibold.ttf", 28)
    except:
        # Fallback to Helvetica
        font_nav = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
        font_title = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 72)
        font_heading = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 32)
        font_body = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
        font_section = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)

    # Top navigation bar
    nav_y = 60
    nav_items = ["Home", "Pins", "Circle", "Expedition"]
    nav_spacing = 150
    start_x = width // 2 - (len(nav_items) * nav_spacing) // 2

    for i, item in enumerate(nav_items):
        color = (0, 122, 255) if item == "Pins" else (60, 60, 67)
        draw.text((start_x + i * nav_spacing, nav_y), item, fill=color, font=font_nav)

    # Left sidebar - "Pins"
    sidebar_x = 50
    sidebar_y = 250

    draw.text((sidebar_x, sidebar_y), "Pins", fill=(0, 0, 0), font=font_title)

    # Search box
    search_y = sidebar_y + 120
    search_box = [(sidebar_x, search_y), (400, search_y + 80)]
    draw.rounded_rectangle(search_box, radius=15, fill=(242, 242, 247))
    draw.text((sidebar_x + 60, search_y + 20), "Search all 26 pins", fill=(142, 142, 147), font=font_body)

    # Journey filter buttons
    button_y = search_y + 140
    journeys = [
        ("North\nFamily", (230, 230, 235)),
        ("East\nNature", (230, 230, 235)),
        ("South\nCommunity", (230, 230, 235))
    ]

    for i, (text, color) in enumerate(journeys):
        btn_x = sidebar_x + i * 140
        btn_box = [(btn_x, button_y), (btn_x + 120, button_y + 80)]
        draw.rounded_rectangle(btn_box, radius=15, fill=color)
        lines = text.split('\n')
        draw.text((btn_x + 10, button_y + 10), lines[0], fill=(0, 0, 0), font=font_section)
        draw.text((btn_x + 10, button_y + 45), lines[1], fill=(0, 0, 0), font=font_section)

    # Pin list items
    pin_list = [
        ("Stilts or Walking Stick", "Adult supervision"),
        ("Knife Safety", "Adult supervision"),
        ("Knots", "Adult partnership"),
        ("Fire Safety", "Adult supervision"),
        ("First Aid", "Adult supervision")
    ]

    list_y = button_y + 150
    for i, (name, supervision) in enumerate(pin_list):
        item_box = [(sidebar_x, list_y + i * 120), (450, list_y + i * 120 + 100)]

        # Highlight selected pin
        if name == pin_name:
            draw.rounded_rectangle(item_box, radius=12, fill=(255, 255, 255))
            draw.rounded_rectangle(item_box, radius=12, outline=(200, 200, 200), width=2)

        draw.text((sidebar_x + 20, list_y + i * 120 + 20), name, fill=(0, 0, 0), font=font_heading)
        draw.text((sidebar_x + 20, list_y + i * 120 + 60), f"⚠️ {supervision}",
                  fill=(255, 149, 0), font=font_section)

    # Right content area
    content_x = 550
    content_y = 200
    content_width = width - content_x - 100

    # Journey badge and title
    badge_size = 80
    draw.ellipse([content_x, content_y, content_x + badge_size, content_y + badge_size],
                 fill=journey_color)
    draw.text((content_x + 20, content_y + 20), "★", fill=(255, 255, 255), font=font_title)

    draw.text((content_x + 100, content_y + 5), "Fun", fill=(155, 89, 182), font=font_heading)
    draw.text((content_x + 100, content_y + 45), pin_name, fill=(0, 0, 0), font=font_title)

    # Warning box
    warning_y = content_y + 140
    warning_box = [(content_x, warning_y), (content_x + content_width, warning_y + 120)]
    draw.rounded_rectangle(warning_box, radius=15, fill=(255, 248, 230))
    draw.text((content_x + 60, warning_y + 20), "⚠️ Adult supervision required",
              fill=(0, 0, 0), font=font_heading)
    draw.text((content_x + 60, warning_y + 60),
              "Done as a parent-child demonstration. Never an unsupervised activity.",
              fill=(100, 100, 100), font=font_section)

    # "What to do" section
    what_y = warning_y + 180
    draw.text((content_x, what_y), "WHAT TO DO", fill=(142, 142, 147), font=font_section)
    draw.text((content_x, what_y + 50), what_to_do, fill=(0, 0, 0), font=font_body)

    # "Examples & Ideas" section
    examples_y = what_y + 150
    draw.text((content_x, examples_y), "💡 EXAMPLES & IDEAS", fill=(175, 82, 222), font=font_heading)

    examples_box = [(content_x, examples_y + 60), (content_x + content_width, examples_y + 400)]
    draw.rounded_rectangle(examples_box, radius=15, fill=(250, 240, 255))

    # Draw examples text
    y_offset = examples_y + 90
    for line in examples_text.split('\n'):
        draw.text((content_x + 40, y_offset), line, fill=(0, 0, 0), font=font_body)
        y_offset += 50

    # "Visual Guide" section
    visual_y = examples_y + 480
    draw.text((content_x, visual_y), "🖼️ VISUAL GUIDE", fill=(175, 82, 222), font=font_heading)

    # Load pin image if available
    try:
        pin_img_path = f"/Users/royyoon/AdventureGuides/CompassPinsApp/pin-images/West/{bg_image_name}.png"
        if os.path.exists(pin_img_path):
            pin_img = Image.open(pin_img_path)
            # Resize to fit
            max_img_width = content_width
            max_img_height = 600
            pin_img.thumbnail((max_img_width, max_img_height), Image.Resampling.LANCZOS)

            # Paste centered
            img_x = content_x + (content_width - pin_img.width) // 2
            img_y = visual_y + 80

            # Add background
            img_bg = [(content_x, img_y - 20), (content_x + content_width, img_y + pin_img.height + 20)]
            draw.rounded_rectangle(img_bg, radius=15, fill=(245, 245, 255))

            img.paste(pin_img, (img_x, img_y), pin_img if pin_img.mode == 'RGBA' else None)
    except:
        # Draw placeholder
        img_box = [(content_x, visual_y + 60), (content_x + content_width, visual_y + 500)]
        draw.rounded_rectangle(img_box, radius=15, fill=(230, 240, 255))
        draw.text((content_x + 200, visual_y + 250), f"{bg_image_name} Image",
                  fill=(100, 100, 100), font=font_heading)

    # Save
    img.save(output_path, 'PNG', quality=95, optimize=True)
    print(f"✅ Created: {os.path.basename(output_path)} ({width}×{height}px)")

if __name__ == "__main__":
    output_dir = "/Users/royyoon/AdventureGuides/CompassPinsApp/AppStore-Screenshots"
    os.makedirs(output_dir, exist_ok=True)

    print("🎨 Creating iPad App Store screenshots (2048 × 2732px)\n")

    # Screenshot 1: Knife Safety
    create_ipad_screenshot(
        os.path.join(output_dir, "ipad-01-knife-safety.png"),
        "Knife Safety",
        (155, 89, 182),  # Purple for Fun/West
        "Demonstrate safe knife handling. Carve or whittle an object together with your adult. Present it to your Circle.",
        "Safety rules:\n• Always cut AWAY from yourself\n• Keep blade sharp (dull = dangerous)\n• Close when not in use\n• Create safety circle (arm's length)\n\nFirst projects: Tent stake, butter knife, whistle",
        "KnifeSafety"
    )

    # Screenshot 2: Walking Stick
    create_ipad_screenshot(
        os.path.join(output_dir, "ipad-02-walking-stick.png"),
        "Stilts or Walking Stick",
        (155, 89, 182),  # Purple for Fun/West
        "Build stilts or a walking stick with adult supervision.",
        "Walking stick:\n• Find sturdy branch (your height + 6\")\n• Remove bark\n• Sand smooth\n• Carve designs or paint\n• Add wrist strap\n• Seal with varnish",
        "WalkingStick"
    )

    print(f"\n📁 Screenshots saved to: {output_dir}")
    print("\n✅ Upload these to App Store Connect:")
    print("   Device: iPad Pro (12.9-inch)")
    print("   Size: 2048 × 2732 px")

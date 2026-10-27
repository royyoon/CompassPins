#!/usr/bin/env python3
"""
Create App Store header asset for CompassPins
Size: 5244 × 2950px (or 3840 × 1646px)
"""

from PIL import Image, ImageDraw, ImageFont
import math

def create_compass_needle(draw, center_x, center_y, angle, length, color, width=15):
    """Draw a compass needle pointing in a specific direction"""
    angle_rad = math.radians(angle)

    # End point of needle
    end_x = center_x + length * math.sin(angle_rad)
    end_y = center_y - length * math.cos(angle_rad)

    # Draw thick line
    draw.line([(center_x, center_y), (end_x, end_y)], fill=color, width=width)

    # Draw arrowhead
    arrow_size = 25
    arrow_angle = 25

    left_angle = angle_rad - math.radians(arrow_angle)
    right_angle = angle_rad + math.radians(arrow_angle)

    left_x = end_x - arrow_size * math.sin(left_angle)
    left_y = end_y + arrow_size * math.cos(left_angle)
    right_x = end_x - arrow_size * math.sin(right_angle)
    right_y = end_y + arrow_size * math.cos(right_angle)

    draw.polygon([(end_x, end_y), (left_x, left_y), (right_x, right_y)], fill=color)

def create_header_asset(output_path, width=5244, height=2950):
    """Create the App Store header asset"""

    # Background color - dark blue gradient
    img = Image.new('RGB', (width, height), (52, 73, 94))
    draw = ImageDraw.Draw(img)

    # Draw gradient background
    for y in range(height):
        ratio = y / height
        r = int(52 + (41 - 52) * ratio)
        g = int(73 + (128 - 73) * ratio)
        b = int(94 + (185 - 94) * ratio)
        draw.rectangle([(0, y), (width, y + 1)], fill=(r, g, b))

    # Draw compass in center-left
    compass_x = width // 3
    compass_y = height // 2
    compass_radius = min(width, height) // 4

    # Outer circle
    circle_bbox = [
        compass_x - compass_radius,
        compass_y - compass_radius,
        compass_x + compass_radius,
        compass_y + compass_radius
    ]
    draw.ellipse(circle_bbox, outline=(255, 255, 255, 200), width=8)

    # Inner circle
    inner_radius = compass_radius // 8
    inner_bbox = [
        compass_x - inner_radius,
        compass_y - inner_radius,
        compass_x + inner_radius,
        compass_y + inner_radius
    ]
    draw.ellipse(inner_bbox, fill=(255, 255, 255), outline=None)

    # Journey colors
    north_color = (74, 144, 226)   # Blue
    east_color = (46, 204, 113)    # Green
    south_color = (230, 126, 34)   # Orange
    west_color = (155, 89, 182)    # Purple

    # Draw compass needles
    needle_length = compass_radius * 0.85
    create_compass_needle(draw, compass_x, compass_y, 0, needle_length, north_color, width=20)    # North
    create_compass_needle(draw, compass_x, compass_y, 90, needle_length, east_color, width=20)   # East
    create_compass_needle(draw, compass_x, compass_y, 180, needle_length, south_color, width=20) # South
    create_compass_needle(draw, compass_x, compass_y, 270, needle_length, west_color, width=20)  # West

    # Try to load a font, fallback to default
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 300)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 120)
        tagline_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 100)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        tagline_font = ImageFont.load_default()

    # Text on right side
    text_x = width * 2 // 3

    # App name
    title = "CompassPins"
    bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = bbox[2] - bbox[0]
    draw.text((text_x - title_width // 2, height // 2 - 400), title,
              fill=(255, 255, 255), font=title_font)

    # Tagline
    tagline = "Track Your Adventure Guides Journey"
    bbox = draw.textbbox((0, 0), tagline, font=tagline_font)
    tagline_width = bbox[2] - bbox[0]
    draw.text((text_x - tagline_width // 2, height // 2 - 50), tagline,
              fill=(200, 220, 240), font=tagline_font)

    # Journey labels
    journey_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 80) if title_font != ImageFont.load_default() else ImageFont.load_default()

    journeys = [
        ("North • Family", north_color, height // 2 + 150),
        ("East • Nature", east_color, height // 2 + 270),
        ("South • Community", south_color, height // 2 + 390),
        ("West • Fun", west_color, height // 2 + 510)
    ]

    for text, color, y_pos in journeys:
        bbox = draw.textbbox((0, 0), text, font=journey_font)
        text_width = bbox[2] - bbox[0]

        # Draw colored circle
        circle_size = 30
        draw.ellipse([
            text_x - text_width // 2 - circle_size - 20,
            y_pos + 15,
            text_x - text_width // 2 - 20,
            y_pos + 15 + circle_size
        ], fill=color)

        # Draw text
        draw.text((text_x - text_width // 2, y_pos), text,
                  fill=(255, 255, 255), font=journey_font)

    # Save
    img.save(output_path, quality=95)
    print(f"✅ Created header asset: {output_path}")
    print(f"   Size: {width} × {height}px")

if __name__ == "__main__":
    # Create large header (5244 × 2950)
    create_header_asset("/Users/royyoon/AdventureGuides/CompassPinsApp/header-large.png", 5244, 2950)

    # Create smaller header (3840 × 1646)
    create_header_asset("/Users/royyoon/AdventureGuides/CompassPinsApp/header-small.png", 3840, 1646)

    print("\n📱 Upload either file to App Store Connect under 'Header and Search Results'")

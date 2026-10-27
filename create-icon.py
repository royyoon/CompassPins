#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import math

def create_compass_icon(size):
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors matching the journeys
    bg_color = (52, 73, 94)  # Dark blue-gray
    compass_color = (236, 240, 241)  # Off-white
    north_color = (52, 152, 219)  # Blue (Family)
    east_color = (46, 204, 113)  # Green (Nature)
    south_color = (230, 126, 34)  # Orange (Community)
    west_color = (155, 89, 182)  # Purple (Fun)
    
    center = size // 2
    radius = int(size * 0.4)
    
    # Draw circular background
    padding = int(size * 0.05)
    draw.ellipse([padding, padding, size-padding, size-padding], fill=bg_color)
    
    # Draw compass circle
    circle_radius = int(radius * 0.9)
    draw.ellipse([center-circle_radius, center-circle_radius, 
                  center+circle_radius, center+circle_radius], 
                 outline=compass_color, width=int(size*0.02))
    
    # Draw compass needles (North, East, South, West)
    needle_length = int(radius * 0.75)
    needle_width = int(size * 0.08)
    
    # North (Blue) - pointing up
    points_n = [
        (center, center - needle_length),  # tip
        (center - needle_width, center),    # left
        (center + needle_width, center)     # right
    ]
    draw.polygon(points_n, fill=north_color)
    
    # South (Orange) - pointing down
    points_s = [
        (center, center + needle_length),   # tip
        (center - needle_width, center),    # left
        (center + needle_width, center)     # right
    ]
    draw.polygon(points_s, fill=south_color)
    
    # East (Green) - pointing right
    points_e = [
        (center + needle_length, center),   # tip
        (center, center - needle_width),    # top
        (center, center + needle_width)     # bottom
    ]
    draw.polygon(points_e, fill=east_color)
    
    # West (Purple) - pointing left
    points_w = [
        (center - needle_length, center),   # tip
        (center, center - needle_width),    # top
        (center, center + needle_width)     # bottom
    ]
    draw.polygon(points_w, fill=west_color)
    
    # Draw center circle
    center_radius = int(size * 0.06)
    draw.ellipse([center-center_radius, center-center_radius,
                  center+center_radius, center+center_radius],
                 fill=compass_color)
    
    return img

# Create 1024x1024 icon for App Store
icon = create_compass_icon(1024)
icon.save('/Users/royyoon/AdventureGuides/CompassPinsApp/AppIcon.png')
print("Created AppIcon.png (1024x1024)")

# Create different sizes for iOS
sizes = {
    '20': 20, '40': 40, '60': 60,
    '29': 29, '58': 58, '87': 87,
    '40': 40, '80': 80, '120': 120,
    '76': 76, '152': 152, '167': 167,
    '1024': 1024
}

import os
output_dir = '/Users/royyoon/AdventureGuides/CompassPinsApp/AppIconSet'
os.makedirs(output_dir, exist_ok=True)

for name, size in sizes.items():
    icon_sized = create_compass_icon(size)
    icon_sized.save(f'{output_dir}/icon_{size}x{size}.png')
    print(f"Created icon_{size}x{size}.png")

print(f"\n✅ All icons created in {output_dir}")

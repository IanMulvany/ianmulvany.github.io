#!/usr/bin/env python3
"""
Generate thumbnail and medium-sized versions of all JPEG images
"""
# /// script
# dependencies = [
#   "pillow",
# ]
# ///

from PIL import Image
import os
import sys
import glob
from pathlib import Path

# Configuration
THUMB_SIZE = (200, 200)  # Max width/height for thumbnails (smaller for faster loading)
MEDIUM_SIZE = (1200, 1200)  # Max width/height for medium images
QUALITY = 80  # JPEG quality (0-100)

def create_directories(source_dir):
    """Create output directories if they don't exist"""
    thumb_dir = os.path.join(source_dir, "thumbs")
    medium_dir = os.path.join(source_dir, "medium")

    os.makedirs(thumb_dir, exist_ok=True)
    os.makedirs(medium_dir, exist_ok=True)

    return thumb_dir, medium_dir

def find_images(source_dir):
    """Find all JPEG images in the source directory (not in subdirectories)"""
    patterns = ["*.jpg", "*.jpeg", "*.JPG", "*.JPEG"]
    files = []

    for pattern in patterns:
        files.extend(glob.glob(os.path.join(source_dir, pattern)))

    # Filter out files that are in subdirectories
    files = [f for f in files if os.path.dirname(f) == source_dir]

    return sorted(files)

def resize_image(input_path, output_path, max_size, quality=QUALITY):
    """Resize an image while maintaining aspect ratio"""
    try:
        with Image.open(input_path) as img:
            # Convert RGBA to RGB if needed
            if img.mode in ('RGBA', 'LA', 'P'):
                background = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'P':
                    img = img.convert('RGBA')
                background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')

            # Calculate new size maintaining aspect ratio
            img.thumbnail(max_size, Image.Resampling.LANCZOS)

            # Save with optimization
            img.save(output_path, 'JPEG', quality=quality, optimize=True)

        return True
    except Exception as e:
        print(f"  ✗ Error: {str(e)}")
        return False

def process_images(source_dir):
    """Process all images and create resized versions"""
    thumb_dir, medium_dir = create_directories(source_dir)
    images = find_images(source_dir)

    if not images:
        print(f"No JPEG images found in directory: {source_dir}")
        return

    print(f"Processing images in: {source_dir}")
    print(f"Found {len(images)} image(s) to process\n")

    processed = 0
    skipped = 0
    failed = 0

    for idx, image_path in enumerate(images, 1):
        filename = os.path.basename(image_path)
        print(f"[{idx}/{len(images)}] Processing {filename}...")

        thumb_path = os.path.join(thumb_dir, filename)
        medium_path = os.path.join(medium_dir, filename)

        # Check if both versions already exist
        if os.path.exists(thumb_path) and os.path.exists(medium_path):
            print(f"  ⊘ Already processed, skipping\n")
            skipped += 1
            continue

        # Generate thumbnail
        if not os.path.exists(thumb_path):
            print(f"  Creating thumbnail...")
            if not resize_image(image_path, thumb_path, THUMB_SIZE):
                failed += 1
                continue
            thumb_size = os.path.getsize(thumb_path) / 1024
            print(f"    ✓ Thumbnail created ({thumb_size:.1f} KB)")
        else:
            print(f"  ⊘ Thumbnail exists")

        # Generate medium version
        if not os.path.exists(medium_path):
            print(f"  Creating medium version...")
            if not resize_image(image_path, medium_path, MEDIUM_SIZE):
                failed += 1
                continue
            medium_size = os.path.getsize(medium_path) / 1024
            print(f"    ✓ Medium created ({medium_size:.1f} KB)")
        else:
            print(f"  ⊘ Medium exists")

        print()
        processed += 1

    print(f"="*60)
    print(f"Summary:")
    print(f"  - Processed: {processed}")
    print(f"  - Skipped (already exists): {skipped}")
    print(f"  - Failed: {failed}")
    print(f"  - Total: {len(images)}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python generate_resized_images.py <directory_path>")
        print("Example: python generate_resized_images.py /path/to/images/2025-ff-cologne")
        sys.exit(1)

    source_dir = os.path.abspath(sys.argv[1])

    if not os.path.isdir(source_dir):
        print(f"Error: '{source_dir}' is not a valid directory")
        sys.exit(1)

    process_images(source_dir)

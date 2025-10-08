#!/usr/bin/env python3
"""
Gallery Generator Script
Generates photo gallery index pages and master gallery page based on gallery-config.md
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple


class GalleryConfig:
    """Parse and store gallery configuration"""

    def __init__(self, config_path: str):
        self.config_path = config_path
        self.galleries = self._parse_config()

    def _parse_config(self) -> List[Dict[str, str]]:
        """Parse the gallery-config.md file"""
        galleries = []

        with open(self.config_path, 'r') as f:
            content = f.read()

        # Extract the configuration section between ```
        config_pattern = r'## Configuration\s*```\s*(.*?)\s*```'
        match = re.search(config_pattern, content, re.DOTALL)

        if not match:
            return galleries

        config_text = match.group(1)

        # Parse each line: directory: profile_image: title: location: year
        for line in config_text.strip().split('\n'):
            if ':' not in line:
                continue

            parts = [p.strip() for p in line.split(':')]

            if len(parts) >= 2:
                directory = parts[0]
                profile_image = parts[1] if len(parts) > 1 else ''
                title = parts[2] if len(parts) > 2 else directory
                location = parts[3] if len(parts) > 3 else 'Germany'
                year = parts[4] if len(parts) > 4 else self._extract_year(directory)

                galleries.append({
                    'directory': directory,
                    'profile_image': profile_image,
                    'title': title,
                    'location': location,
                    'year': year
                })

        return galleries

    def _extract_year(self, directory: str) -> str:
        """Extract year from directory name (e.g., 2025-ff-cologne -> 2025)"""
        year_match = re.match(r'(\d{4})', directory)
        return year_match.group(1) if year_match else '2025'


class GalleryGenerator:
    """Generate gallery HTML pages"""

    def __init__(self, base_path: str):
        self.base_path = Path(base_path)

    def get_image_files(self, directory: str) -> List[str]:
        """Get all image files in a directory"""
        gallery_path = self.base_path / directory
        if not gallery_path.exists():
            return []

        image_extensions = {'.jpg', '.jpeg', '.png', '.gif', '.JPG', '.JPEG', '.PNG', '.GIF'}
        images = []

        for file in gallery_path.iterdir():
            if file.is_file() and file.suffix in image_extensions:
                images.append(file.name)

        return sorted(images)

    def generate_gallery_page(self, gallery: Dict[str, str]) -> str:
        """Generate individual gallery index.html"""
        directory = gallery['directory']
        title = gallery['title']
        year = gallery['year']

        images = self.get_image_files(directory)

        if not images:
            print(f"Warning: No images found in {directory}")
            return ""

        # Generate JavaScript array of image filenames
        image_list = ',\n            '.join([f"'{img}'" for img in images])

        # Extract base name for CDN URL
        cdn_base = f"https://cdn.mulvany.net/{directory}/"

        html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} Gallery</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #0a0a0a;
            color: #fff;
            line-height: 1.6;
        }}

        header {{
            text-align: center;
            padding: 3rem 2rem;
            background: linear-gradient(135deg, #1a1a1a 0%, #0a0a0a 100%);
        }}

        h1 {{
            font-size: 2.5rem;
            font-weight: 300;
            margin-bottom: 1rem;
            letter-spacing: 2px;
        }}

        .download-btn {{
            display: inline-block;
            margin-top: 1rem;
            padding: 0.75rem 2rem;
            background: #fff;
            color: #0a0a0a;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 500;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(255, 255, 255, 0.1);
        }}

        .download-btn:hover {{
            transform: translateY(-2px);
            box-shadow: 0 6px 25px rgba(255, 255, 255, 0.2);
        }}

        .gallery {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
            padding: 2rem;
            max-width: 1400px;
            margin: 0 auto;
        }}

        .gallery-item {{
            position: relative;
            overflow: hidden;
            border-radius: 8px;
            cursor: pointer;
            aspect-ratio: 3/2;
            background: #1a1a1a;
        }}

        .gallery-item img {{
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s ease;
        }}

        .gallery-item:hover img {{
            transform: scale(1.05);
        }}

        .lightbox {{
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.95);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }}

        .lightbox.active {{
            display: flex;
        }}

        .lightbox-content {{
            max-width: 90%;
            max-height: 90%;
            position: relative;
        }}

        .lightbox-content img {{
            max-width: 100%;
            max-height: 90vh;
            object-fit: contain;
        }}

        .lightbox-close {{
            position: absolute;
            top: 2rem;
            right: 2rem;
            font-size: 3rem;
            color: #fff;
            cursor: pointer;
            background: none;
            border: none;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.3s ease;
        }}

        .lightbox-close:hover {{
            background: rgba(255, 255, 255, 0.1);
        }}

        .lightbox-nav {{
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            font-size: 3rem;
            color: #fff;
            cursor: pointer;
            background: rgba(255, 255, 255, 0.1);
            border: none;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }}

        .lightbox-nav:hover {{
            background: rgba(255, 255, 255, 0.2);
        }}

        .lightbox-prev {{
            left: 2rem;
        }}

        .lightbox-next {{
            right: 2rem;
        }}

        .lightbox-download {{
            position: absolute;
            bottom: 2rem;
            left: 50%;
            transform: translateX(-50%);
            padding: 0.75rem 2rem;
            background: #fff;
            color: #0a0a0a;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 500;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(255, 255, 255, 0.1);
            font-size: 0.9rem;
        }}

        .lightbox-download:hover {{
            transform: translateX(-50%) translateY(-2px);
            box-shadow: 0 6px 25px rgba(255, 255, 255, 0.2);
        }}

        .slideshow-btn {{
            position: absolute;
            bottom: 2rem;
            right: 2rem;
            padding: 0.75rem 1.5rem;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            border: 2px solid #fff;
            border-radius: 50px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.9rem;
            backdrop-filter: blur(10px);
        }}

        .slideshow-btn:hover {{
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-2px);
        }}

        .slideshow-btn.playing {{
            background: #fff;
            color: #0a0a0a;
        }}

        .load-more-container {{
            text-align: center;
            padding: 2rem;
        }}

        .load-more-btn {{
            display: inline-block;
            padding: 1rem 3rem;
            background: #fff;
            color: #0a0a0a;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(255, 255, 255, 0.1);
            font-size: 1rem;
        }}

        .load-more-btn:hover {{
            transform: translateY(-2px);
            box-shadow: 0 6px 25px rgba(255, 255, 255, 0.2);
        }}

        .load-more-btn:disabled {{
            opacity: 0.5;
            cursor: not-allowed;
        }}

        .loader {{
            border: 3px solid #333;
            border-top: 3px solid #fff;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }}

        @keyframes spin {{
            0% {{ transform: rotate(0deg); }}
            100% {{ transform: rotate(360deg); }}
        }}

        footer {{
            text-align: center;
            padding: 2rem;
            color: #666;
            font-size: 0.9rem;
        }}

        @media (max-width: 768px) {{
            .gallery {{
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                gap: 1rem;
                padding: 1rem;
            }}

            h1 {{
                font-size: 1.8rem;
            }}

            .lightbox-nav {{
                width: 45px;
                height: 45px;
                font-size: 2rem;
            }}

            .lightbox-prev {{
                left: 1rem;
            }}

            .lightbox-next {{
                right: 1rem;
            }}

            .lightbox-close {{
                top: 1rem;
                right: 1rem;
                width: 40px;
                height: 40px;
                font-size: 2rem;
            }}

            .lightbox-download {{
                bottom: 1rem;
                left: 1rem;
                transform: none;
                padding: 0.6rem 1.2rem;
                font-size: 0.85rem;
            }}

            .lightbox-download:hover {{
                transform: translateY(-2px);
            }}

            .slideshow-btn {{
                bottom: 1rem;
                right: 1rem;
                padding: 0.6rem 1.2rem;
                font-size: 0.85rem;
            }}
        }}
    </style>
</head>
<body>
    <header>
        <h1>{title}</h1>
        <p>Fotogalerie</p>
        <a href="{cdn_base}{directory}-images.zip" class="download-btn" download>Alle Bilder herunterladen</a>
    </header>

    <div class="gallery" id="gallery"></div>

    <div class="load-more-container" id="load-more-container">
        <div class="loader"></div>
    </div>

    <div class="lightbox" id="lightbox">
        <button class="lightbox-close" onclick="closeLightbox()">&times;</button>
        <button class="lightbox-nav lightbox-prev" onclick="changeImage(-1)">&#8249;</button>
        <div class="lightbox-content">
            <img id="lightbox-img" src="" alt="">
        </div>
        <button class="lightbox-nav lightbox-next" onclick="changeImage(1)">&#8250;</button>
        <a id="lightbox-download" class="lightbox-download" href="" download>Herunterladen</a>
        <button id="slideshow-btn" class="slideshow-btn" onclick="toggleSlideshow()">Diashow abspielen</button>
    </div>

    <footer>
        <p>&copy; {year} {title} Gallery</p>
    </footer>

    <script>
        const cdnBase = '{cdn_base}';
        const imageFiles = [
            {image_list}
        ];

        // Create paths for different sizes
        const images = {{
            thumbs: imageFiles.map(file => cdnBase + 'thumbs/' + file),
            medium: imageFiles.map(file => cdnBase + 'medium/' + file),
            full: imageFiles.map(file => cdnBase + file)
        }};

        let currentImageIndex = 0;
        let loadedCount = 0;
        const IMAGES_PER_LOAD = 24; // Load 24 images at a time
        let isLoading = false;
        let slideshowInterval = null;
        let isSlideshowPlaying = false;

        // Generate gallery progressively
        const gallery = document.getElementById('gallery');
        const loadMoreContainer = document.getElementById('load-more-container');

        function loadMoreImages() {{
            if (isLoading || loadedCount >= images.thumbs.length) return;

            isLoading = true;
            loadMoreContainer.style.display = 'block';

            // Simulate slight delay for UX (optional)
            setTimeout(() => {{
                const endIndex = Math.min(loadedCount + IMAGES_PER_LOAD, images.thumbs.length);

                for (let index = loadedCount; index < endIndex; index++) {{
                    const item = document.createElement('div');
                    item.className = 'gallery-item';
                    item.onclick = () => openLightbox(index);

                    const imgElement = document.createElement('img');
                    imgElement.src = images.thumbs[index];
                    imgElement.alt = `Photo ${{index + 1}}`;
                    imgElement.loading = 'lazy';

                    item.appendChild(imgElement);
                    gallery.appendChild(item);
                }}

                loadedCount = endIndex;
                isLoading = false;

                // Hide loader if all images loaded
                if (loadedCount >= images.thumbs.length) {{
                    loadMoreContainer.style.display = 'none';
                }}
            }}, 100);
        }}

        // Intersection Observer for infinite scroll
        const observer = new IntersectionObserver((entries) => {{
            entries.forEach(entry => {{
                if (entry.isIntersecting && !isLoading) {{
                    loadMoreImages();
                }}
            }});
        }}, {{
            rootMargin: '200px' // Load more when user is 200px from the bottom
        }});

        // Start observing the load more container
        observer.observe(loadMoreContainer);

        // Load initial batch
        loadMoreImages();

        function openLightbox(index) {{
            currentImageIndex = index;
            document.getElementById('lightbox-img').src = images.medium[index];
            document.getElementById('lightbox-download').href = images.full[index];
            document.getElementById('lightbox').classList.add('active');
            document.body.style.overflow = 'hidden';
        }}

        function closeLightbox() {{
            stopSlideshow();
            document.getElementById('lightbox').classList.remove('active');
            document.body.style.overflow = 'auto';
        }}

        function changeImage(direction) {{
            currentImageIndex += direction;
            if (currentImageIndex < 0) currentImageIndex = images.medium.length - 1;
            if (currentImageIndex >= images.medium.length) currentImageIndex = 0;
            document.getElementById('lightbox-img').src = images.medium[currentImageIndex];
            document.getElementById('lightbox-download').href = images.full[currentImageIndex];
        }}

        function toggleSlideshow() {{
            if (isSlideshowPlaying) {{
                stopSlideshow();
            }} else {{
                startSlideshow();
            }}
        }}

        function startSlideshow() {{
            isSlideshowPlaying = true;
            const btn = document.getElementById('slideshow-btn');
            btn.textContent = 'Diashow stoppen';
            btn.classList.add('playing');

            slideshowInterval = setInterval(() => {{
                changeImage(1);
            }}, 2000); // Change image every 2 seconds
        }}

        function stopSlideshow() {{
            if (slideshowInterval) {{
                clearInterval(slideshowInterval);
                slideshowInterval = null;
            }}
            isSlideshowPlaying = false;
            const btn = document.getElementById('slideshow-btn');
            btn.textContent = 'Diashow abspielen';
            btn.classList.remove('playing');
        }}

        // Keyboard navigation
        document.addEventListener('keydown', (e) => {{
            if (document.getElementById('lightbox').classList.contains('active')) {{
                if (e.key === 'Escape') closeLightbox();
                if (e.key === 'ArrowLeft') {{
                    stopSlideshow();
                    changeImage(-1);
                }}
                if (e.key === 'ArrowRight') {{
                    stopSlideshow();
                    changeImage(1);
                }}
                if (e.key === ' ') {{
                    e.preventDefault();
                    toggleSlideshow();
                }}
            }}
        }});

        // Close lightbox on background click
        document.getElementById('lightbox').addEventListener('click', (e) => {{
            if (e.target.id === 'lightbox') closeLightbox();
        }});
    </script>
</body>
</html>
'''
        return html

    def generate_master_page(self, galleries: List[Dict[str, str]]) -> str:
        """Generate master-gallery.html"""

        gallery_links = []

        for gallery in galleries:
            directory = gallery['directory']
            title = gallery['title']
            location = gallery['location']
            year = gallery['year']
            profile_image = gallery['profile_image']

            # Count images
            images = self.get_image_files(directory)
            image_count = len(images)

            if image_count > 0:
                status_badge = f'<span class="status-badge available">{image_count} photos</span>'
                # Use profile image or first image with CDN URL
                cdn_base = f'https://cdn.mulvany.net/{directory}/'
                if profile_image:
                    img_src = f'{cdn_base}thumbs/{profile_image}'
                else:
                    img_src = f'{cdn_base}thumbs/{images[0]}' if images else ''

                img_html = f'<img src="{img_src}" alt="{title}" class="gallery-icon">'
            else:
                status_badge = '<span class="status-badge soon">Coming soon</span>'
                img_html = '<span class="gallery-icon placeholder">📸</span>'

            gallery_html = f'''            <a href="{directory}/index.html" class="gallery-link">
                <div class="gallery-main">
                    {img_html}
                    <div class="gallery-details">
                        <h2>{title}</h2>
                        <p class="gallery-location-year">{location} · {year}</p>
                    </div>
                </div>
                <div class="gallery-meta">
                    {status_badge}
                    <span class="arrow">→</span>
                </div>
            </a>'''

            gallery_links.append(gallery_html)

        galleries_html = '\n\n'.join(gallery_links)

        html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Familienfest Galleries</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #0a0a0a;
            color: #fff;
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }}

        header {{
            text-align: center;
            padding: 5rem 2rem 3rem 2rem;
        }}

        h1 {{
            font-size: 4rem;
            font-weight: 200;
            margin-bottom: 1rem;
            letter-spacing: 8px;
            text-transform: uppercase;
        }}

        .subtitle {{
            font-size: 1rem;
            color: #666;
            letter-spacing: 3px;
            text-transform: uppercase;
        }}

        main {{
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }}

        .galleries-list {{
            max-width: 800px;
            width: 100%;
        }}

        .gallery-link {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 2rem 3rem;
            margin-bottom: 1px;
            background: #0f0f0f;
            text-decoration: none;
            color: inherit;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
        }}

        .gallery-link:hover {{
            background: #1a1a1a;
            border-left-color: #fff;
            padding-left: 3.5rem;
        }}

        .gallery-link:first-child {{
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
        }}

        .gallery-link:last-child {{
            border-bottom-left-radius: 8px;
            border-bottom-right-radius: 8px;
        }}

        .gallery-main {{
            display: flex;
            align-items: center;
            gap: 2rem;
        }}

        .gallery-icon {{
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 4px;
            opacity: 0.9;
        }}

        .gallery-icon.placeholder {{
            display: flex;
            align-items: center;
            justify-content: center;
            background: #1a1a1a;
            font-size: 2rem;
            opacity: 0.7;
        }}

        .gallery-details h2 {{
            font-size: 1.8rem;
            font-weight: 400;
            margin-bottom: 0.3rem;
            letter-spacing: 2px;
        }}

        .gallery-location-year {{
            font-size: 0.9rem;
            color: #666;
            letter-spacing: 1px;
        }}

        .gallery-meta {{
            display: flex;
            align-items: center;
            gap: 2rem;
        }}

        .status-badge {{
            padding: 0.5rem 1.2rem;
            border-radius: 30px;
            font-size: 0.75rem;
            letter-spacing: 1px;
            text-transform: uppercase;
            font-weight: 600;
        }}

        .status-badge.available {{
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
        }}

        .status-badge.soon {{
            background: transparent;
            border: 1px solid #333;
            color: #666;
        }}

        .arrow {{
            font-size: 1.5rem;
            opacity: 0;
            transition: opacity 0.3s ease;
            color: #666;
        }}

        .gallery-link:hover .arrow {{
            opacity: 1;
        }}

        .divider {{
            height: 1px;
            background: linear-gradient(90deg, transparent, #333, transparent);
            margin: 3rem 0;
        }}

        footer {{
            text-align: center;
            padding: 3rem 2rem;
            color: #333;
            font-size: 0.8rem;
            letter-spacing: 2px;
        }}

        @media (max-width: 768px) {{
            h1 {{
                font-size: 2rem;
                letter-spacing: 4px;
            }}

            .gallery-link {{
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
                padding: 1.5rem 2rem;
            }}

            .gallery-link:hover {{
                padding-left: 2rem;
            }}

            .gallery-meta {{
                width: 100%;
                justify-content: space-between;
            }}

            .arrow {{
                display: none;
            }}
        }}
    </style>
</head>
<body>
    <header>
        <h1>Familienfest</h1>
        <p class="subtitle">Gallery Collection</p>
    </header>

    <main>
        <div class="galleries-list">
{galleries_html}
        </div>
    </main>

    <footer>
        <p>© 2025</p>
    </footer>
</body>
</html>
'''
        return html

    def save_gallery_page(self, gallery: Dict[str, str], html: str):
        """Save individual gallery index.html"""
        directory = gallery['directory']
        gallery_path = self.base_path / directory
        gallery_path.mkdir(exist_ok=True)

        index_path = gallery_path / 'index.html'
        with open(index_path, 'w') as f:
            f.write(html)

        print(f"Generated: {index_path}")

    def save_master_page(self, html: str):
        """Save master-gallery.html"""
        master_path = self.base_path / 'master-gallery.html'
        with open(master_path, 'w') as f:
            f.write(html)

        print(f"Generated: {master_path}")


def main():
    """Main entry point"""
    import sys

    # Get base path from command line or use current directory
    base_path = sys.argv[1] if len(sys.argv) > 1 else '.'
    base_path = Path(base_path).resolve()

    config_path = base_path / 'gallery-config.md'

    if not config_path.exists():
        print(f"Error: Config file not found at {config_path}")
        sys.exit(1)

    print(f"Reading configuration from: {config_path}")

    # Parse configuration
    config = GalleryConfig(str(config_path))

    if not config.galleries:
        print("Error: No galleries found in configuration")
        sys.exit(1)

    print(f"Found {len(config.galleries)} galleries in configuration")

    # Generate gallery pages
    generator = GalleryGenerator(str(base_path))

    for gallery in config.galleries:
        print(f"\nGenerating gallery for: {gallery['title']} ({gallery['directory']})")
        html = generator.generate_gallery_page(gallery)
        if html:
            generator.save_gallery_page(gallery, html)

    # Generate master page
    print(f"\nGenerating master gallery page...")
    master_html = generator.generate_master_page(config.galleries)
    generator.save_master_page(master_html)

    print(f"\n✓ Gallery generation complete!")


if __name__ == '__main__':
    main()

"""
- given a hey url, fetch the blog content
"""

import requests
from bs4 import BeautifulSoup
import logging  # Import logging

# Set up logging configuration
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def fetch_blog_content(url):
    try:
        # Fetch the HTML content
        response = requests.get(url)
        response.raise_for_status()  # Check for request errors

        # Parse the HTML
        soup = BeautifulSoup(response.text, "html.parser")

        # Extract the blog post content inside <div class="trix-content">
        content_div = soup.find("div", class_="trix-content")
        if content_div:
            logging.info(f"Content found for {url}")
            return str(content_div)  # Return the full HTML of the content_div
        else:
            return "<div>Blog content not found.</div>"
    except requests.exceptions.RequestException as e:
        logging.error(f"Error fetching the URL: {e}")
        return f"<div>Error fetching the URL: {e}</div>"


if __name__ == "__main__":
    dry_run = True  # Set to True for dry run, False to perform actual fetch
    test_url = "https://world.hey.com/ian.mulvany/all-my-blog-posts-2dd22f7c"

    if dry_run:
        logging.info("Dry run: Would fetch content from {url}")
        content = "<div class='trix-content'>Simulated HTML content for dry run.</div>"
    else:
        logging.info(f"Fetching content from {test_url}")
        content = fetch_blog_content(url)
    print(content)

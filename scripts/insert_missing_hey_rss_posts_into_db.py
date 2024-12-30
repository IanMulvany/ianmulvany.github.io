"""
using get_missing_posts from get_posts_from_RSS_not_in_db.py, 
and the fetch_blog_content function from scrape_hey_blog_page_content.py,
insert the missing posts into the database.
"""

import sqlite3
import time
import logging
from datetime import datetime
from scrape_hey_blog_page_content import fetch_blog_content
from get_posts_from_RSS_not_in_db import get_missing_posts
from datetime import datetime
from dateutil import parser
import os

# Get the base directory of the script
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Path to the database
DB_PATH = os.path.join(BASE_DIR, "../data/blog_posts.db")


logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)


def prepare_date(date_str):
    """
    Converts an input date string to the format 'yyyy-mm-dd'.
    Handles broad date formats like RSS feed formats.

    Args:
        date_str (str): The input date string from an RSS feed or similar source.

    Returns:
        str: The date in 'yyyy-mm-dd' format.

    Raises:
        ValueError: If the input date cannot be parsed.
    """
    try:
        # Use dateutil.parser to parse the input date string flexibly
        parsed_date = parser.parse(date_str)
        # Format the parsed date to 'yyyy-mm-dd'
        return parsed_date.strftime("%Y-%m-%d")
    except Exception as e:
        raise ValueError(f"Unable to parse the date: {date_str}. Error: {e}")


def insert_post_into_db(post, content, blog_name="hey"):
    logging.info(f"in function insert_post_into_db, post: {post.title}")
    try:
        logging.info("about to open DB connection")
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        title = post.title
        link = post.link
        published_date = prepare_date(post.published)
        cursor.execute(
            "INSERT INTO posts (title, date, blog_name, link, full_text) VALUES (?, ?, ?, ?, ?)",
            (title, published_date, blog_name, link, content),
        )
        conn.commit()
    except sqlite3.Error as e:
        logging.error(f"Error inserting post into database: {e}")
    finally:
        if conn:
            conn.close()
            logging.info(f"Database connection closed")


def insert_missing_posts_into_db(dry_run=False):
    if not dry_run:
        missing_posts = get_missing_posts()
        # if there are no missing posts, return
        if len(missing_posts) == 0:
            logging.info("No missing posts found")
            return
        logging.info(f"Found {len(missing_posts)} missing posts")
        for post in missing_posts:
            logging.info(f"Fetching content for post: {post.title}")
            content = fetch_blog_content(post.link)
            logging.info(f"Inserting post into database: {post.title}")
            insert_post_into_db(post, content)
            logging.info(f"Post inserted into database: {post.title}")
    else:
        logging.info("Dry run: Would insert post into database")


if __name__ == "__main__":
    # Run in dry run mode
    insert_missing_posts_into_db(dry_run=False)

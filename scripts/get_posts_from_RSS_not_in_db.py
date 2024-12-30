"""
Compare an RSS feed to the items contained in the database.

The RSS feed is https://world.hey.com/ian.mulvany/feed.atom 
The database is blog_posts.db

Return a list of posts that are not in the database. 
"""

import feedparser
import sqlite3
import os

# Get the base directory of the script
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Path to the database
DB_PATH = os.path.join(BASE_DIR, "../data/blog_posts.db")


def get_missing_posts():
    # Load the RSS feed
    feed = feedparser.parse("https://world.hey.com/ian.mulvany/feed.atom")

    # Connect to the database
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Fetch all posts from the database
    cursor.execute(
        "SELECT title, date, blog_name, link FROM posts WHERE blog_name = 'hey'"
    )
    posts = cursor.fetchall()

    # Compare the feed items to the posts in the database, and keep track of the ones that are not in the database
    missing_posts = []
    for item in feed.entries:
        title = item.title
        date = item.published
        link = item.link

        # Check if the post exists in the database based only on the link
        cursor.execute(
            "SELECT COUNT(*) FROM posts WHERE link = ?",
            (link,),
        )
        count = cursor.fetchone()[0]

        if count == 0:
            missing_posts.append(item)

    # Close the database connection
    conn.close()

    return missing_posts


# Example usage (can be removed or commented out when importing)
if __name__ == "__main__":
    missing_posts = get_missing_posts()
    for post in missing_posts:
        print(
            f"Post not found in database: {post.title} - {post.published} - {post.link}"
        )

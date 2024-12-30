import sqlite3
from datetime import datetime
from collections import defaultdict
import subprocess
import logging
import os

# Get the base directory of the script
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Path to the database
DB_PATH = os.path.join(BASE_DIR, "../data/blog_posts.db")
# Path to the output file
FILE_PATH = os.path.join(BASE_DIR, "../all-my-posts.html")

logging.basicConfig(level=logging.INFO)

# Connect to the SQLite database
conn = sqlite3.connect(DB_PATH)


# Query the database
query = """
SELECT title, date, blog_name, link 
FROM posts 
ORDER BY date DESC;
"""
cursor = conn.cursor()
cursor.execute(query)

# Fetch and organize posts
posts = cursor.fetchall()  # List of tuples: (title, date, blog_name, link)
grouped_posts = defaultdict(list)

# Group posts by month and year
for title, date, blog_name, link in posts:
    post_date = datetime.strptime(date, "%Y-%m-%d")  # Parse date string to datetime
    month_year = post_date.strftime("%B %Y")
    grouped_posts[month_year].append((title, post_date, blog_name, link))

# Close the database connection
conn.close()

# Get the last updated date
last_updated_date = datetime.now().strftime("%Y-%m-%d")

# Generate HTML
html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blog Posts Archive</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
            color: #333;
        }}
        h1 {{
            font-weight: 600;
            margin-bottom: 0.5rem;
            font-size: 2rem;
        }}
        .last-updated {{
            font-size: 0.8rem;
            color: #666;
            margin-bottom: 2rem;
        }}
        .month-heading {{
            font-size: 1.2rem;
            font-weight: 600;
            color: #374151;
            margin: 2rem 0 0.5rem 0;
        }}
        .post-list {{
            list-style: none;
            padding: 0;
            margin: 0;
            line-height: 1.1;
        }}
        .post-item {{
            margin-bottom: 0.25rem;
        }}
        .post-date {{
            color: #666;
            font-size: 0.8rem;
        }}
        .post-title {{
            color: #059669;
            text-decoration: none;
            font-weight: 500;
            margin: 0 0.5rem;
        }}
        .post-title:hover {{
            color: #047857;
            text-decoration: underline;
        }}
        .post-blog {{
            color: #666;
            font-size: 0.9rem;
        }}
        .year-nav {{
            margin-bottom: 2rem;
            padding: 1rem;
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 5px;
        }}
        .year-nav a {{
            margin-right: 0.5rem;
            text-decoration: none;
            color: #059669;
        }}
        .year-nav a:hover {{
            text-decoration: underline;
        }}
    </style>
</head>
<body>
    <h1>Blog Posts Archive</h1>
    <div class="last-updated">Last Updated: {last_updated_date}</div>
    <ul class="post-list">
"""

for month_year, posts in grouped_posts.items():
    # Add month heading with year included in the ID
    html_content += f'<h2 class="month-heading" id="{month_year.replace(" ", "_")}">{month_year}</h2>\n'
    for title, post_date, blog_name, link in posts:
        formatted_date = post_date.strftime("%Y-%m-%d")
        html_content += f"""
        <li class="post-item">
            <span class="post-date">{formatted_date}</span>
            <a href="{link}" class="post-title">{title}</a>
            <span class="post-blog">— {blog_name}</span>
        </li>
        """

html_content += """
    </ul>
</body>
</html>
"""

# Write to a static HTML file
# Write the HTML content to the file
with open(FILE_PATH, "w", encoding="utf-8") as f:
    f.write(html_content)

logging.info(f"Working directory: {os.getcwd()}")
logging.info(f"HTML file generated: {FILE_PATH}")


# # lets see if local git changes work.
# try:
#     subprocess.run(["git", "add", FILE_PATH], check=True)
#     # Commit the changes with a message
#     subprocess.run(["git", "commit", "-m", "Update all-my-posts.html"], check=True)
#     # Push the changes to the remote repository
#     subprocess.run(["git", "push"], check=True)
#     logging.info("Changes committed and pushed to the repository.")
# except subprocess.CalledProcessError as e:
#     logging.error(f"An error occurred while running Git commands: {e}")


# try:
#     # Configure Git with a temporary email and username
#     subprocess.run(["git", "config", "--global", "user.name", "GitHub Actions"], check=True)
#     subprocess.run(["git", "config", "--global", "user.email", "actions@github.com"], check=True)

#     # Authenticate with the GITHUB_TOKEN
#     github_token = os.getenv("GITHUB_TOKEN")
#     repo_url = f"https://x-access-token:{github_token}@github.com/<your-username>/<your-repo>.git"

#     # Add, commit, and push the changes
#     subprocess.run(["git", "add", output_file], check=True)
#     subprocess.run(["git", "commit", "-m", "Update all-my-posts.html"], check=True)
#     subprocess.run(["git", "push", repo_url, "HEAD:master"], check=True)

#     print("Changes committed and pushed to the repository.")
# except subprocess.CalledProcessError as e:
#     print(f"An error occurred while running Git commands: {e}")

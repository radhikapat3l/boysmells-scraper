import requests
import pandas as pd
from bs4 import BeautifulSoup
from datetime import datetime

URL = "https://boysmells.com/collections/eau-de-parfum/products/exploratory-set"
OUTPUT_FILE = "boysmells_price_reviews.csv"

headers = {
    "User-Agent": "Mozilla/5.0"
}

response = requests.get(URL, headers=headers)
response.raise_for_status()

soup = BeautifulSoup(response.text, "lxml")

# ---- PRICE ----
price = None
price_tag = soup.select_one('span.price-item')
if price_tag:
    price = price_tag.get_text(strip=True)

# ---- STAR RATING & REVIEW COUNT ----
avg_rating = None
review_count = None

rating_tag = soup.find("span", {"class": "okeReviews-reviewsSummary-rating"})
count_tag = soup.find("span", {"class": "okeReviews-reviewsSummary-count"})

if rating_tag:
    avg_rating = rating_tag.get_text(strip=True)

if count_tag:
    review_count = count_tag.get_text(strip=True)

data = {
    "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    "price": price,
    "avg_star_rating_out_of_5": avg_rating,
    "review_count": review_count,
    "url": URL
}

df = pd.DataFrame([data])

try:
    old = pd.read_csv(OUTPUT_FILE)
    df = pd.concat([old, df], ignore_index=True)
except FileNotFoundError:
    pass

df.to_csv(OUTPUT_FILE, index=False)
print("Scrape complete. Data saved.")

import os
from bs4 import BeautifulSoup

base_dir = os.path.dirname(os.path.abspath(__file__))
html_path = os.path.join(base_dir, '..', 'htmls', 'ajio.html')

# Open and read the file
with open(html_path, 'r', encoding='utf-8') as f:
    soup = BeautifulSoup(f.read(), 'html.parser')

# Find all product card divs using their specific class attributes
bag_cards = soup.find_all("div", class_="item rilrtl-products-list__item item")
print(len(bag_cards))
# Loop through and extract details from each card
# for card in bag_cards:
#     # Find the link/anchor containing product details
#     link = card.find("a", class_="rilrtl-products-list__link")
#     if link:
#         # Extract product name and price if available
#         brand = card.find("div", class_="brand")
#         name = card.find("div", class_="nameCls")
#         price = card.find("span", class_="price")
#
#         print(f"Brand: {brand.text if brand else 'N/A'}")
#         print(f"Name: {name.text if name else 'N/A'}")
#         print(f"Price: {price.text if price else 'N/A'}")
#         print("-" * 40)
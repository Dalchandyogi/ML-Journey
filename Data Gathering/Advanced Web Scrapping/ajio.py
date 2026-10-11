import time
from selenium import webdriver

driver = webdriver.Chrome()
driver.get("https://www.ajio.com/men-backpacks/c/830201001")
time.sleep(3)  # Initial load wait

last_height = driver.execute_script("return document.body.scrollHeight")
counter = 1

while True:
  # Scroll down in increments or small chunks
  driver.execute_script(
      "window.scrollTo(0, 1000);"
  )  # or window.scrollBy(0, 1000)
  time.sleep(3)  # Wait for AJAX request to fetch new items

  new_height = driver.execute_script("return document.body.scrollHeight")
  print(f"Loop {counter}: old={last_height}, new={new_height}")

  if new_height == last_height:
    print("Reached the bottom or no more items are loading.")
    break

  last_height = new_height
  counter += 1

html = driver.page_source
with open("htmls/ajio.html", "w", encoding="utf-8") as f:
  f.write(html)
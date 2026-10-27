from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

import time,os

# Gets the folder where basic.py is located
base_dir = os.path.dirname(os.path.abspath(__file__))
driver_path = os.path.join(base_dir, 'chromeDriver', 'chromedriver.exe')

s = Service(driver_path)
driver = webdriver.Chrome()

# open the url
target_url = 'https://google.com'
driver.get(target_url)

# ====== Task - 1. Open google and search for the campusx, and see the DSMP page =======
time.sleep(2)
search_input = driver.find_element(by=By.XPATH, value='//*[@id="ti6dpd"]')

search_input.send_keys('campusx')
time.sleep(2)

search_input.send_keys(Keys.ENTER)
time.sleep(2)

link = driver.find_element(by=By.XPATH, value='//*[@id="rso"]/div[1]/div/div/div/div[1]/div/div/span/a')
link.click()
time.sleep(1)

link2 = driver.find_element(by=By.XPATH, value='/html/body/div[1]/header/section[2]/a[1]')
link2.click()



# Keeps the script running as long as the browser window is open
try:
    while len(driver.window_handles) > 0:
        time.sleep(1)
except Exception:
    pass

import os
import time
from datetime import datetime
import requests

BASE = "/var/image"
INTERVAL = 60  # seconds between shots

def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)

def capture_image():
    now = datetime.now()
    day_path = f"{BASE}/{now.year}/{now.month:02d}/{now.day:02d}"
    ensure_dir(day_path)

    filename = f"{now.year}{now.month:02d}{now.day:02d}-{now.hour:02d}{now.minute:02d}{now.second:02d}.jpg"
    full_path = f"{day_path}/{filename}"

    url = "http://localhost:8080/?action=snapshot"
    img = requests.get(url, timeout=5).content

    with open(full_path, "wb") as f:
        f.write(img)

    print(f"Captured {full_path}")

def main():
    while True:
        capture_image()
        time.sleep(INTERVAL)

#if __name__ == "__main__":
#    main()

if __name__ == "__main__":
    capture_image()


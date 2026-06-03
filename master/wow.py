import cv2
import threading
import time
import os
from datetime import datetime
import random
import ctypes
ctypes.windll.winmm.timeBeginPeriod(1)
try:
    ctypes.windll.user32.SetProcessDpiAwarenessContext(-4)  # PerMonitorV2
except:
    ctypes.windll.shcore.SetProcessDpiAwareness(2)
import traceback

import mss
import mss.tools
import numpy as np

# 配置参数
SAVE_FOLDER = "capture" 
MAX_IMAGES = 100  
INTERVAL = 0.02


def det_bar(img, y, left, right):
    r = sum(img[y, left:right, 0] > 10)
    b = sum(img[y, left:right, 2] > 10)

    if r + b == 0:
        ret = None
    else:
        ret = r / (r + b)

    img[y, left:right] = [255, 255, 255, 255]
    return ret

def capture(region = None):
    with mss.mss() as sct:
        region = region or sct.monitors[0]
        return np.array(sct.grab(region))

def main(now):
    img = capture({'left': 0, 'top': 0, 'width': 1000, 'height': 70})
    hp1 = det_bar(img, 5, 25, 149)
    hp2 = det_bar(img, 18, 25, 149)
    hp3 = det_bar(img, 30, 25, 149)
    hp4 = det_bar(img, 43, 25, 149)
    hp5 = det_bar(img, 56, 25, 149)
    print(hp1, hp2, hp3, hp4, hp5)

    ab1 = det_bar(img, 5, 152, 213)
    ab2 = det_bar(img, 18, 152, 213)
    ab3 = det_bar(img, 30, 152, 213)
    ab4 = det_bar(img, 43, 152, 213)
    ab5 = det_bar(img, 56, 152, 213)

    hab1 = det_bar(img, 5, 215, 276)
    hab2 = det_bar(img, 18, 215, 276)
    hab3 = det_bar(img, 30, 215, 276)
    hab4 = det_bar(img, 43, 215, 276)
    hab5 = det_bar(img, 56, 215, 276)

    ch = det_bar(img, 5, 380, 504)
    gcd = det_bar(img, 5, 506, 630)
    cd1 = det_bar(img, 18, 506, 630)
    cd2 = det_bar(img, 30, 506, 630)
    
    cv2.imwrite(os.path.join(SAVE_FOLDER, f"{now:08.3f}.png"), img)

def clear_dir(folder, max_num = 0):
    images = [f for f in os.listdir(folder)]
    if max_num == 0:
        for img in images:
            os.remove(os.path.join(folder, img))
    if len(images) > max_num:
        images.sort()
        for img in images[:-max_num]:
            os.remove(os.path.join(folder, img))

def loop():
    if not os.path.exists(SAVE_FOLDER):
        os.makedirs(SAVE_FOLDER)
    clear_dir(SAVE_FOLDER)

    data = []
    init_time = datetime.now().timestamp()
    next_time = 0
    tick = 0
    while True:
        while (now := datetime.now().timestamp() - init_time) < next_time:
            time.sleep(next_time - now)

        #print(f"▶️  Loop executing {now:8.3f}")
        try:
            ret = main(now)
            data.append(ret)
        except Exception as e:
            print(f"❌ Exception occurred")
            traceback.print_exc()

        tick += 1
        end = datetime.now().timestamp() - init_time
        if tick % 30 == 0:
            clear_dir(SAVE_FOLDER, MAX_IMAGES)
            print(len(data) / end)
        next_time += INTERVAL
        while next_time  < end:
            next_time = next_time + INTERVAL

def start():
    threading.Thread(target=loop, daemon=True).start()

if __name__ == "__main__":
    loop()
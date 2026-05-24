import cv2
import threading
import time
import os
from datetime import datetime

import mss
import mss.tools
import numpy as np

# 配置参数
SAVE_FOLDER = "test"  # 保存图片的文件夹
MAX_IMAGES = 200                  # 最多保留的图片数量
CAPTURE_INTERVAL = 0.1           # 捕获间隔（秒），可根据需求调整

class bar:
    def __init__(self, y, left, right):
        self.y = y
        self.left = left
        self.right = right
    
    def update(self, img, now):
        bar = img[self.y, self.left:self.right, 0]
        print((bar > 200).sum(), bar.shape[0]) 
        img[self.y, self.left:self.right] = [255, 255, 255, 1]
        return img

def det_bar(img, y, left, right):
    bar = img[y, left:right, 0]
    
    print((bar > 200).sum(), bar.shape[0]) 
    img[y, left:right] = [255, 255, 255, 1]
    return img


def capture_screen_to_numpy(region = None):
    start_time = time.time()
    with mss.mss() as sct:
        region = region or sct.monitors[0]
        img = np.array(sct.grab(region))
    end_time = time.time()
    #print(end_time- start_time, region, img.shape)
    return img

def manage_image_count(folder, max_num):
    images = [f for f in os.listdir(folder) if f.endswith((".jpg", ".png", ".jpeg"))]
    if max_num == 0:
        for img in images:
            img_path = os.path.join(folder, img)
            os.remove(img_path)
        
    if len(images) > max_num:
        images.sort()
        for img in images[:-max_num]:
            img_path = os.path.join(folder, img)
            os.remove(img_path)

def save_image_thread():
    while True:
        try:
            now = datetime.now()
            img = capture_screen_to_numpy({'left': 300, 'top': 0, 'width': 400, 'height': 200})
            det_bar(img, 15, 75, 325)

            img_path = os.path.join(SAVE_FOLDER, now.strftime("%Y%m%d_%H%M%S_%f") + ".jpg")
            cv2.imwrite(img_path, img)
            manage_image_count(SAVE_FOLDER, MAX_IMAGES)
        except Exception as e:
            print(f"❌ 线程异常：{str(e)}")
            time.sleep(1)

def start():
    if not os.path.exists(SAVE_FOLDER):
        os.makedirs(SAVE_FOLDER)
    manage_image_count(SAVE_FOLDER, 0)
    threading.Thread(target=save_image_thread, daemon=True).start()
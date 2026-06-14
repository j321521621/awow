import cv2
import time
import os
from datetime import datetime

import pickle

class Log:
    def __init__(self):
        self.dir_log = os.path.join('log', datetime.now().strftime("%Y-%m-%d %H_%M_%S"))
        self.dir_cap = 'log/capture'
        if not os.path.exists(self.dir_cap):
            os.makedirs(self.dir_cap)
        self.clean_capture(0)

    def write_data(self, d):
        return
        with open(self.dir_log, "ab") as f:
            pickle.dump(d, f)

    def write_img(self, img):
        return
        cv2.imwrite(f"{self.dir_cap}/{datetime.now().timestamp():08.3f}.png", img)
        self.clean_capture()
        
    def clean_capture(self, max_num = 100):
        fs = [f for f in os.listdir(self.dir_cap)]
        fs.sort()
        while len(fs) > max_num:
            os.remove(os.path.join(self.dir_cap, fs.pop(0)))

log = Log()
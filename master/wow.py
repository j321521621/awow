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
import pickle


def minv(data):
    v = min(data)
    n = data.index(v)
    return n, v

def maxv(data):
    v = max(data)
    n = data.index(v)
    return n, v

def det_bar(img, y, left, right):
    r = int(sum(img[y, left:right, 0] > 10))
    b = int(sum(img[y, left:right, 2] > 10))
    img[y, left:right] = [255, 255, 255, 255]

    if r + b > 0:
        return r / (r + b)
    else:
        return None

def det_box(img, top, bottom, left, right):
    ret = list(np.mean(img[top: bottom, left:right, :], axis=(0, 1)))[:3]
    img[top: bottom, left:right] = [255, 255, 255, 255]
    return ret


def capture():
    with mss.mss() as sct:
        img = np.array(sct.grab({'left': 0, 'top': 0, 'width': 1000, 'height': 70}))

    hp = [
        det_bar(img, 5, 25, 149),
        det_bar(img, 18, 25, 149),
        det_bar(img, 30, 25, 149),
        det_bar(img, 43, 25, 149),
        det_bar(img, 56, 25, 149),
    ]

    ab = [
        det_bar(img, 5, 152, 213),
        det_bar(img, 18, 152, 213),
        det_bar(img, 30, 152, 213),
        det_bar(img, 43, 152, 213),
        det_bar(img, 56, 152, 213),
    ]

    hab = [
        det_bar(img, 5, 215, 276),
        det_bar(img, 18, 215, 276),
        det_bar(img, 30, 215, 276),
        det_bar(img, 43, 215, 276),
        det_bar(img, 56, 215, 276),
    ]

    job = [
        np.argmax(det_box(img, 4, 7, 4, 7)),
        np.argmax(det_box(img, 17, 20, 4, 7)),
        np.argmax(det_box(img, 29, 32, 4, 7)),
        np.argmax(det_box(img, 42, 45, 4, 7)),
        np.argmax(det_box(img, 55, 58, 4, 7)),
    ]

    dis = [
        sum(det_box(img, 4, 7, 17, 20)) > 750,
        sum(det_box(img, 17, 20, 17, 20)) > 750,
        sum(det_box(img, 29, 32, 17, 20)) > 750,
        sum(det_box(img, 42, 45, 17, 20)) > 750,
        sum(det_box(img, 55, 58, 17, 20)) > 750,
    ]

    ch = det_bar(img, 5, 380, 504)
    gcd = det_bar(img, 5, 506, 630)
    cd1 = det_bar(img, 18, 506, 630)
    cd2 = det_bar(img, 30, 506, 630)

    buff1 = sum(det_box(img, 29, 32, 700, 703)) > 10

    return {
        "job" : job,
        "dis" : dis,
        "hp": hp,
        "ab": ab,
        "hab": hab,
        "ch": ch,
        "buff1" : buff1,

        "gcd": gcd,
        "cd1": cd1,
        "cd2": cd2,
    }, img
    

class State():
    def __init__(self):
        self.data = []

    def add(self, d):
        self.data.append(d)

        self.now = d['now']
        self.gcd = self.guess_cd('gcd', 1.5)
        self.cd1 = self.guess_cd('cd1', 12)
        self.cd2 = self.guess_cd('cd2', 3)

        self.ch = d['ch']
        self.buff1 = d['buff1']
        self.danger = self.guess_danger()


        while self.data and self.data[0]['now'] <  self.now - 1:
            self.data.pop(0)

    def guess_cd(self, k, default):
        if self.data[-1][k] == 1:
            return 0

        for d in self.data[::-1]:
            if d['now'] >  self.now - 0.2 and d[k] == 0:
                return 0

        ds = [self.data[-1]]
        for d in self.data[-2::-1]:
            if ds[-1][k] >= d[k] and d[k] > 0:
                ds.append(d)
            else:
                break

        t0 = ds[-1]['now']
        t1 = ds[0]['now']
        d0 = ds[-1][k]
        d1 = ds[0][k]

        if d1 - d0 < 0.05:
            return (1 - d1) * default

        return (1 - d1) * (t1 - t0) / (d1 - d0)
    
    def guess_danger(self):
        d = self.data[-1]
        tank_id = None
        other_id = []
        for i in range(5):
            if d['dis'][i]:
                if d['job'][i] == 2:
                    tank_id = i
                else:
                    other_id.append(i)

        if other_id:
            n, v = minv([d['hp'][i] + d['ab'][i] for i in other_id])
            if v < 0.95:
                return other_id[n]

            n, v = minv([d['hp'][i] for i in other_id])
            if v < 0.95:
                return other_id[n]
            
            n, v = maxv([d['hab'][i] for i in other_id])
            if v > 0.05:
                return other_id[n]
        
        if tank_id is not None:
            if d['hab'][tank_id] > 0.05:
                return tank_id

        return 0

class Log:
    def __init__(self):
        self.dir_cap = 'log/capture'
        if not os.path.exists(self.dir_cap):
            os.makedirs(self.dir_cap)
        self.clean_capture(0)
        self.dir_log = os.path.join('log', datetime.now().strftime("%Y-%m-%d %H_%M_%S"))
        self.time = []

    def add(self, d, img):
        self.write(d)
        tick = d['tick']
        now = d['now']
        cv2.imwrite(os.path.join(self.dir_cap, f"{now:08.3f}.png"), img)
        self.time.append(now)
        if tick > 0 and tick % 30 == 0:
            self.clean_capture()
            #print(f"{(len(self.time) - 1) / (self.time[-1] - self.time[0]):.2f} Hz")
            self.time = []

    def write(self, d):
        with open(self.dir_log, "ab") as f:
            pickle.dump(d, f)

        
    def clean_capture(self, max_num = 100):
        fs = [f for f in os.listdir(self.dir_cap)]
        fs.sort()
        while len(fs) > max_num:
            os.remove(os.path.join(self.dir_cap, fs.pop(0)))

log = Log()
state = State()

def loop(interval = 0.01):
    global log
    global state

    init_time = datetime.now().timestamp()
    next_time = 0
    tick = 0
    while True:
        while (now := datetime.now().timestamp() - init_time) < next_time:
            time.sleep(next_time - now)

        #print(f"▶️  Loop executing {now:8.3f}")
        try:
            d, img = capture()
            d['tick'] = tick
            d['now'] = now
            log.add(d, img)
            state.add(d)
        except Exception as e:
            print(f"❌ Exception occurred")
            traceback.print_exc()

        tick += 1
        end_time = datetime.now().timestamp() - init_time
        while interval > 0 and next_time  < end_time:
            next_time = next_time + interval

def start():
    threading.Thread(target=loop, daemon=True).start()

if __name__ == "__main__":
    loop()
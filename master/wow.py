import os
import time
import threading
import traceback
from datetime import datetime
import numpy as np
import mss
import ctypes
import math
ctypes.windll.winmm.timeBeginPeriod(1)
try:
    ctypes.windll.user32.SetProcessDpiAwarenessContext(-4)  # PerMonitorV2
except:
    ctypes.windll.shcore.SetProcessDpiAwareness(2)

from log import log

def det_bar(img, left, right, y):
    b = int(sum(img[y, left:right, 0] > 10))
    r = int(sum(img[y, left:right, 2] > 10))
    if r + b > 0:
        ret = b / (r + b)
    else:
        ret = None

    img[y, left:right] = [255, 255, 255, 255]
    return ret

def det_box(img, left, right, top, bottom):
    ret = np.mean(img[top: bottom, left:right, :], axis=(0, 1)).tolist()[:3]

    img[top: bottom, left:right] = [255, 255, 255, 255]
    return ret

def get_aura_stack(aura):
    b, g, r = aura
    if g > 0:
        return 2
    elif b > 0:
        return 1
    else:
        return 0

def capture():
    with mss.mss() as sct:
        img = np.array(sct.grab({'left': 1920, 'top': 0, 'width': 1000, 'height': 70}))

    logo = [
        det_box(img, 0, 45, 0,  5),
        det_box(img, 0, 45, 10, 15),
        det_box(img, 0, 45, 20, 25),
        det_box(img, 0, 45, 30, 35),
        det_box(img, 0, 45, 40, 45),
    ]
    if logo != [[0.0, 0.0, 255.0], [0.0, 255.0, 0.0], [255.0, 0.0, 0.0], [255.0, 0.0, 255.0], [0.0, 255.0, 255.0]]:
        return {}, None

    ret = {
        'hp'        : det_bar(img, 50, 95, 2),
        'mp'        : det_bar(img, 50, 95, 12),
        'essence'   : det_bar(img, 50, 95, 22),
        'cast'      : det_bar(img, 50, 95, 32),
        'channel'   : det_bar(img, 50, 95, 42),

        'gcd'       : det_bar(img, 100, 195,  2),
        'cd_jt'     : det_bar(img, 100, 195, 12),
        'cd_yg'     : det_bar(img, 100, 195, 22),
        'cd_hp'     : det_bar(img, 100, 195, 32),
        'cd_nz'     : det_bar(img, 100, 195, 42),

        'move'      : det_box(img, 200, 210, 5, 10)[0] > 0,
        'buff_bf'   : get_aura_stack(det_box(img, 200, 210, 25, 30)),
        'buff_hx'   : get_aura_stack(det_box(img, 215, 225, 25, 30)),
        'buff_lv'   : det_box(img, 230, 240, 25, 30)[0] > 0,

        'player'    : [],
    }

    for i in range(24):
        basex = 100 * (i // 5) + 250
        basey = 10 * (i % 5)
        p = {
            'id'    : 'raid'+str(i+1),
            'hp'    : det_bar(img, basex + 20, basex + 65, basey + 2),
            'range' : det_box(img, basex + 12, basex + 14, basey + 2, basey + 4)[0] > 200,
            'hx'    : det_box(img, basex + 72, basex + 74, basey + 2, basey + 4)[0] > 0,
            'nz'    : det_box(img, basex + 82, basex + 84, basey + 2, basey + 4)[0] > 0 or det_box(img, basex + 92, basex + 94, basey + 2, basey + 4)[0] > 0,
        }
        if p['hp'] is not None:
            ret['player'].append(p)

    return ret, img
    

class Wow():
    def __init__(self):
        pass

    def add_frame(self, d):
        self.channel = d['channel']

        self.gcd = self.guess_cd(d['gcd'], 1.5)
        self.cd_jt = self.guess_cd(d['cd_jt'], 15)
        self.cd_yg = self.guess_cd(d['cd_yg'], 18)
        self.cd_hp = self.guess_cd(d['cd_hp'], 25)
        self.cd_nz = self.guess_cd(d['cd_nz'], 9)

        self.short_hp = sum((1 - p['hp']) for p in d['player'] if p['range'])
        self.hx_count = sum([p['hx'] for p in d['player']])
        self.target_hx = self.guess_hx_target(d['player'])
        self.target_nz = self.guess_nz_target(d['player'])

        self.buff_hx = d['buff_hx']
        self.buff_bf = d['buff_bf']
        self.buff_lv = d['buff_lv']

        self.cast_jt = self.cd_jt - self.gcd < 0.5
        self.cast_yg = self.cd_yg - self.gcd < 0.5
        self.cast_hp = self.cd_hp - self.gcd < 0.5
        self.cast_nz = (self.buff_lv or self.cd_nz - self.gcd < 0.5) and self.target_nz
        self.cast_hx = (self.buff_bf or d['essence'] > 0.3) and self.target_hx

    def guess_cd(self, cd, default):
        if cd == 0 or cd == 1:
            return 0
        else:
            return (1 - cd) * default

    def guess_hx_target(self, player):
        buffer = sorted(
            player,
            key = lambda p: (p['range'], not p['hx'], not p['nz'], p['hp'], p['id']),
            reverse=True
        )
        if buffer and buffer[0]['range'] and not buffer[0]['hx']:
            return buffer[0]['id']
        else:
            return None
        
    def guess_nz_target(self, player):
        buffer = sorted(
            player,
            key = lambda p: (p['range'], not p['hx'], not p['nz'], p['hp'], p['id']),
            reverse=True
        )
        if buffer and buffer[0]['range']:
            return buffer[0]['id']
        else:
            return None

    def loop(self, interval = 0.01):
        init_time = datetime.now().timestamp()
        next_time = 0
        tick = 0
        while True:
            while (now := datetime.now().timestamp() - init_time) < next_time:
                time.sleep(next_time - now)
            try:
                d, img = capture()
                if d:
                    d['tick'] = tick
                    d['now'] = now
                    log.write_img(img)
                    log.write_data(d)
                    self.add_frame(d)
            except Exception as e:
                print(f"❌ Exception occurred")
                traceback.print_exc()
            tick += 1
            end_time = datetime.now().timestamp() - init_time
            while interval > 0 and next_time  < end_time:
                next_time = next_time + interval
            #print(tick / (datetime.now().timestamp() - init_time))

    def start(self):
        threading.Thread(target=self.loop, daemon=True).start()

wow = Wow()

if __name__ == "__main__":
    wow.loop()
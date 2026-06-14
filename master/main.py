import os
import sys
import time
import random
from datetime import datetime
import threading
import traceback


import cv2
import keyboard
import pyautogui
pyautogui.PAUSE = 0  # 取消默认 0.1 秒间隔
pyautogui.MINIMUM_SLEEP = 0

from wow import wow
from log import log

def on_1():
    gcd = wow.gcd
    cd1 = wow.cd1
    cd2 = wow.cd2

    if cd1 - gcd < 0.5:
        key = 'num7'
    elif cd2 - gcd <0.5:
        key = 'num8'
    else:
        key = 'num9'
    
    log.write_data([wow.now, 'attack', gcd, cd1, cd2, key])
    pyautogui.press(key)

def on_2():
    if wow.buff1:
        key = 'add'
    elif wow.ch is None or wow.ch > 0.95:
        key = 'num0'
    else:
        key = 'add'

    player = f'num{wow.danger+1}'

    log.write_data([wow.now, 'heal', player, key])
    pyautogui.press(player)
    pyautogui.press(key)

def on_3():
    pyautogui.press('num6')


lock = threading.Lock()

def loop():
    while True:
        with lock:
            #print(f"{wow.now:0.2f}")
            try:
                if keyboard.is_pressed('alt'):
                    pass
                elif keyboard.is_pressed(2):
                    on_1()
                elif keyboard.is_pressed(3):
                    on_2()
                elif keyboard.is_pressed(4):
                    on_3()
            except Exception as e:
                print(f"❌ Exception occurred")
                traceback.print_exc()
        time.sleep(0.2)


class KeyState:
    def __init__(self):
        self.data = {}

    def process(self, event):
        c, t = event.scan_code, event.event_type
        if c not in self.data:
            self.data[c] = 'up'
        if t == 'up' and self.data[c] == 'down':
            self.data[c] = 'up'
            return True
        if t == 'down' and self.data[c] == 'up':
            self.data[c] = 'down'
            return True
        return False


keystate = KeyState()
def onkey(event):
    if not keystate.process(event):
        return
    if keyboard.is_pressed('alt'):
        return
    with lock:
        #print(f"{wow.now:0.2f} {event.scan_code} {event.event_type}")
        if event.scan_code == 2 and event.event_type == 'down':
            on_1()
        elif event.scan_code == 3 and event.event_type == 'down':
            on_2()
        elif event.scan_code == 4 and event.event_type == 'down':
            on_3()

if __name__ == '__main__':
    wow.start()
    keyboard.hook(onkey)
    threading.Thread(target=loop, daemon=True).start()
    keyboard.wait()
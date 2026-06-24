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





class Main:
    def __init__(self):
        self.key_state = {}
        self.enable = True
        self.lock = threading.Lock()

    def process(self, event):
        c, t = event.scan_code, event.event_type
        if c not in self.key_state:
            self.key_state[c] = 'up'
        if t == 'up' and self.key_state[c] == 'down':
            self.key_state[c] = 'up'
            return True
        if t == 'down' and self.key_state[c] == 'up':
            self.key_state[c] = 'down'
            return True
        return False

    def on_key(self, event):
        if not self.process(event):
            return
        if event.scan_code == 88 and event.event_type == 'down': #F12
            if self.enable:
                self.enable = False
                print('PAUSE……')
            else:
                self.enable = True
                print('STAND BY')
        if self.enable == False:
            return
        if keyboard.is_pressed('alt'):
            return
        with self.lock:
            #print(f"{wow.now:0.2f} {event.scan_code} {event.event_type}")
            if event.scan_code == 2 and event.event_type == 'down': #1
                self.on_1()
            elif event.scan_code == 3 and event.event_type == 'down': #2
                self.on_2()
            elif event.scan_code == 4 and event.event_type == 'down': #3
                self.on_3()

    def on_1(self):
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

    def on_2(self):
        if wow.buff1:
            key = 'add'
        elif wow.ch is None or wow.ch > 0.95:
            key = 'num0'
        else:
            if wow.danger is None:
                return
            key = 'add'

        if wow.danger is None:
            player = f'num1'
        else:
            player = f'num{wow.danger+1}'

        log.write_data([wow.now, 'heal', player, key])
        pyautogui.press(player)
        pyautogui.press(key)

    def on_3(self):
        pyautogui.press('num6')
            
    def loop(self):
        while True:
            if self.enable == False:
                continue
            with self.lock:
                #print(f"{wow.now:0.2f}")
                try:
                    if keyboard.is_pressed('alt'):
                        pass
                    elif keyboard.is_pressed(2):
                        self.on_1()
                    elif keyboard.is_pressed(3):
                        self.on_2()
                    elif keyboard.is_pressed(4):
                        self.on_3()
                except Exception as e:
                    print(f"❌ Exception occurred")
                    traceback.print_exc()
            time.sleep(0.2)

    def start(self):
        threading.Thread(target=self.loop, daemon=True).start()

main = Main()

if __name__ == '__main__':
    wow.start()
    keyboard.hook(lambda event:main.on_key(event))
    main.start()
    print('STAND BY')
    keyboard.wait()
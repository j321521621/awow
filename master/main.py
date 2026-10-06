import os
import sys
import time
import random
from datetime import datetime
import threading
import traceback

import keyboard
import pyautogui
pyautogui.PAUSE = 0  # 取消默认 0.1 秒间隔
pyautogui.MINIMUM_SLEEP = 0

from wow import wow
from log import log

HK = {
    'raid1' : 'f7',
    'raid2' : 'f8',
    'raid3' : 'f9',
    'raid4' : 'f10',
    'raid5' : 'f11',
    'raid6' : 'f12',
    'raid7' : '7',
    'raid8' : '8',
    'raid9' : '9',
    'raid10' : '0',
    'raid11' : '-',
    'raid12' : '=',

    'raid13' : 'num1',
    'raid14' : 'num2',
    'raid15' : 'num3',
    'raid16' : 'num4',
    'raid17' : 'num5',
    'raid18' : 'num6',
    'raid19' : 'num7',
    'raid20' : 'num8',
    'raid21' : 'num9',
    'raid22' : 'num0',
    'raid23' : 'add',
    'raid24' : 'subtract',

    'lp' : 'delete',
    'nz' : 'home',
    'yg' : 'end',
    'jt' : 'pageup',
    'hx' : 'pagedown',
    'fc' : '[',
    'hp' : ']',
    'ly' : ';',

}


def on_1():   
    if wow.available == False:
        pass
    elif wow.channel:
        pass
    elif wow.cast_nz and wow.hx_count:
        pyautogui.press(HK[wow.target_nz])
        pyautogui.press(HK['nz'])
    elif wow.buff_bf and wow.short_hp >= 1.0:
        pyautogui.press(HK['fc'])
    elif wow.buff_bf == 2 and wow.buff_hx < 2:
        pyautogui.press(HK['fc'])
    elif wow.buff_bf < 2 and wow.cast_yg:
        pyautogui.press(HK['yg'])

def on_2():
    if wow.available == False:
        pass
    else:
        pyautogui.press(HK['lp'])

def on_3():
    if wow.available == False:
        pass
    elif wow.channel:
        pass
    elif wow.cast_jt:
        pyautogui.press(HK['jt'])
    elif wow.cast_hx and wow.buff_hx == 2:
        pyautogui.press(HK[wow.target_hx])
        pyautogui.press(HK['hx'])
    elif wow.buff_bf:
        pyautogui.press(HK['fc'])
    elif wow.cast_hx:
        pyautogui.press(HK[wow.target_hx])
        pyautogui.press(HK['hx'])
    elif wow.cast_hp:
        pyautogui.press(HK['hp'])

def on_4():
    pass

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
        if event.scan_code == 69 and event.event_type == 'down': #F12
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
                on_1()
            elif event.scan_code == 3 and event.event_type == 'down': #2
                on_2()
            elif event.scan_code == 4 and event.event_type == 'down': #3
                on_3()
            elif event.scan_code == 5 and event.event_type == 'down': #4
                on_4()

            
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
                        on_1()
                    elif keyboard.is_pressed(3):
                        on_2()
                    elif keyboard.is_pressed(4):
                        on_3()
                    elif keyboard.is_pressed(5):
                        on_4()
                except Exception as e:
                    print(f"❌ Exception occurred")
                    traceback.print_exc()
            time.sleep(0.2)

    def start(self):
        pass
        threading.Thread(target=self.loop, daemon=True).start()

main = Main()

if __name__ == '__main__':
    wow.start()
    keyboard.hook(lambda event:main.on_key(event))
    main.start()
    print('STAND BY')
    keyboard.wait()
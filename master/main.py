import os
import sys
import time
import random
from datetime import datetime

import cv2
import keyboard
import pyautogui
pyautogui.PAUSE = 0  # 取消默认 0.1 秒间隔
pyautogui.MINIMUM_SLEEP = 0

import wow



def on_key_event(e):
    #print(f"{wow.state.now}: {e.name} {e.event_type}")
    if e.name == '1' and e.event_type == 'down':
        gcd = wow.state.gcd
        cd1 = wow.state.cd1
        cd2 = wow.state.cd2

        if cd1 - gcd < 0.5:
            key = 'num7'
        elif cd2 - gcd <0.5:
            key = 'num8'
        else:
            key = 'num9'
        
        print('cd:', gcd, cd1, cd2, key)
        pyautogui.press(key)

    #if e.scan_code == 2 and e.event_type == 'down':
    #    print(i%5+1)
    #    pyautogui.press('num'+str(i%5+1))
    #    pyautogui.press('num6')


if __name__ == '__main__':
    wow.start()
    keyboard.hook(on_key_event)
    keyboard.wait()
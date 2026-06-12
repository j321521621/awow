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
    #print(f"{wow.state.now}: {e.scan_code}")
    if e.scan_code == 2 and e.event_type == 'down':
        gcd = wow.state.gcd
        cd1 = wow.state.cd1
        cd2 = wow.state.cd2

        if cd1 - gcd < 0.5:
            key = 'num7'
        elif cd2 - gcd <0.5:
            key = 'num8'
        else:
            key = 'num9'
        
        print(wow.state.now, 'attack', gcd, cd1, cd2, key)
        pyautogui.press(key)

    if e.scan_code == 3 and e.event_type == 'down':
        if wow.state.buff1:
            key = 'add'
        elif wow.state.ch is None or wow.state.ch > 0.95:
            key = 'num0'
        else:
            key = 'add'

        player = f'num{wow.state.danger+1}'

        print(wow.state.now, 'heal', player, key)
        pyautogui.press(player)
        pyautogui.press(key)

    if e.name == '3' and e.event_type == 'down':
        pass



if __name__ == '__main__':
    wow.start()
    keyboard.hook(on_key_event)
    keyboard.wait()
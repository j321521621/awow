import os
import sys
import time
from datetime import datetime

import cv2
import keyboard
import pyautogui

pyautogui.PAUSE = 0  # 取消默认 0.1 秒间隔
pyautogui.MINIMUM_SLEEP = 0

import wow
wow.start()



# 按键回调函数
def on_key_event(e):
    now = datetime.now()
    now = now.strftime("%H:%M:%S.%f")[:-3]
    print(f"{now}: {e.name} {e.event_type}")
    if e.scan_code == 2 and e.event_type == 'down':
        pass
        #cv2.imwrite(f"test/img.png",img)
        pyautogui.press('num1')

# 监听全局所有键盘事件
keyboard.hook(on_key_event)

# 保持程序运行，防止退出
keyboard.wait()
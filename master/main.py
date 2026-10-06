import os
import sys
import time
from datetime import datetime
import threading
import traceback

import keyboard

from wow import wow
import logic


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
                logic.on_1()
            elif event.scan_code == 3 and event.event_type == 'down': #2
                logic.on_2()
            elif event.scan_code == 4 and event.event_type == 'down': #3
                logic.on_3()
            elif event.scan_code == 5 and event.event_type == 'down': #4
                logic.on_4()

            
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
                        logic.on_1()
                    elif keyboard.is_pressed(3):
                        logic.on_2()
                    elif keyboard.is_pressed(4):
                        logic.on_3()
                    elif keyboard.is_pressed(5):
                        logic.on_4()
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